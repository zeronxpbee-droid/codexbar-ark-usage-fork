import CodexBarCore
import Foundation

/// S17 (M3) Ark-owned widget snapshot row mapper.
///
/// Produces stable 5h / Daily / Weekly / Monthly `WidgetUsageRowSnapshot`
/// rows from an Ark `UsageSnapshot`. Each known row carries:
/// - `percentLeft`: remaining percent (100 - usedPercent);
/// - `resetsAt`: the real window reset date (S18 field);
/// - `detailText`: the M2 opaque complete display string from
///   `RateWindow.resetDescription` (S18 field) — display-only, never parsed.
///
/// Missing windows are omitted rather than invented as zero. Monthly
/// `usageKnown = false` keeps the row visible (for reset context) but with
/// `percentLeft`, `resetsAt`, and `detailText` all `nil`.
///
/// This mapper does not change `supportsOpus` or enable Widget selection/UI.
enum ArkWidgetSnapshotRows {
    /// Map an Ark `UsageSnapshot` to stable widget rows in the order
    /// 5h, Daily, Weekly, Monthly.
    static func rows(from snapshot: UsageSnapshot) -> [WidgetSnapshot.WidgetUsageRowSnapshot] {
        var rows: [WidgetSnapshot.WidgetUsageRowSnapshot] = []

        if let window = snapshot.primary {
            rows.append(Self.makeRow(id: "ark-afp-5h", title: "5h", window: window))
        }

        if let window = snapshot.secondary {
            rows.append(Self.makeRow(id: "ark-afp-daily", title: "Daily", window: window))
        }

        if let window = snapshot.tertiary {
            rows.append(Self.makeRow(id: "ark-afp-weekly", title: "Weekly", window: window))
        }

        if let monthly = snapshot.extraRateWindows?.first(where: { $0.id == "ark-afp-monthly" }) {
            if monthly.usageKnown {
                rows.append(Self.makeRow(id: monthly.id, title: monthly.title, window: monthly.window))
            } else {
                rows.append(WidgetSnapshot.WidgetUsageRowSnapshot(
                    id: monthly.id,
                    title: monthly.title,
                    percentLeft: nil,
                    resetsAt: nil,
                    detailText: nil))
            }
        }

        return rows
    }

    /// Build a single row from a known `RateWindow`.
    private static func makeRow(
        id: String,
        title: String,
        window: RateWindow) -> WidgetSnapshot.WidgetUsageRowSnapshot
    {
        WidgetSnapshot.WidgetUsageRowSnapshot(
            id: id,
            title: title,
            percentLeft: window.remainingPercent,
            resetsAt: window.resetsAt,
            detailText: window.resetDescription)
    }
}
