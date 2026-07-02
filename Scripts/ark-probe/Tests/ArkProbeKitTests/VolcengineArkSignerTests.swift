import Foundation
import XCTest
@testable import ArkProbeKit

/// Signature vectors are produced by an INDEPENDENT Python reference
/// implementation (Scripts/ark-probe/reference/volc_sign_reference.py), not by
/// the Swift signer under test. This ensures the test does not merely assert
/// that the implementation equals itself.
final class VolcengineArkSignerTests: XCTestCase {
    // Fixed, non-real inputs — mirror volc_sign_reference.py exactly.
    private let ak = "AKTESTEXAMPLE000000000"
    private let sk = "TESTSECRET0000000000000000000000"
    private let region = "cn-beijing"
    private let service = "ark"
    private let host = "ark.cn-beijing.volces.com"
    // 2026-07-02T00:00:00Z
    private let fixedDate = Date(timeIntervalSince1970: 1_782_950_400)

    private func makeSignedResult() -> VolcengineArkSigner.SignedResult {
        let input = VolcengineArkSigner.RequestInput(
            method: "POST",
            host: host,
            path: "/",
            query: [("Action", "GetAFPUsage"), ("Version", "2024-01-01")],
            contentType: "application/json",
            body: Data("{}".utf8))
        return VolcengineArkSigner.sign(
            input,
            credentials: .init(accessKeyID: ak, secretAccessKey: sk),
            region: region,
            service: service,
            date: fixedDate)
    }

    func test_fixedDate_matchesExpectedUTCStamps() {
        // Guards against locale/timezone regressions in the date formatter.
        XCTAssertEqual(VolcengineArkSigner.amzDate(from: fixedDate), "20260702T000000Z")
        XCTAssertEqual(VolcengineArkSigner.shortDate(from: fixedDate), "20260702")
    }

    func test_bodyHash_matchesPythonReference() {
        let result = makeSignedResult()
        // SHA-256 of "{}"
        let expected = "44136fa355b3678a1146ad16f7e8649e94fb4fc21fe77e8310c060f61caaff8a"
        XCTAssertEqual(result.headers["X-Content-Sha256"], expected)
    }

    func test_signedHeaders_matchesPythonReference() {
        let result = makeSignedResult()
        XCTAssertEqual(result.signedHeaders, "content-type;host;x-content-sha256;x-date")
    }

    func test_credentialScope_matchesPythonReference() {
        let result = makeSignedResult()
        XCTAssertEqual(result.credentialScope, "20260702/cn-beijing/ark/request")
    }

    func test_canonicalRequest_matchesPythonReference() {
        let result = makeSignedResult()
        let expected = [
            "POST",
            "/",
            "Action=GetAFPUsage&Version=2024-01-01",
            "content-type:application/json",
            "host:ark.cn-beijing.volces.com",
            "x-content-sha256:44136fa355b3678a1146ad16f7e8649e94fb4fc21fe77e8310c060f61caaff8a",
            "x-date:20260702T000000Z",
            "",
            "content-type;host;x-content-sha256;x-date",
            "44136fa355b3678a1146ad16f7e8649e94fb4fc21fe77e8310c060f61caaff8a",
        ].joined(separator: "\n")
        XCTAssertEqual(result.canonicalRequest, expected)
    }

    func test_signature_matchesPythonReference() {
        let result = makeSignedResult()
        // Independently computed by volc_sign_reference.py.
        let expected = "0b9d4a47c69fbb15135625cad9f6309b7e478bca238e816897505b9373186e96"
        XCTAssertEqual(result.signature, expected)
    }

    func test_authorization_containsAlgorithmAndCredential_butSecretNotLeaked() {
        let result = makeSignedResult()
        XCTAssertTrue(result.authorization.hasPrefix("HMAC-SHA256 "))
        XCTAssertTrue(result.authorization.contains("Credential=\(ak)/20260702/cn-beijing/ark/request"))
        XCTAssertTrue(result.authorization.contains("SignedHeaders=content-type;host;x-content-sha256;x-date"))
        XCTAssertTrue(result.authorization.contains("Signature=0b9d4a47c69fbb15135625cad9f6309b7e478bca238e816897505b9373186e96"))
        // The secret must never appear anywhere in the produced material.
        XCTAssertFalse(result.authorization.contains(sk))
    }

    func test_canonicalQueryString_isSortedAndEncoded() {
        let q = VolcengineArkSigner.canonicalQueryString([("b", "2"), ("a", "1 2")])
        XCTAssertEqual(q, "a=1%202&b=2")
    }
}
