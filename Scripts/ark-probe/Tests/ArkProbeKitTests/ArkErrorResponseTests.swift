import Foundation
import XCTest
@testable import ArkProbeKit

/// Tests for the safe non-2xx error diagnostic path. All fixtures are entirely
/// fictional. The central guarantee under test: the sanitized diagnostic
/// exposes only the HTTP status, body byte count, and the machine-readable
/// error `Code` — never the `Message`, `RequestId`, AK/SK, Authorization, or any
/// account/resource/tenant identifier.
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

    func test_returnsNilWhenNoErrorCodePresent() {
        XCTAssertNil(ArkErrorResponse.extractErrorCode(from: Data("{}".utf8)))
        XCTAssertNil(ArkErrorResponse.extractErrorCode(from: Data("not json".utf8)))
        // Error object present but no Code key.
        XCTAssertNil(ArkErrorResponse.extractErrorCode(
            from: Data("{ \"ResponseMetadata\": { \"Error\": { \"Message\": \"x\" } } }".utf8)))
        // Empty code string is treated as absent.
        XCTAssertNil(ArkErrorResponse.extractErrorCode(
            from: Data("{ \"ResponseMetadata\": { \"Error\": { \"Code\": \"  \" } } }".utf8)))
    }

    func test_diagnostic_containsOnlyAllowedFields() {
        let code = ArkErrorResponse.extractErrorCode(from: standardEnvelope)
        let diagnostic = SanitizedUsageReport.renderErrorDiagnostic(
            httpStatus: 401,
            bodyByteCount: standardEnvelope.count,
            errorCode: code)

        // Allowed fields present.
        XCTAssertTrue(diagnostic.contains("httpStatus: 401"))
        XCTAssertTrue(diagnostic.contains("bodyBytes: \(standardEnvelope.count)"))
        XCTAssertTrue(diagnostic.contains("errorCode: SignatureDoesNotMatch"))

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

        XCTAssertTrue(diagnostic.contains("errorCode: <unavailable>"))
        XCTAssertTrue(diagnostic.contains("httpStatus: 401"))
        // Even the RequestId in the body must not surface.
        XCTAssertFalse(diagnostic.contains("FAKE-REQ-ID-0002"))
        XCTAssertFalse(diagnostic.contains("RequestId"))
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
