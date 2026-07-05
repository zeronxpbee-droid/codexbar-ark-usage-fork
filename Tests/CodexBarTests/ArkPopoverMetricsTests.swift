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
///   - Refresh errors surface via `subtitleStyle == .error` without dropping
///     cached metrics.
///   - Stale snapshots still render their cached rows.
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

    /// Build a `UsageSnapshot` with Ark identity, using the static `now` as
    /// `updatedAt` so tests do not need `Self.now` at call sites.
    private static func makeSnapshot(
        primary: RateWindow? = nil,
        secondary: RateWindow? = nil,
        tertiary: RateWindow? = nil,
        extraRateWindows: [NamedRateWindow]? = nil,
        updatedAt: Date = now) -> UsageSnapshot
    {
        UsageSnapshot(
            primary: primary,
            secondary: secondary,
            tertiary: tertiary,
            extraRateWindows: extraRateWindows,
            updatedAt: updatedAt,
            identity: Self.makeIdentity())
    }

    private static func makeModel(
        snapshot: UsageSnapshot?,
        usageBarsShowUsed: Bool = true,
        resetTimeDisplayStyle: ResetTimeDisplayStyle = .countdown,
        lastError: String? = nil,
        now: Date = now) -> UsageMenuCardView.Model
    {
        UsageMenuCardView.Model.make(.init(
            provider: .ark,
            metadata: Self.metadata,
            snapshot: snapshot,
            credits: nil,
            creditsError: nil,
            dashboard: nil,
            dashboardError: nil,
            tokenSnapshot: nil,
            tokenError: nil,
            account: AccountInfo(email: nil, plan: nil),
            isRefreshing: false,
            lastError: lastError,
            usageBarsShowUsed: usageBarsShowUsed,
            resetTimeDisplayStyle: resetTimeDisplayStyle,
            tokenCostUsageEnabled: false,
            showOptionalCreditsAndExtraUsage: true,
            hidePersonalInfo: false,
            now: now))
    }

    // MARK: - Four windows complete

    @Test
    func fourWindowsCompleteShowsAllValues() {
        let monthly = NamedRateWindow(
            id: "ark-afp-monthly",
            title: "Monthly",
            window: arkWindow(usedPercent: 10),
            usageKnown: true)
        let snapshot = makeSnapshot(
            primary: arkWindow(usedPercent: 20),
            secondary: arkWindow(usedPercent: 30),
            tertiary: arkWindow(usedPercent: 40),
            extraRateWindows: [monthly])

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
    func usageBarsShowRemainingStillShowsCompleteDetail() {
        let snapshot = makeSnapshot(primary: arkWindow(usedPercent: 20))

        let model = makeModel(snapshot: snapshot, usageBarsShowUsed: false)

        #expect(model.metrics.count == 1)
        // remaining% = 100 - 20 = 80
        #expect(model.metrics[0].percent == 80)
        // detailText still carries the complete display string (used+quota+remaining)
        #expect(model.metrics[0].detailText == "100 / 500 AFP · 400 remaining")
    }

    // MARK: - resetsAt nil → resetText nil (no fallback)

    @Test
    func resetsAtNilOmitsResetTextNoFallback() {
        let window = arkWindow(usedPercent: 20, resetsAt: nil)
        let snapshot = makeSnapshot(primary: window)

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
    func missingWindowsOmittedNotRenderedAsZero() {
        // Only primary present; secondary/tertiary/monthly all nil.
        let snapshot = makeSnapshot(primary: arkWindow(usedPercent: 20))

        let model = makeModel(snapshot: snapshot, usageBarsShowUsed: true)

        #expect(model.metrics.count == 1)
        #expect(model.metrics[0].title == "5h")
    }

    @Test
    func onlyPrimaryAndTertiary() {
        // Secondary missing — primary and tertiary still render.
        let snapshot = makeSnapshot(
            primary: arkWindow(usedPercent: 20),
            tertiary: arkWindow(usedPercent: 40))

        let model = makeModel(snapshot: snapshot, usageBarsShowUsed: true)

        #expect(model.metrics.count == 2)
        #expect(model.metrics.map(\.title) == ["5h", "Weekly"])
    }

    // MARK: - Monthly usageKnown = false

    @Test
    func monthlyUsageUnknownShowsUnavailable() {
        let monthly = NamedRateWindow(
            id: "ark-afp-monthly",
            title: "Monthly",
            window: arkWindow(usedPercent: 0),
            usageKnown: false)
        let snapshot = makeSnapshot(
            primary: arkWindow(usedPercent: 20),
            extraRateWindows: [monthly])

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
    func noSnapshotReturnsEmptyMetrics() {
        let model = makeModel(snapshot: nil, usageBarsShowUsed: true)
        #expect(model.metrics.isEmpty)
    }

    // MARK: - resetDescription nil but resetsAt present

    @Test
    func resetDescriptionNilStillShowsReset() {
        // Window with no resetDescription (quota values missing from API).
        let window = arkWindow(usedPercent: 20, resetDescription: nil)
        let snapshot = makeSnapshot(primary: window)

        let model = makeModel(snapshot: snapshot, usageBarsShowUsed: true)

        #expect(model.metrics.count == 1)
        // resetText still generated from resetsAt.
        #expect(model.metrics[0].resetText != nil)
        // detailText is nil (no resetDescription to display).
        #expect(model.metrics[0].detailText == nil)
    }

    // MARK: - Absolute reset style

    @Test
    func absoluteResetStyleShowsDate() {
        let snapshot = makeSnapshot(primary: arkWindow(usedPercent: 20))

        let model = makeModel(
            snapshot: snapshot,
            usageBarsShowUsed: true,
            resetTimeDisplayStyle: .absolute)

        #expect(model.metrics.count == 1)
        // Absolute style produces "Resets <date>".
        #expect(model.metrics[0].resetText?.hasPrefix("Resets") == true)
        // detailText unaffected by reset style.
        #expect(model.metrics[0].detailText == "100 / 500 AFP · 400 remaining")
    }

    // MARK: - Refresh error with cached snapshot

    @Test
    func refreshErrorShowsErrorStyleButMetricsRender() {
        // A cached snapshot exists from a previous successful fetch, but the
        // latest refresh failed. The popover must still show the cached rows
        // while surfacing the error via subtitleStyle.
        let snapshot = makeSnapshot(primary: arkWindow(usedPercent: 20))

        let model = makeModel(
            snapshot: snapshot,
            lastError: "Ark API error (HTTP 500)")

        // Metrics still render from the cached snapshot.
        #expect(model.metrics.count == 1)
        #expect(model.metrics[0].detailText == "100 / 500 AFP · 400 remaining")
        // Subtitle reflects the error.
        #expect(model.subtitleStyle == .error)
    }

    // MARK: - Stale snapshot still renders

    @Test
    func staleSnapshotStillRendersMetrics() {
        // Snapshot is 2 hours old but still has valid data. The popover must
        // render the cached rows and surface the stale age via the subtitle.
        let staleUpdated = Self.now.addingTimeInterval(-7200)
        let snapshot = makeSnapshot(
            primary: arkWindow(usedPercent: 20),
            updatedAt: staleUpdated)

        let model = makeModel(snapshot: snapshot, usageBarsShowUsed: true)

        // Cached metrics still render.
        #expect(model.metrics.count == 1)
        #expect(model.metrics[0].detailText == "100 / 500 AFP · 400 remaining")
        // Stale age is visibly identified via the "Updated …" subtitle.
        #expect(model.subtitleStyle == .info)
        #expect(model.subtitleText.hasPrefix("Updated"))
    }
}
