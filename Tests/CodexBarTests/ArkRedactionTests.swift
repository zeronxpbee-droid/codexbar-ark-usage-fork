import Foundation
import Testing
@testable import CodexBarCore

/// Redaction guarantees for Ark diagnostics. Error descriptions must never carry
/// credentials, Authorization/signature material, RequestId, account identifiers,
/// or raw server error bodies (docs/PRD.md §9, AGENTS.md §6). All inputs are FAKE.
struct ArkRedactionTests {
    private let fakeSecret = "FAKESECRET0000000000000000000000EXAMPLE"
    private let fakeAccessKeyID = "AKFAKE000000000000EXAMPLE"

    // MARK: - ArkUsageError descriptions

    @Test
    func `api error description carries only status and validated code`() {
        let description = ArkUsageError
            .apiError(statusCode: 403, errorCode: "SignatureDoesNotMatch")
            .errorDescription ?? ""

        #expect(description.contains("403"))
        #expect(description.contains("SignatureDoesNotMatch"))
        // Never the secret, never a raw message body.
        #expect(!description.contains(fakeSecret))
        #expect(!description.contains(fakeAccessKeyID))
    }

    @Test
    func `api error description omits code when none was validated`() {
        let description = ArkUsageError
            .apiError(statusCode: 500, errorCode: nil)
            .errorDescription ?? ""

        #expect(description.contains("500"))
        #expect(!description.contains(fakeSecret))
    }

    @Test
    func `no error description leaks credential material`() {
        let errors: [ArkUsageError] = [
            .missingCredentials,
            .networkError("URLError -1001"),
            .apiError(statusCode: 401, errorCode: "UnauthorizedOperation"),
            .emptyOrUnsupported,
            .parseFailed,
        ]
        for error in errors {
            let description = error.errorDescription ?? ""
            #expect(!description.contains(fakeSecret))
            #expect(!description.contains(fakeAccessKeyID))
        }
    }

    // MARK: - ArkErrorResponse extraction

    @Test
    func `error extraction returns only the machine code, never message or request id`() {
        let body = Data("""
        {
          "ResponseMetadata": {
            "RequestId": "202607020000-SENSITIVE-REQUEST-ID",
            "Error": {
              "Code": "SignatureDoesNotMatch",
              "Message": "The request signature we calculated does not match; ak=\(fakeAccessKeyID)"
            }
          }
        }
        """.utf8)

        let code = ArkErrorResponse.extractErrorCode(from: body)
        #expect(code == "SignatureDoesNotMatch")
        // The RequestId, Message text, and any embedded credential must not surface.
        #expect(code?.contains("REQUEST-ID") != true)
        #expect(code?.contains(fakeAccessKeyID) != true)
    }

    @Test
    func `error extraction rejects a malicious multi-line code`() {
        let body = Data("""
        { "Error": { "Code": "Bad\\nCode injected: \(fakeSecret)" } }
        """.utf8)
        // A value violating the strict single-line ASCII grammar yields nil,
        // so the secret can never ride along in the extracted code.
        #expect(ArkErrorResponse.extractErrorCode(from: body) == nil)
    }

    @Test
    func `error extraction returns nil for a non-json body`() {
        let body = Data("upstream proxy error: \(fakeSecret)".utf8)
        #expect(ArkErrorResponse.extractErrorCode(from: body) == nil)
    }
}
