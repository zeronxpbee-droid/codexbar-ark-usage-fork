import Foundation
import XCTest
@testable import ArkProbeKit

/// Tests for the safe non-2xx error diagnostic path. All fixtures are entirely
/// fictional. The central guarantee under test: the sanitized diagnostic
/// exposes only the HTTP status, body byte count, and the machine-readable
/// error `Code` — never the `Message`, `RequestId`, AK/SK, Authorization, or any
/// account/resource/tenant identifier.
///
/// Entry 012 hardening: `Error.Code` is treated as UNTRUSTED input. It is
/// accepted only if it matches `[A-Za-z0-9][A-Za-z0-9._-]{0,127}`; otherwise the
/// extractor returns nil and the diagnostic renders `errorCode: <unavailable>`.
/// The public renderer re-validates its argument, so passing a hostile value
/// directly to `renderErrorDiagnostic` is also neutralized. Tests assert the
/// EXACT output line count and field set, not just selected substrings.
final class ArkErrorResponseTests: XCTestCase {
    // Fictional standard Volcengine error envelope.
    private let standardEnvelope = Data("""
    {
      "ResponseMetadata": {
        "RequestId": "FAKE-REQ-ID-DO-NOT-LEAK-0001",
        "Action": "GetAFPUsage",
        "Version": "2024-01-01",
        "Service": "ark",
        "Region": "cn-beijing",
        "Error": {
          "CodeN": 100004,
          "Code": "SignatureDoesNotMatch",
          "Message": "The request signature we calculated does not match; secret leak canary 9F3A."
        }
      }
    }
    """.utf8)

    // MARK: - Extraction of a well-formed code

    func test_extractsPreferredResponseMetadataErrorCode() {
        let code = ArkErrorResponse.extractErrorCode(from: standardEnvelope)
        XCTAssertEqual(code, "SignatureDoesNotMatch")
    }

    func test_extractsTopLevelErrorCodeFallback() {
        let data = Data("""
        { "Error": { "Code": "AccessDenied", "Message": "nope, secret canary 7B2C" } }
        """.utf8)
        XCTAssertEqual(ArkErrorResponse.extractErrorCode(from: data), "AccessDenied")
    }

    func test_acceptsGrammarPunctuationAndBoundaryLength() {
        // Dots, underscores, hyphens allowed after the first alphanumeric char.
        XCTAssertEqual(
            ArkErrorResponse.extractErrorCode(
                from: Data("{ \"Error\": { \"Code\": \"Err.Code_v2-1\" } }".utf8)),
            "Err.Code_v2-1")

        // Exactly 128 chars (1 leading + 127 trailing) is the max accepted length.
        let maxCode = "A" + String(repeating: "b", count: 127)
        XCTAssertEqual(maxCode.count, 128)
        XCTAssertEqual(
            ArkErrorResponse.extractErrorCode(
                from: Data("{ \"Error\": { \"Code\": \"\(maxCode)\" } }".utf8)),
            maxCode)
    }

    func test_returnsNilWhenNoErrorCodePresent() {
        XCTAssertNil(ArkErrorResponse.extractErrorCode(from: Data("{}".utf8)))
        XCTAssertNil(ArkErrorResponse.extractErrorCode(from: Data("not json".utf8)))
        // Error object present but no Code key.
        XCTAssertNil(ArkErrorResponse.extractErrorCode(
            from: Data("{ \"ResponseMetadata\": { \"Error\": { \"Message\": \"x\" } } }".utf8)))
    }

    // MARK: - Untrusted input: hostile Error.Code values must be rejected

    func test_rejectsWhitespaceOnlyCode() {
        // Whitespace-only fails the grammar (first char is not alphanumeric).
        XCTAssertNil(ArkErrorResponse.extractErrorCode(
            from: Data("{ \"ResponseMetadata\": { \"Error\": { \"Code\": \"  \" } } }".utf8)))
    }

