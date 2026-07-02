import CodexBarCore
import Foundation
import Testing
@testable import CodexBar

/// S9: the Ark automatic menu-bar window resolver selects the highest used
/// percentage among the four stable AFP lanes (5h primary, Daily secondary,
/// Weekly tertiary, Monthly extra), falling back to 5h then Daily when no
/// known-usage window exists.
struct ArkMenuBarMetricWindowResolverTests {
    private let monthlyID = "ark-afp-monthly"

    private func arkSnapshot(
        fiveHour: Double?,
        daily: Double?,
        weekly: Double?,
        monthly: Double?) -> UsageSnapshot
    {
        func lane(_ percent: Double?) -> RateWindow? {
            percent.map { RateWindow(usedPercent: $0, windowMinutes: nil, resetsAt: nil, resetDescription: nil) }
        }
        let extra: [NamedRateWindow]? = monthly.map {
            [NamedRateWindow(
                id: monthlyID,
                title: "Monthly",
                window: RateWindow(usedPercent: $0, windowMinutes: nil, resetsAt: nil, resetDescription: nil))]
        }
        return UsageSnapshot(
            primary: lane(fiveHour),
            secondary: lane(daily),
            tertiary: lane(weekly),
            extraRateWindows: extra,
            updatedAt: Date())
    }

    @Test
    func `automatic ark metric selects the highest-risk window across all four lanes`() {
        let snapshot = arkSnapshot(fiveHour: 10, daily: 20, weekly: 30, monthly: 95)

        let window = MenuBarMetricWindowResolver.rateWindow(
            preference: .automatic,
            provider: .ark,
            snapshot: snapshot,
            supportsAverage: false)

        // Monthly (95%) is the most constrained even though it lives in extraRateWindows.
        #expect(window?.usedPercent == 95)
    }

    @Test
    func `automatic ark metric picks the weekly lane when it is most constrained`() {
        let snapshot = arkSnapshot(fiveHour: 12, daily: 44, weekly: 88, monthly: 5)

        let window = MenuBarMetricWindowResolver.rateWindow(
            preference: .automatic,
            provider: .ark,
            snapshot: snapshot,
            supportsAverage: false)

        #expect(window?.usedPercent == 88)
    }

    @Test
    func `automatic ark metric falls back to 5h when only the primary lane is known`() {
        let snapshot = arkSnapshot(fiveHour: 37, daily: nil, weekly: nil, monthly: nil)

        let window = MenuBarMetricWindowResolver.rateWindow(
            preference: .automatic,
            provider: .ark,
            snapshot: snapshot,
            supportsAverage: false)

        #expect(window?.usedPercent == 37)
    }

    @Test
    func `automatic ark metric falls back to Daily when 5h is absent`() {
        let snapshot = arkSnapshot(fiveHour: nil, daily: 41, weekly: nil, monthly: nil)

        let window = MenuBarMetricWindowResolver.rateWindow(
            preference: .automatic,
            provider: .ark,
            snapshot: snapshot,
            supportsAverage: false)

        #expect(window?.usedPercent == 41)
    }

    @Test
    func `automatic ark metric returns nil when no window is known`() {
        let snapshot = UsageSnapshot(primary: nil, secondary: nil, updatedAt: Date())

        let window = MenuBarMetricWindowResolver.rateWindow(
            preference: .automatic,
            provider: .ark,
            snapshot: snapshot,
            supportsAverage: false)

        #expect(window == nil)
    }

    @Test
    func `automatic ark metric ignores a monthly window whose usage is unknown`() {
        // A monthly extra window flagged usageKnown == false must not win selection.
        let snapshot = UsageSnapshot(
            primary: RateWindow(usedPercent: 15, windowMinutes: nil, resetsAt: nil, resetDescription: nil),
            secondary: nil,
            extraRateWindows: [
                NamedRateWindow(
                    id: monthlyID,
                    title: "Monthly",
                    window: RateWindow(usedPercent: 0, windowMinutes: nil, resetsAt: nil, resetDescription: nil),
                    usageKnown: false),
            ],
            updatedAt: Date())

        let window = MenuBarMetricWindowResolver.rateWindow(
            preference: .automatic,
            provider: .ark,
            snapshot: snapshot,
            supportsAverage: false)

        #expect(window?.usedPercent == 15)
    }
}
