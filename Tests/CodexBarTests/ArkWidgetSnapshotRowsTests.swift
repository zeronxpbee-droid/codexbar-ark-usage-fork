import CodexBarCore
import Foundation
import Testing
@testable import CodexBar

/// S17 (M3) tests for `ArkWidgetSnapshotRows`.
///
/// Verifies the four-window widget row mapping:
///   - Stable ordering: 5h, Daily, Weekly, Monthly.
///   - Each known row carries `percentLeft` (remaining %), `resetsAt` (real
///     reset date), and `detailText` (M2 opaque complete display string).
///   - Missing windows are omitted, not invented as zero.
///   - Monthly `usageKnown = false` keeps the row visible but with
///     `percentLeft`/`resetsAt`/`detailText` all `nil`.
struct ArkWidgetSnapshotRowsTests {
    // MARK: - Helpers

    private let now = Date(timeIntervalSince1970: 1_742_771_200)
    private let resetDate = Date(timeIntervalSince1970: 1_742_771_200 + 3600)
    private let detailText = "100 / 500 AFP · 400 remaining"

    private func arkWindow(usedPercent: Double = 20) -> RateWindow {
        RateWindow(
            usedPercent: usedPercent,
            windowMinutes: nil,
            resetsAt: self.resetDate,
            resetDescription: self.detailText)
    }

    private func monthlyNamedWindow(usedPercent: Double = 10, usageKnown: Bool = true) -> NamedRateWindow {
        NamedRateWindow(
            id: "ark-afp-monthly",
            title: "Monthly",
            window: self.arkWindow(usedPercent: usedPercent),
            usageKnown: usageKnown)
    }

    private func makeIdentity() -> ProviderIdentitySnapshot {
        ProviderIdentitySnapshot(
            providerID: .ark,
            accountEmail: nil,
            accountOrganization: nil,
            loginMethod: nil)
    }

    // MARK: - Four windows complete

    @Test
    func fourWindowsCompleteProducesStableOrder() {
        let snapshot = UsageSnapshot(
            primary: self.arkWindow(usedPercent: 20),
            secondary: self.arkWindow(usedPercent: 30),
            tertiary: self.arkWindow(usedPercent: 40),
            extraRateWindows: [self.monthlyNamedWindow(usedPercent: 10)],
            updatedAt: self.now,
            identity: self.makeIdentity())

        let rows = ArkWidgetSnapshotRows.rows(from: snapshot)

        #expect(rows.count == 4)
        #expect(rows.map(\.id) == ["ark-afp-5h", "ark-afp-daily", "ark-afp-weekly", "ark-afp-monthly"])
        #expect(rows.map(\.title) == ["5h", "Daily", "Weekly", "Monthly"])
    }

    @Test
    func fourWindowsCompleteCarriesAllS18Fields() {
        let snapshot = UsageSnapshot(
            primary: self.arkWindow(usedPercent: 20),
            secondary: self.arkWindow(usedPercent: 30),
            tertiary: self.arkWindow(usedPercent: 40),
            extraRateWindows: [self.monthlyNamedWindow(usedPercent: 10)],
            updatedAt: self.now,
            identity: self.makeIdentity())

        let rows = ArkWidgetSnapshotRows.rows(from: snapshot)

        // remainingPercent = 100 - usedPercent for each window
        #expect(rows[0].percentLeft == 80)
        #expect(rows[1].percentLeft == 70)
        #expect(rows[2].percentLeft == 60)
        #expect(rows[3].percentLeft == 90)

        // Every known row carries the real reset date and M2 detail string.
        for row in rows {
            #expect(row.resetsAt == self.resetDate)
            #expect(row.detailText == self.detailText)
        }
    }

    // MARK: - Missing windows omitted

    @Test
    func onlyPrimaryPresentOmitsMissingWindows() {
        let snapshot = UsageSnapshot(
            primary: self.arkWindow(usedPercent: 20),
            secondary: nil,
            tertiary: nil,
            extraRateWindows: nil,
            updatedAt: self.now,
            identity: self.makeIdentity())

        let rows = ArkWidgetSnapshotRows.rows(from: snapshot)

        #expect(rows.count == 1)
        #expect(rows[0].id == "ark-afp-5h")
        #expect(rows[0].title == "5h")
        #expect(rows[0].percentLeft == 80)
        #expect(rows[0].resetsAt == self.resetDate)
        #expect(rows[0].detailText == self.detailText)
    }

    @Test
    func primaryAndTertiaryOnlySkipsDailyAndMonthly() {
        let snapshot = UsageSnapshot(
            primary: self.arkWindow(usedPercent: 20),
            secondary: nil,
            tertiary: self.arkWindow(usedPercent: 40),
            extraRateWindows: nil,
            updatedAt: self.now,
            identity: self.makeIdentity())

        let rows = ArkWidgetSnapshotRows.rows(from: snapshot)

        #expect(rows.count == 2)
        #expect(rows.map(\.id) == ["ark-afp-5h", "ark-afp-weekly"])
    }

    // MARK: - Monthly usageKnown = false

    @Test
    func monthlyUsageUnknownKeepsRowWithNilFields() {
        let snapshot = UsageSnapshot(
            primary: self.arkWindow(usedPercent: 20),
            secondary: nil,
            tertiary: nil,
            extraRateWindows: [self.monthlyNamedWindow(usedPercent: 0, usageKnown: false)],
            updatedAt: self.now,
            identity: self.makeIdentity())

        let rows = ArkWidgetSnapshotRows.rows(from: snapshot)

        #expect(rows.count == 2)
        let monthlyRow = rows[1]
        #expect(monthlyRow.id == "ark-afp-monthly")
        #expect(monthlyRow.title == "Monthly")
        // usageKnown = false → all value fields nil, but row preserved.
        #expect(monthlyRow.percentLeft == nil)
        #expect(monthlyRow.resetsAt == nil)
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
            updatedAt: self.now,
            identity: self.makeIdentity())

        let rows = ArkWidgetSnapshotRows.rows(from: snapshot)

        #expect(rows.isEmpty)
    }

    // MARK: - resetsAt nil preserved

    @Test
    func resetsAtNilProducesNilResetsAtField() {
        let window = RateWindow(
            usedPercent: 20,
            windowMinutes: nil,
            resetsAt: nil,
            resetDescription: self.detailText)
        let snapshot = UsageSnapshot(
            primary: window,
            secondary: nil,
            tertiary: nil,
            extraRateWindows: nil,
            updatedAt: self.now,
            identity: self.makeIdentity())

        let rows = ArkWidgetSnapshotRows.rows(from: snapshot)

        #expect(rows.count == 1)
        #expect(rows[0].percentLeft == 80)
        // resetsAt is nil because the window has no reset date.
        #expect(rows[0].resetsAt == nil)
        // detailText still carries the M2 display string.
        #expect(rows[0].detailText == self.detailText)
    }

    // MARK: - resetDescription nil produces nil detailText

    @Test
    func resetDescriptionNilProducesNilDetailText() {
        let window = RateWindow(
            usedPercent: 20,
            windowMinutes: nil,
            resetsAt: self.resetDate,
            resetDescription: nil)
        let snapshot = UsageSnapshot(
            primary: window,
            secondary: nil,
            tertiary: nil,
            extraRateWindows: nil,
            updatedAt: self.now,
            identity: self.makeIdentity())

        let rows = ArkWidgetSnapshotRows.rows(from: snapshot)

        #expect(rows.count == 1)
        #expect(rows[0].resetsAt == self.resetDate)
        // detailText is nil because resetDescription is nil.
        #expect(rows[0].detailText == nil)
    }
}
