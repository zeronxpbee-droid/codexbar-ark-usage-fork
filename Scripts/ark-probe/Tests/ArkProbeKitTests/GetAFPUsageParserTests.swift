import Foundation
import XCTest
@testable import ArkProbeKit

final class GetAFPUsageParserTests: XCTestCase {
    // Non-real fixture. Epoch ms values are arbitrary but valid.
    private func fixture(nested: Bool) -> Data {
        let windows = """
        "AFPFiveHour": { "Quota": 100, "Used": 25, "SubscribeTime": 1782950400000, "ResetTime": 1782968400000 },
        "AFPDaily":    { "Quota": 1000, "Used": 300, "SubscribeTime": 1782950400000, "ResetTime": 1783036800000 },
        "AFPWeekly":   { "Quota": 5000, "Used": 1200, "SubscribeTime": 1782950400000, "ResetTime": 1783555200000 },
        "AFPMonthly":  { "Quota": 20000, "Used": 4500.5, "SubscribeTime": 1782950400000, "ResetTime": 1785542400000 }
        """
        let json = nested
            ? "{ \"ResponseMetadata\": { \"RequestId\": \"redact-me\" }, \"Result\": { \(windows) } }"
            : "{ \(windows) }"
        return Data(json.utf8)
    }

    func test_parse_topLevelWindows() throws {
        let response = try GetAFPUsageParser.parse(fixture(nested: false))
        XCTAssertEqual(response.windows.count, 4)
        XCTAssertEqual(response.fiveHour?.quota, 100)
        XCTAssertEqual(response.fiveHour?.used, 25)
        XCTAssertEqual(response.fiveHour?.remaining, 75)
        XCTAssertEqual(response.monthly?.used, 4500.5)
        XCTAssertEqual(response.monthly?.remaining, 15499.5)
    }

    func test_parse_nestedResultWindows() throws {
        let response = try GetAFPUsageParser.parse(fixture(nested: true))
        XCTAssertEqual(response.windows.count, 4)
        XCTAssertEqual(response.weekly?.quota, 5000)
    }

    func test_resetDate_convertsEpochMillis() throws {
        let response = try GetAFPUsageParser.parse(fixture(nested: false))
        let expected = Date(timeIntervalSince1970: 1_782_968_400) // 1782968400000 ms
        XCTAssertEqual(response.fiveHour?.resetDate, expected)
    }

    func test_parse_missingFieldsTolerated() throws {
        let json = "{ \"AFPDaily\": { \"Quota\": 500 } }"
        let response = try GetAFPUsageParser.parse(Data(json.utf8))
        XCTAssertEqual(response.windows.count, 1)
        XCTAssertEqual(response.daily?.quota, 500)
        XCTAssertNil(response.daily?.used)
        XCTAssertNil(response.daily?.remaining)   // remaining needs both quota and used
        XCTAssertNil(response.daily?.resetDate)   // unknown reset
    }

    func test_parse_emptyBodyThrowsNoWindows() {
        XCTAssertThrowsError(try GetAFPUsageParser.parse(Data("{}".utf8))) { error in
            XCTAssertEqual(error as? GetAFPUsageParser.ParseError, .noWindows)
        }
    }

    func test_parse_invalidJSONThrows() {
        XCTAssertThrowsError(try GetAFPUsageParser.parse(Data("not json".utf8))) { error in
            XCTAssertEqual(error as? GetAFPUsageParser.ParseError, .invalidJSON)
        }
    }
}

final class SanitizedUsageReportTests: XCTestCase {
    func test_render_containsNumericFieldsOnly_noIdentifiers() throws {
        let json = """
        {
          "ResponseMetadata": { "RequestId": "SECRET-REQUEST-ID", "Account": "2100000000" },
          "Result": {
            "AFPFiveHour": { "Quota": 100, "Used": 25, "SubscribeTime": 1782950400000, "ResetTime": 1782968400000 }
          }
        }
        """
        let response = try GetAFPUsageParser.parse(Data(json.utf8))
        let report = SanitizedUsageReport.render(response)

        // Numeric fields present.
        XCTAssertTrue(report.contains("used=25"))
        XCTAssertTrue(report.contains("quota=100"))
        XCTAssertTrue(report.contains("remaining=75"))
        XCTAssertTrue(report.contains("5h"))

        // Identifiers from the envelope must never appear.
        XCTAssertFalse(report.contains("SECRET-REQUEST-ID"))
        XCTAssertFalse(report.contains("2100000000"))
        XCTAssertFalse(report.contains("RequestId"))
        XCTAssertFalse(report.contains("Account"))
    }

    func test_renderSignedRequestShape_doesNotPrintSignature() {
        let shape = SanitizedUsageReport.renderSignedRequestShape(
            host: "ark.cn-beijing.volces.com",
            method: "POST",
            path: "/",
            query: [("Action", "GetAFPUsage"), ("Version", "2024-01-01")],
            signedHeaders: "content-type;host;x-content-sha256;x-date",
            bodyByteCount: 2)
        XCTAssertTrue(shape.contains("redacted"))
        XCTAssertFalse(shape.lowercased().contains("signature="))
    }
}
