import CodexBarCore
import Foundation
import Testing
@testable import CodexBar

/// S17 (M3) tests for `ArkWidgetSnapshotRows`.
///
/// Verifies the four-window widget row mapping:
///   - Stable ordering: 5h, Daily, Weekly, Monthly.
///   - Each known row carries `percentLeft` (remaining %), `resetAt` (real
///     reset date), and `detailText` (M2 opaque complete display string).
///   - Missing windows are omitted, not invented as zero.
///   - Monthly `usageKnown = false` keeps the row visible but with
///     `percentLeft`/`resetAt`/`detailText` all `nil`.
struct ArkWidgetSnapshotRowsTests {
    // MARK: - Helpers

    private let now = Date(timeIntervalSince1970: 1_742_771_200)
    private let resetDate = Date(timeIntervalSince1970: 1_742_771_200 + 3600)
    private let detailText = "100 / 500 AFP · 400 remaining"

    private func arkWindow(usedPercent: Double = 20) -> RateWindow {
        RateWindow(
            usedPercent: usedPercent,
            windowMinutes: nil,
            resetsAt: resetDate,
            resetDescription: detailText)
    }

    private func monthlyNamedWindow(usedPercent: Double = 10, usageKnown: Bool = true) -> NamedRateWindow {
        NamedRateWindow(
            id: "ark-afp-monthly",
            title: "Monthly",
            window: arkWindow(usedPercent: usedPercent),
            usageKnown: usageKnown)
    }

    // MARK: - Four windows complete

    @Test
    func fourWindowsCompleteProducesStableOrder() {
        let snapshot = UsageSnapshot(
            primary: arkWindow(usedPercent: 20),
            secondary: arkWindow(usedPercent: 30),
            tertiary: arkWindow(usedPercent: 40),
            extraRateWindows: [monthlyNamedWindow(usedPercent: 10)],
            updatedAt: now,
            identity: ProviderIdentitySnapshot(
                providerID: .ark,
                accountEmail: nil,
                accountOrganization: nil,
                loginMethod: nil))

        let rows = ArkWidgetSnapshotRows.rows(from: snapshot)

        #expect(rows.count == 4)
        #expect(rows.map(\.id) == ["ark-afp-5h", "ark-afp-daily", "ark-afp-weekly", "ark-afp-monthly"])
        #expect(rows.map(\.title) == ["5h", "Daily", "Weekly", "Monthly"])
    }

    @Test
    func fourWindowsCompleteCarriesAllS18Fields() {
        let snapshot = UsageSnapshot(
            primary: arkWindow(usedPercent: 20),
            secondary: arkWindow(usedPercent: 30),
            tertiary: arkWindow(usedPercent: 40),
            extraRateWindows: [monthlyNamedWindow(usedPercent: 10)],
            updatedAt: now,
            identity: ProviderIdentitySnapshot(
                providerID: .ark,
                accountEmail: nil,
                accountOrganization: nil,
                loginMethod: nil))

        let rows = ArkWidgetSnapshotRows.rows(from: snapshot)

        // remainingPercent = 100 - usedPercent for each window
        #expect(rows[0].percentLeft == 80)  // 100 - 20
        #expect(rows[1].percentLeft == 70)  // 100 - 30
        #expect(rows[2].percentLeft == 60)  // 100 - 40
        #expect(rows[3].percentLeft == 90)  // 100 - 10

        // Every known row carries the real reset date and M2 detail string.
        for row in rows {
            #expect(row.resetAt == resetDate)
            #expect(row.detailText == detailText)
        }
    }

    // MARK: - Missing windows omitted

    @Test
    func onlyPrimaryPresentOmitsMissingWindows() {
        let snapshot = UsageSnapshot(
            primary: arkWindow(usedPercent: 20),
            secondary: nil,
            tertiary: nil,
            extraRateWindows: nil,
            updatedAt: now,
            identity: ProviderIdentitySnapshot(
                providerID: .ark,
                accountEmail: nil,
                accountOrganization: nil,
                loginMethod: nil))

        let rows = ArkWidgetSnapshotRows.rows(from: snapshot)

        #expect(rows.count == 1)
        #expect(rows[0].id == "ark-afp-5h")
        #expect(rows[0].title == "5h")
        #expect(rows[0].percentLeft == 80)
        #expect(rows[0].resetAt == resetDate)
        #expect(rows[0].detailText == detailText)
    }

