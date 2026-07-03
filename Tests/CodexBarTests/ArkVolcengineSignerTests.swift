import Foundation
import Testing
@testable import CodexBarCore

/// Signature vectors mirror the INDEPENDENT Python reference implementation used
/// by the M0 probe (`Scripts/ark-probe/reference/volc_sign_reference.py`), not
/// the Swift signer under test, so the test does not merely assert the
/// implementation equals itself. These are the same fixed, non-real inputs and
/// expected outputs verified in M0, now pinned against the production
/// `CodexBarCore.VolcengineArkSigner`.
struct ArkVolcengineSignerTests {
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
            host: self.host,
            path: "/",
            query: [("Action", "GetAFPUsage"), ("Version", "2024-01-01")],
            contentType: "application/json",
            body: Data("{}".utf8))
        return VolcengineArkSigner.sign(
            input,
            credentials: .init(accessKeyID: self.ak, secretAccessKey: self.sk),
            region: self.region,
            service: self.service,
            date: self.fixedDate)
    }

    @Test
    func `fixed date matches expected UTC stamps`() {
        // Guards against locale/timezone regressions in the date formatter.
        #expect(VolcengineArkSigner.amzDate(from: self.fixedDate) == "20260702T000000Z")
        #expect(VolcengineArkSigner.shortDate(from: self.fixedDate) == "20260702")
    }

    @Test
    func `body hash matches python reference`() {
        // SHA-256 of "{}".
        let expected = "44136fa355b3678a1146ad16f7e8649e94fb4fc21fe77e8310c060f61caaff8a"
        #expect(self.makeSignedResult().headers["X-Content-Sha256"] == expected)
    }

    @Test
    func `signed headers match python reference`() {
        #expect(self.makeSignedResult().signedHeaders == "content-type;host;x-content-sha256;x-date")
    }

    @Test
    func `credential scope terminates with request not aws4_request`() {
        #expect(self.makeSignedResult().credentialScope == "20260702/cn-beijing/ark/request")
    }

    @Test
    func `canonical request matches python reference`() {
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
        #expect(self.makeSignedResult().canonicalRequest == expected)
    }

    @Test
    func `signature matches independent python reference`() {
        // Independently computed by volc_sign_reference.py.
        let expected = "0b9d4a47c69fbb15135625cad9f6309b7e478bca238e816897505b9373186e96"
        #expect(self.makeSignedResult().signature == expected)
    }

    @Test
    func `authorization carries algorithm and credential but never leaks the secret`() {
        let result = self.makeSignedResult()
        #expect(result.authorization.hasPrefix("HMAC-SHA256 "))
        #expect(result.authorization.contains("Credential=\(self.ak)/20260702/cn-beijing/ark/request"))
        #expect(result.authorization.contains("SignedHeaders=content-type;host;x-content-sha256;x-date"))
        #expect(result.authorization
            .contains("Signature=0b9d4a47c69fbb15135625cad9f6309b7e478bca238e816897505b9373186e96"))
        // The secret must never appear anywhere in the produced material.
        #expect(!result.authorization.contains(self.sk))
        for value in result.headers.values {
            #expect(!value.contains(self.sk))
        }
    }

    @Test
    func `canonical query string is sorted and percent encoded`() {
        let q = VolcengineArkSigner.canonicalQueryString([("b", "2"), ("a", "1 2")])
        #expect(q == "a=1%202&b=2")
    }
}
