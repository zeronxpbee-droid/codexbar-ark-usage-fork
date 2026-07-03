import CodexBarCore
import Foundation
import Testing
@testable import CodexBar

/// S15 (M2, Option A) tests for Ark popover metrics.
///
/// Verifies the four-window data flow:
///   - `detailText` carries the complete display string (used / quota / remaining)
///     from `RateWindow.resetDescription` — opaque, never parsed.
///   - `resetText` is generated ONLY from `resetsAt`; never falls back to
///     `resetDescription` (which would render quota as "Resets …").
///   - `percent` shows used% or remaining% per `usageBarsShowUsed`.
///   - Missing windows are omitted (not rendered as 0%).
///   - Monthly `usageKnown = false` shows "Unavailable".
struct ArkPopoverMetricsTests {
    // MARK: - Helpers

    /// Fixed epoch so resetText assertions are deterministic.
    private static let now = Date(timeIntervalSince1970: 1_742_771_200)
    private static let resetDate = now.addingTimeInterval(3600)

    private static var metadata: ProviderMetadata {
        // Registered by ArkProviderDescriptor (M1, S3).
        try! #require(ProviderDefaults.metadata[.ark])
    }

    /// Build a `RateWindow` with the Ark complete display string in
    /// `resetDescription`, matching the format produced by
    /// `ArkUsageSnapshot.rateWindow(from:)`.
    private static func arkWindow(
        usedPercent: Double = 20,
        resetsAt: Date? = resetDate,
        resetDescription: String? = "100 / 500 AFP · 400 remaining") -> RateWindow
    {
        RateWindow(
            usedPercent: usedPercent,
            windowMinutes: nil,
            resetsAt: resetsAt,
            resetDescription: resetDescription)
    }

    private static func makeIdentity() -> ProviderIdentitySnapshot {
        ProviderIdentitySnapshot(
            providerID: .ark,
            accountEmail: nil,
            accountOrganization: nil,
            loginMethod: nil)
    }

    private static func makeModel(
        snapshot: UsageSnapshot?,
        usageBarsShowUsed: Bool = true,
        now: Date = now) -> UsageMenuCardView.Model
    {
        UsageMenuCardView.Model.make(.init(
            provider: .ark,
            metadata: metadata,
            snapshot: snapshot,
            credits: nil,
            creditsError: nil,
            dashboard: nil,
            dashboardError: nil,
            tokenSnapshot: nil,
            tokenError: nil,
            account: AccountInfo(email: nil, plan: nil),
            isRefreshing: false,
            lastError: nil,
            usageBarsShowUsed: usageBarsShowUsed,
            resetTimeDisplayStyle: .countdown,
            tokenCostUsageEnabled: false,
            showOptionalCreditsAndExtraUsage: true,
            hidePersonalInfo: false,
            now: now))
    }

    // MARK: - Four windows complete

    @Test
    func fourWindowsCompleteShowsAllValues() throws {
        let monthly = NamedRateWindow(
            id: "ark-afp-monthly",
            title: "Monthly",
            window: arkWindow(usedPercent: 10),
            usageKnown: true)
        let snapshot = UsageSnapshot(
            primary: arkWindow(usedPercent: 20),
            secondary: arkWindow(usedPercent: 30),
            tertiary: arkWindow(usedPercent: 40),
            extraRateWindows: [monthly],
            updatedAt: Self.now,
            identity: makeIdentity())

        let model = makeModel(snapshot: snapshot, usageBarsShowUsed: true)

        #expect(model.metrics.count == 4)
        #expect(model.metrics.map(\.title) == ["5h", "Daily", "Weekly", "Monthly"])

        // Every row carries the complete display string in detailText (FR4:
        // used/quota/remaining visible regardless of percent mode).
        for metric in model.metrics {
            #expect(metric.detailText == "100 / 500 AFP · 400 remaining")
        }

        // used% per usageBarsShowUsed = true
        #expect(model.metrics[0].percent == 20)
        #expect(model.metrics[1].percent == 30)
        #expect(model.metrics[2].percent == 40)
        #expect(model.metrics[3].percent == 10)

        // resetText generated from resetsAt (countdown style)
        for metric in model.metrics {
            #expect(metric.resetText != nil)
            #expect(metric.resetText?.hasPrefix("Resets") == true)
        }
    }

    // MARK: - usageBarsShowUsed = false (remaining %)

    @Test
    func usageBarsShowRemainingStillShowsCompleteDetail() throws {
        let snapshot = UsageSnapshot(
            primary: arkWindow(usedPercent: 20),
            secondary: nil,
            tertiary: nil,
            updatedAt: Self.now,
            identity: makeIdentity())

        let model = makeModel(snapshot: snapshot, usageBarsShowUsed: false)

        #expect(model.metrics.count == 1)
        // remaining% = 100 - 20 = 80
        #expect(model.metrics[0].percent == 80)
        // detailText still carries the complete display string (used+quota+remaining)
        #expect(model.metrics[0].detailText == "100 / 500 AFP · 400 remaining")
    }

    // MARK: - resetsAt nil → resetText nil (no fallback)

