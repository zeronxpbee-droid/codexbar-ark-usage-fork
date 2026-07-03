#if canImport(CryptoKit)
import CryptoKit
#else
import Crypto
#endif
import Foundation

/// Minimal Volcengine (火山引擎) Signature V4 request signer for the Ark
/// Agent Plan `GetAFPUsage` OpenAPI.
///
/// This is derived structurally from CodexBar's existing `BedrockAWSSigner`
/// (AWS SigV4) but implements the **Volcengine** signing spec, which differs
/// from AWS in several ways that are called out inline below. It is
/// intentionally self-contained and offline: it produces signature material for
/// a request but performs no networking itself.
///
/// Spec assumptions (verified during M0 against the credentialed live probe):
///   1. Algorithm label is `HMAC-SHA256` (NOT AWS's `AWS4-HMAC-SHA256`).
///   2. Credential scope terminates with `/request` (NOT `/aws4_request`).
///   3. The signing key chain seeds with the raw secret key
///      (`kDate = HMAC(SecretKey, shortDate)`) with NO `AWS4` prefix, and the
///      final step hashes the literal string `request`.
///   4. Date header is `X-Date` in `yyyyMMdd'T'HHmmss'Z'` UTC.
///   5. Payload hash header is `X-Content-Sha256`.
///   6. Signed headers are the lowercased, semicolon-joined, sorted set of
///      `content-type;host;x-content-sha256;x-date`.
///
/// Session tokens (STS `X-Security-Token`) are intentionally NOT supported: the
/// official spec requires that header to be part of the canonical signed
/// headers, and Agent Plan uses long-lived IAM AK/SK. Rather than emit an
/// unsigned token header, only AK/SK is accepted.
public enum VolcengineArkSigner {
    public struct Credentials: Sendable {
        public let accessKeyID: String
        public let secretAccessKey: String

        public init(accessKeyID: String, secretAccessKey: String) {
            self.accessKeyID = accessKeyID
            self.secretAccessKey = secretAccessKey
        }
    }

    /// A fully-described request to be signed. Kept transport-agnostic so the
    /// signer can be unit-tested with fixed vectors and no `URLRequest`.
    public struct RequestInput: Sendable {
        public let method: String
        public let host: String
        public let path: String
        /// Query items as (name, value) pairs, unencoded.
        public let query: [(String, String)]
        public let contentType: String
        public let body: Data

        public init(
            method: String = "POST",
            host: String,
            path: String = "/",
            query: [(String, String)],
            contentType: String = "application/json",
            body: Data)
        {
            self.method = method
            self.host = host
            self.path = path
            self.query = query
            self.contentType = contentType
            self.body = body
        }
    }

    /// The signature material produced for a request. `headers` can be applied
    /// directly to a URLRequest by the caller.
    public struct SignedResult: Sendable {
        public let headers: [String: String]
        public let canonicalRequest: String
        public let stringToSign: String
        public let credentialScope: String
        public let signedHeaders: String
        public let signature: String
        public let authorization: String
    }

    // Algorithm constants — see spec assumptions above.
    static let algorithm = "HMAC-SHA256"
    static let credentialScopeTerminator = "request"

    /// Produce signature material for `input`. Pure and deterministic given
    /// `date`; performs no I/O.
    public static func sign(
        _ input: RequestInput,
        credentials: Credentials,
        region: String,
        service: String,
        date: Date) -> SignedResult
    {
        let xDate = Self.amzDate(from: date)
        let shortDate = Self.shortDate(from: date)
        let bodyHash = Self.sha256Hex(input.body)

        // Canonical headers. Volcengine signs a fixed core set; we include
        // content-type, host, x-content-sha256, x-date.
        var headerPairs: [(String, String)] = [
            ("content-type", input.contentType),
            ("host", input.host),
            ("x-content-sha256", bodyHash),
            ("x-date", xDate),
        ]
        headerPairs.sort { $0.0 < $1.0 }

        let signedHeaders = headerPairs.map(\.0).joined(separator: ";")
        let canonicalHeaders = headerPairs.map { "\($0.0):\($0.1)" }.joined(separator: "\n")

        let canonicalRequest = [
            input.method.uppercased(),
            Self.uriEncodePath(input.path.isEmpty ? "/" : input.path),
            Self.canonicalQueryString(input.query),
            canonicalHeaders + "\n",
            signedHeaders,
            bodyHash,
        ].joined(separator: "\n")

        let credentialScope = "\(shortDate)/\(region)/\(service)/\(Self.credentialScopeTerminator)"

        let stringToSign = [
            Self.algorithm,
            xDate,
            credentialScope,
            Self.sha256Hex(Data(canonicalRequest.utf8)),
        ].joined(separator: "\n")

        let signature = Self.calculateSignature(
            secretKey: credentials.secretAccessKey,
            shortDate: shortDate,
            region: region,
            service: service,
            stringToSign: stringToSign)

        let authorization = "\(Self.algorithm) "
            + "Credential=\(credentials.accessKeyID)/\(credentialScope), "
            + "SignedHeaders=\(signedHeaders), "
            + "Signature=\(signature)"

        let headers: [String: String] = [
            "Content-Type": input.contentType,
            "Host": input.host,
            "X-Content-Sha256": bodyHash,
            "X-Date": xDate,
            "Authorization": authorization,
        ]

        return SignedResult(
            headers: headers,
            canonicalRequest: canonicalRequest,
            stringToSign: stringToSign,
            credentialScope: credentialScope,
            signedHeaders: signedHeaders,
            signature: signature,
            authorization: authorization)
    }

    // MARK: - Signing key derivation (Volcengine chain)

    private static func calculateSignature(
        secretKey: String,
        shortDate: String,
        region: String,
        service: String,
        stringToSign: String) -> String
    {
        // NOTE: no "AWS4" prefix on the secret; final step hashes "request".
        let kDate = Self.hmacSHA256(key: Data(secretKey.utf8), data: Data(shortDate.utf8))
        let kRegion = Self.hmacSHA256(key: kDate, data: Data(region.utf8))
        let kService = Self.hmacSHA256(key: kRegion, data: Data(service.utf8))
        let kSigning = Self.hmacSHA256(key: kService, data: Data(Self.credentialScopeTerminator.utf8))
        let signature = Self.hmacSHA256(key: kSigning, data: Data(stringToSign.utf8))
        return signature.map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Primitives

    static func hmacSHA256(key: Data, data: Data) -> Data {
        let symmetricKey = SymmetricKey(data: key)
        let mac = HMAC<SHA256>.authenticationCode(for: data, using: symmetricKey)
        return Data(mac)
    }

    static func sha256Hex(_ data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Canonicalization helpers

    static func canonicalQueryString(_ query: [(String, String)]) -> String {
        guard !query.isEmpty else { return "" }
        return query
            .map { "\(self.uriEncode($0.0))=\(self.uriEncode($0.1))" }
            .sorted()
            .joined(separator: "&")
    }

    static func uriEncode(_ string: String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        return string.addingPercentEncoding(withAllowedCharacters: allowed) ?? string
    }

    static func uriEncodePath(_ path: String) -> String {
        path.split(separator: "/", omittingEmptySubsequences: false)
            .map { self.uriEncode(String($0)) }
            .joined(separator: "/")
    }

    // MARK: - Date formatting

    static func amzDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    static func shortDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
}