    func test_rejectsCodeWithSurroundingAndInnerWhitespace() {
        // A value that only conforms after trimming must NOT be accepted.
        XCTAssertNil(ArkErrorResponse.extractErrorCode(
            from: Data("{ \"Error\": { \"Code\": \"  Signature  \" } }".utf8)))
        // Inner space is not part of the grammar.
        XCTAssertNil(ArkErrorResponse.extractErrorCode(
            from: Data("{ \"Error\": { \"Code\": \"Bad Code\" } }".utf8)))
    }

    func test_rejectsCodeWithEmbeddedNewline() {
        // Escaped newline inside the JSON string value.
        XCTAssertNil(ArkErrorResponse.extractErrorCode(
            from: Data("{ \"Error\": { \"Code\": \"Line1\\nLine2\" } }".utf8)))
        // Also reject the direct-string form (belt and suspenders).
        XCTAssertNil(ArkErrorResponse.validatedCode("Line1\nLine2"))
        XCTAssertNil(ArkErrorResponse.validatedCode("Injected\n  fakeField: leaked"))
    }

    func test_rejectsCodeWithControlCharacter() {
        // U+0007 (BEL) embedded in the code value.
        XCTAssertNil(ArkErrorResponse.extractErrorCode(
            from: Data("{ \"Error\": { \"Code\": \"Alert\\u0007Bell\" } }".utf8)))
        XCTAssertNil(ArkErrorResponse.validatedCode("Tab\tSeparated"))
        XCTAssertNil(ArkErrorResponse.validatedCode("Null\u{0000}Byte"))
    }

    func test_rejectsOverLongCode() {
        // 129 chars (one past the 128 max) must be rejected.
        let tooLong = "A" + String(repeating: "b", count: 128)
        XCTAssertEqual(tooLong.count, 129)
        XCTAssertNil(ArkErrorResponse.extractErrorCode(
            from: Data("{ \"Error\": { \"Code\": \"\(tooLong)\" } }".utf8)))
        XCTAssertNil(ArkErrorResponse.validatedCode(tooLong))
    }

    func test_rejectsCodeStartingWithPunctuation() {
        // First character must be alphanumeric; punctuation-led codes rejected.
        XCTAssertNil(ArkErrorResponse.validatedCode(".leading"))
        XCTAssertNil(ArkErrorResponse.validatedCode("-leading"))
        XCTAssertNil(ArkErrorResponse.validatedCode("_leading"))
    }

    // MARK: - Diagnostic output: exact line count and field set

    /// The diagnostic must contain EXACTLY four lines: the header plus the three
    /// permitted fields (httpStatus, bodyBytes, errorCode). No `note` line, and
    /// no other fields may ever appear.
    func test_diagnostic_hasExactLineCountAndFieldSet() {
        let code = ArkErrorResponse.extractErrorCode(from: standardEnvelope)
        let diagnostic = SanitizedUsageReport.renderErrorDiagnostic(
            httpStatus: 401,
            bodyByteCount: standardEnvelope.count,
            errorCode: code)

        let lines = diagnostic.components(separatedBy: "\n")
        XCTAssertEqual(lines.count, 4, "diagnostic must be header + exactly 3 fields")
        XCTAssertEqual(lines[0], "Non-2xx response (redacted diagnostic):")
        XCTAssertEqual(lines[1], "  httpStatus: 401")
        XCTAssertEqual(lines[2], "  bodyBytes: \(standardEnvelope.count)")
        XCTAssertEqual(lines[3], "  errorCode: SignatureDoesNotMatch")

        // Exact field-key set: precisely these three keys, nothing else.
        let fieldKeys = lines.dropFirst().map { line -> String in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return String(trimmed.prefix(while: { $0 != ":" }))
        }
        XCTAssertEqual(Set(fieldKeys), ["httpStatus", "bodyBytes", "errorCode"])
        XCTAssertEqual(fieldKeys.count, 3, "no duplicate or extra field lines")

        // The removed static note line must never reappear.
        XCTAssertFalse(diagnostic.contains("note:"))
        XCTAssertFalse(diagnostic.lowercased().contains("suppressed"))

        // Forbidden content must never appear.
        XCTAssertFalse(diagnostic.contains("FAKE-REQ-ID-DO-NOT-LEAK-0001"))
        XCTAssertFalse(diagnostic.contains("RequestId"))
        XCTAssertFalse(diagnostic.contains("does not match"))
        XCTAssertFalse(diagnostic.contains("Message"))
        XCTAssertFalse(diagnostic.contains("secret leak canary"))
        XCTAssertFalse(diagnostic.contains("9F3A"))
    }