    @Test
    func resetsAtNilOmitsResetTextNoFallback() throws {
        let window = arkWindow(usedPercent: 20, resetsAt: nil)
        let snapshot = UsageSnapshot(
            primary: window,
            secondary: nil,
            tertiary: nil,
            updatedAt: Self.now,
            identity: makeIdentity())

        let model = makeModel(snapshot: snapshot, usageBarsShowUsed: true)

        #expect(model.metrics.count == 1)
        // resetText MUST be nil — never falls back to resetDescription.
        // This is the key invariant: UsageFormatter.resetLine would otherwise
        // render "Resets 100 / 500 AFP · 400 remaining" (lines 150-159).
        #expect(model.metrics[0].resetText == nil)
        // detailText still carries the complete display string.
        #expect(model.metrics[0].detailText == "100 / 500 AFP · 400 remaining")
    }

    // MARK: - Missing windows omitted

    @Test
    func missingWindowsOmittedNotRenderedAsZero() throws {
        // Only primary present; secondary/tertiary/monthly all nil.
        let snapshot = UsageSnapshot(
            primary: arkWindow(usedPercent: 20),
            secondary: nil,
            tertiary: nil,
            updatedAt: Self.now,
            identity: makeIdentity())

        let model = makeModel(snapshot: snapshot, usageBarsShowUsed: true)

        #expect(model.metrics.count == 1)
        #expect(model.metrics[0].title == "5h")
    }

    @Test
    func onlyPrimaryAndTertiary() throws {
        // Secondary missing — primary and tertiary still render.
        let snapshot = UsageSnapshot(
            primary: arkWindow(usedPercent: 20),
            secondary: nil,
            tertiary: arkWindow(usedPercent: 40),
            updatedAt: Self.now,
            identity: makeIdentity())

        let model = makeModel(snapshot: snapshot, usageBarsShowUsed: true)

        #expect(model.metrics.count == 2)
        #expect(model.metrics.map(\.title) == ["5h", "Weekly"])
    }

    // MARK: - Monthly usageKnown = false

    @Test
    func monthlyUsageUnknownShowsUnavailable() throws {
        let monthly = NamedRateWindow(
            id: "ark-afp-monthly",
            title: "Monthly",
            window: arkWindow(usedPercent: 0),
            usageKnown: false)
        let snapshot = UsageSnapshot(
            primary: arkWindow(usedPercent: 20),
            secondary: nil,
            tertiary: nil,
            extraRateWindows: [monthly],
            updatedAt: Self.now,
            identity: makeIdentity())

        let model = makeModel(snapshot: snapshot, usageBarsShowUsed: true)

        #expect(model.metrics.count == 2)
        let monthlyMetric = model.metrics[1]
        #expect(monthlyMetric.title == "Monthly")
        #expect(monthlyMetric.statusText == "Unavailable")
        #expect(monthlyMetric.resetText == nil)
        // detailText nil when usageKnown = false (no quota to show).
        #expect(monthlyMetric.detailText == nil)
    }

    // MARK: - No snapshot

    @Test
    func noSnapshotReturnsEmptyMetrics() throws {
        let model = makeModel(snapshot: nil, usageBarsShowUsed: true)
        #expect(model.metrics.isEmpty)
    }

    // MARK: - resetDescription nil but resetsAt present

    @Test
    func resetDescriptionNilStillShowsReset() throws {
        // Window with no resetDescription (quota values missing from API).
        let window = RateWindow(
            usedPercent: 20,
            windowMinutes: nil,
            resetsAt: Self.resetDate,
            resetDescription: nil)
        let snapshot = UsageSnapshot(
            primary: window,
            secondary: nil,
            tertiary: nil,
            updatedAt: Self.now,
            identity: makeIdentity())

        let model = makeModel(snapshot: snapshot, usageBarsShowUsed: true)

        #expect(model.metrics.count == 1)
        // resetText still generated from resetsAt.
        #expect(model.metrics[0].resetText != nil)
        // detailText is nil (no resetDescription to display).
        #expect(model.metrics[0].detailText == nil)
    }

    // MARK: - Absolute reset style

    @Test
    func absoluteResetStyleShowsDate() throws {
        let snapshot = UsageSnapshot(
            primary: arkWindow(usedPercent: 20),
            secondary: nil,
            tertiary: nil,
            updatedAt: Self.now,
            identity: makeIdentity())

        let model = UsageMenuCardView.Model.make(.init(
            provider: .ark,
            metadata: metadata,
            snapshot: snapshot,
            credits: nil,
            creditsError: nil,
            dashboard: nil,
            dashboardError: nil,
            tokenSnapshot: nil,
            tokenError: nil,
            account: AccountInfo(email: nil, plan: nil),
            isRefreshing: false,
            lastError: nil,
            usageBarsShowUsed: true,
            resetTimeDisplayStyle: .absolute,
            tokenCostUsageEnabled: false,
            showOptionalCreditsAndExtraUsage: true,
            hidePersonalInfo: false,
            now: Self.now))

        #expect(model.metrics.count == 1)
        // Absolute style produces "Resets <date>".
        #expect(model.metrics[0].resetText?.hasPrefix("Resets") == true)
        // detailText unaffected by reset style.
        #expect(model.metrics[0].detailText == "100 / 500 AFP · 400 remaining")
    }
}