    @Test
    func primaryAndTertiaryOnlySkipsDailyAndMonthly() {
        let snapshot = UsageSnapshot(
            primary: arkWindow(usedPercent: 20),
            secondary: nil,
            tertiary: arkWindow(usedPercent: 40),
            extraRateWindows: nil,
            updatedAt: now,
            identity: ProviderIdentitySnapshot(
                providerID: .ark,
                accountEmail: nil,
                accountOrganization: nil,
                loginMethod: nil))

        let rows = ArkWidgetSnapshotRows.rows(from: snapshot)

        #expect(rows.count == 2)
        #expect(rows.map(\.id) == ["ark-afp-5h", "ark-afp-weekly"])
    }

    // MARK: - Monthly usageKnown = false

    @Test
    func monthlyUsageUnknownKeepsRowWithNilFields() {
        let snapshot = UsageSnapshot(
            primary: arkWindow(usedPercent: 20),
            secondary: nil,
            tertiary: nil,
            extraRateWindows: [monthlyNamedWindow(usedPercent: 0, usageKnown: false)],
            updatedAt: now,
            identity: ProviderIdentitySnapshot(
                providerID: .ark,
                accountEmail: nil,
                accountOrganization: nil,
                loginMethod: nil))

        let rows = ArkWidgetSnapshotRows.rows(from: snapshot)

        #expect(rows.count == 2)
        let monthlyRow = rows[1]
        #expect(monthlyRow.id == "ark-afp-monthly")
        #expect(monthlyRow.title == "Monthly")
        // usageKnown = false → all value fields nil, but row preserved.
        #expect(monthlyRow.percentLeft == nil)
        #expect(monthlyRow.resetAt == nil)
        #expect(monthlyRow.detailText == nil)
    }

    // MARK: - No windows

    @Test
    func noWindowsReturnsEmptyRows() {
        let snapshot = UsageSnapshot(
            primary: nil,
            secondary: nil,
            tertiary: nil,
            extraRateWindows: nil,
            updatedAt: now,
            identity: ProviderIdentitySnapshot(
                providerID: .ark,
                accountEmail: nil,
                accountOrganization: nil,
                loginMethod: nil))

        let rows = ArkWidgetSnapshotRows.rows(from: snapshot)

        #expect(rows.isEmpty)
    }

    // MARK: - resetsAt nil preserved

    @Test
    func resetsAtNilProducesNilResetAtField() {
        let window = RateWindow(
            usedPercent: 20,
            windowMinutes: nil,
            resetsAt: nil,
            resetDescription: detailText)
        let snapshot = UsageSnapshot(
            primary: window,
            secondary: nil,
            tertiary: nil,
            extraRateWindows: nil,
            updatedAt: now,
            identity: ProviderIdentitySnapshot(
                providerID: .ark,
                accountEmail: nil,
                accountOrganization: nil,
                loginMethod: nil))

        let rows = ArkWidgetSnapshotRows.rows(from: snapshot)

        #expect(rows.count == 1)
        #expect(rows[0].percentLeft == 80)
        // resetAt is nil because the window has no reset date.
        #expect(rows[0].resetAt == nil)
        // detailText still carries the M2 display string.
        #expect(rows[0].detailText == detailText)
    }

    // MARK: - resetDescription nil produces nil detailText

    @Test
    func resetDescriptionNilProducesNilDetailText() {
        let window = RateWindow(
            usedPercent: 20,
            windowMinutes: nil,
            resetsAt: resetDate,
            resetDescription: nil)
        let snapshot = UsageSnapshot(
            primary: window,
            secondary: nil,
            tertiary: nil,
            extraRateWindows: nil,
            updatedAt: now,
            identity: ProviderIdentitySnapshot(
                providerID: .ark,
                accountEmail: nil,
                accountOrganization: nil,
                loginMethod: nil))

        let rows = ArkWidgetSnapshotRows.rows(from: snapshot)

        #expect(rows.count == 1)
        #expect(rows[0].resetAt == resetDate)
        // detailText is nil because resetDescription is nil.
        #expect(rows[0].detailText == nil)
    }
}