    func test_diagnostic_unavailableWhenCodeMissing() {
        let body = Data("{ \"ResponseMetadata\": { \"RequestId\": \"FAKE-REQ-ID-0002\" } }".utf8)
        let code = ArkErrorResponse.extractErrorCode(from: body)
        let diagnostic = SanitizedUsageReport.renderErrorDiagnostic(
            httpStatus: 401,
            bodyByteCount: body.count,
            errorCode: code)

        let lines = diagnostic.components(separatedBy: "\n")
        XCTAssertEqual(lines.count, 4)
        XCTAssertEqual(lines[3], "  errorCode: <unavailable>")
        XCTAssertTrue(diagnostic.contains("httpStatus: 401"))
        // Even the RequestId in the body must not surface.
        XCTAssertFalse(diagnostic.contains("FAKE-REQ-ID-0002"))
        XCTAssertFalse(diagnostic.contains("RequestId"))
    }

    // MARK: - Renderer boundary: hostile value passed DIRECTLY to the renderer

    /// The renderer is `public`, so it must defend itself. Passing hostile,
    /// unvalidated strings straight into `renderErrorDiagnostic` must collapse to
    /// `<unavailable>` and must never expand the line count or leak the payload.
    func test_renderer_neutralizesHostileDirectInput() {
        let hostileValues = [
            "Injected\nfakeField: leaked-secret",   // newline injection
            "Alert\u{0007}Bell",                     // control character
            "  spaced value  ",                      // whitespace
            "Bad Code With Spaces",                  // inner whitespace
            "A" + String(repeating: "b", count: 200), // over-length
            "",                                       // empty
            ".startsWithDot",                         // bad leading char
        ]

        for hostile in hostileValues {
            let diagnostic = SanitizedUsageReport.renderErrorDiagnostic(
                httpStatus: 500,
                bodyByteCount: 123,
                errorCode: hostile)

            let lines = diagnostic.components(separatedBy: "\n")
            XCTAssertEqual(
                lines.count, 4,
                "hostile input must not change the line count: \(hostile.debugDescription)")
            XCTAssertEqual(
                lines[3], "  errorCode: <unavailable>",
                "hostile input must render <unavailable>: \(hostile.debugDescription)")

            // The hostile payload must not appear anywhere in the output.
            XCTAssertFalse(
                diagnostic.contains("leaked-secret"),
                "newline-injected payload leaked: \(hostile.debugDescription)")
            XCTAssertFalse(
                diagnostic.contains("fakeField"),
                "injected field leaked: \(hostile.debugDescription)")
        }
    }

    /// A well-formed code passed directly to the renderer is preserved verbatim.
    func test_renderer_preservesValidDirectInput() {
        let diagnostic = SanitizedUsageReport.renderErrorDiagnostic(
            httpStatus: 403,
            bodyByteCount: 42,
            errorCode: "AccessDenied")
        let lines = diagnostic.components(separatedBy: "\n")
        XCTAssertEqual(lines.count, 4)
        XCTAssertEqual(lines[3], "  errorCode: AccessDenied")
    }

    /// The extractor must not read the Message even when a caller mistakenly
    /// tries to render it — the returned value is exactly the Code, nothing else.
    func test_extractor_neverReturnsMessageOrIdentifiers() {
        let code = ArkErrorResponse.extractErrorCode(from: standardEnvelope) ?? ""
        XCTAssertFalse(code.contains("does not match"))
        XCTAssertFalse(code.contains("canary"))
        XCTAssertFalse(code.contains("FAKE-REQ-ID"))
        XCTAssertEqual(code, "SignatureDoesNotMatch")
    }
}
