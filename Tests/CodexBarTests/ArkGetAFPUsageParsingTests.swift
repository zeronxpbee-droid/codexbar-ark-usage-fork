import Foundation
import Testing
@testable import CodexBarCore

/// Parsing of the Volcengine Ark `GetAFPUsage` response and its normalization
/// into CodexBar's `UsageSnapshot`. All fixtures are synthetic; no real network
/// or credentials are involved.
struct ArkGetAFPUsageParsingTests {
    // MARK: - Parser

    @Test
    func `parses all four windows nested under Result`() throws {
        let json = """
        {
          "ResponseMetadata": { "RequestId": "REDACTED-DO-NOT-ASSERT" },
          "Result": {
            "AFPFiveHour": { "Quota": 100, "Used": 25, "SubscribeTime": 1700000000000, "ResetTime": 1700018000000 },
            "AFPDaily":    { "Quota": 200, "Used": 40, "SubscribeTime": 1700000000000, "ResetTime": 1700086400000 },
            "AFPWeekly":   { "Quota": 700, "Used": 350, "SubscribeTime": 1700000000000, "ResetTime": 1700604800000 },
            "AFPMonthly":  { "Quota": 3000, "Used": 300, "SubscribeTime": 1700000000000, "ResetTime": 1702592000000 }
          }
        }
        """
        let response = try GetAFPUsageParser.parse(Data(json.utf8))

        #expect(response.windows.count == 4)
        #expect(response.fiveHour?.usedPercent == 25)
        #expect(response.daily?.usedPercent == 20)
        #expect(response.weekly?.usedPercent == 50)
        #expect(response.monthly?.usedPercent == 10)
        #expect(response.fiveHour?.remaining == 75)
        // Epoch-ms reset converts to a Date.
        #expect(response.fiveHour?.resetDate == Date(timeIntervalSince1970: 1_700_018_000))
    }

    @Test
    func `parses windows present at the top level`() throws {
        let json = """
        { "AFPFiveHour": { "Quota": 10, "Used": 3, "SubscribeTime": 1, "ResetTime": 2 } }
        """
        let response = try GetAFPUsageParser.parse(Data(json.utf8))
        #expect(response.windows.count == 1)
        #expect(response.daily == nil)
        #expect(response.fiveHour?.usedPercent == 30)
    }

    @Test
    func `throws noWindows when the payload has none of the expected windows`() {
        let json = """
        { "Result": { "SomethingElse": {} } }
        """
        #expect(throws: GetAFPUsageParser.ParseError.noWindows) {
            _ = try GetAFPUsageParser.parse(Data(json.utf8))
        }
    }

    @Test
    func `throws invalidJSON on a non-object body`() {
        #expect(throws: GetAFPUsageParser.ParseError.invalidJSON) {
            _ = try GetAFPUsageParser.parse(Data("not json".utf8))
        }
    }

    @Test
    func `window with non-positive quota reports unknown usage rather than zero`() throws {
        let json = """
        { "AFPFiveHour": { "Quota": 0, "Used": 0, "SubscribeTime": 1, "ResetTime": 2 } }
        """
        let response = try GetAFPUsageParser.parse(Data(json.utf8))
        // The window is present (so parsing succeeds) but usage is unknown.
        #expect(response.fiveHour != nil)
        #expect(response.fiveHour?.usedPercent == nil)
    }

    // MARK: - AFP -> UsageSnapshot mapping (方案 B semantics)

    private func window(quota: Double, used: Double, reset: Int64) -> AFPWindow {
        AFPWindow(quota: quota, used: used, subscribeTimeMillis: 0, resetTimeMillis: reset)
    }

    @Test
    func `maps 5h to primary, Daily to secondary, Weekly to tertiary, Monthly to extra`() {
        let updatedAt = Date(timeIntervalSince1970: 1_782_950_400)
        let snapshot = ArkUsageSnapshot(
            fiveHour: window(quota: 100, used: 25, reset: 1_700_018_000_000),
            daily: window(quota: 200, used: 40, reset: 1_700_086_400_000),
            weekly: window(quota: 700, used: 350, reset: 1_700_604_800_000),
            monthly: window(quota: 3000, used: 300, reset: 1_702_592_000_000),
            updatedAt: updatedAt)
            .toUsageSnapshot()

        #expect(snapshot.primary?.usedPercent == 25)
        #expect(snapshot.secondary?.usedPercent == 20)
        #expect(snapshot.tertiary?.usedPercent == 50)
        #expect(snapshot.updatedAt == updatedAt)
        #expect(snapshot.identity?.providerID == .ark)

        let monthly = snapshot.extraRateWindows?.first { $0.id == "ark-afp-monthly" }
        #expect(monthly != nil)
        #expect(monthly?.title == "Monthly")
        #expect(monthly?.usageKnown == true)
        #expect(monthly?.window.usedPercent == 10)
    }

    @Test
    func `omits windows whose usage is unknown so nothing renders as zero`() {
        let snapshot = ArkUsageSnapshot(
            fiveHour: window(quota: 0, used: 0, reset: 1),
            daily: nil,
            weekly: nil,
            monthly: nil,
            updatedAt: Date())
            .toUsageSnapshot()

        #expect(snapshot.primary == nil)
        #expect(snapshot.secondary == nil)
        #expect(snapshot.tertiary == nil)
        #expect(snapshot.extraRateWindows == nil || snapshot.extraRateWindows?.isEmpty == true)
    }

    @Test
    func `reset description carries a used-over-quota summary`() {
        let snapshot = ArkUsageSnapshot(
            fiveHour: window(quota: 100, used: 25, reset: 1),
            daily: nil,
            weekly: nil,
            monthly: nil,
            updatedAt: Date())
            .toUsageSnapshot()

        #expect(snapshot.primary?.resetDescription == "25 / 100 AFP · 75 remaining")
    }
}
