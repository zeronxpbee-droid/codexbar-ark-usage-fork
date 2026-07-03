import CodexBarCore
import Foundation

/// Ark-owned popover metrics for the four AFP windows (5h / Daily / Weekly / Monthly).
///
/// S15 (M2, Option A): Ark's four-window model cannot render correctly through
/// the standard `metrics(input:)` path because (1) `supportsOpus` is `false`
/// (kept false to avoid touching the M3 Widget snapshot boundary), which hides
/// the tertiary (Weekly) row, and (2) `RateWindow` has no typed used/quota/
/// remaining fields to satisfy FR4's four-value requirement.
///
/// This file builds `[Metric]` rows directly from `UsageSnapshot`, reusing
/// `Metric`, `PercentStyle`, and `UsageFormatter`. The complete display string
/// (used / quota / remaining) is carried in `RateWindow.resetDescription` and
/// read into `Metric.detailText` as **opaque display text** — never parsed back
/// into numeric values.
///
/// `resetText` is generated ONLY from `resetsAt` (via `UsageFormatter.resetLine`),
/// guarded so it never falls back to `resetDescription` (which would render
/// quota text as `"Resets …"` — see `UsageFormatter.resetLine` lines 150-159).
extension UsageMenuCardView.Model {
    /// Build the four AFP window rows for the Ark popover. Called from the
    /// S15 router branch in `metrics(input:)`.
    static func arkMetrics(input: Input, snapshot: UsageSnapshot) -> [Metric] {
        let percentStyle: PercentStyle = input.usageBarsShowUsed ? .used : .left
        var metrics: [Metric] = []

        if let primary = snapshot.primary {
            metrics.append(Self.arkMetric(
                id: "primary",
                title: L(input.metadata.sessionLabel),
                window: primary,
                input: input,
                percentStyle: percentStyle))
        }
        if let secondary = snapshot.secondary {
            metrics.append(Self.arkMetric(
                id: "secondary",
                title: L(input.metadata.weeklyLabel),
                window: secondary,
                input: input,
                percentStyle: percentStyle))
        }
        // Weekly (tertiary) is NOT gated by supportsOpus here — Ark renders all
        // four windows directly. The title is hardcoded because
        // `input.metadata.opusLabel` is nil (Ark does not use the Opus label),
        // and `rateWindowLabels` would fall back to "Sonnet".
        if let tertiary = snapshot.tertiary {
            metrics.append(Self.arkMetric(
                id: "tertiary",
                title: L("Weekly"),
                window: tertiary,
                input: input,
                percentStyle: percentStyle))
        }
        metrics.append(contentsOf: Self.arkExtraRateWindowMetrics(
            snapshot: snapshot,
            input: input,
            percentStyle: percentStyle))
        return metrics
    }

    /// Build a single Ark rate-window `Metric`.
    ///
    /// - `detailText`: `window.resetDescription` (the complete display string
    ///   `"used / quota AFP · remaining remaining"`), treated as opaque text.
    /// - `resetText`: generated ONLY when `resetsAt != nil`, via
    ///   `UsageFormatter.resetLine`. Never falls back to `resetDescription`.
    /// - `percent`: used% or remaining% per `usageBarsShowUsed`.
    private static func arkMetric(
        id: String,
        title: String,
        window: RateWindow,
        input: Input,
        percentStyle: PercentStyle) -> Metric
    {
        let percent = Self.clamped(
            input.usageBarsShowUsed ? window.usedPercent : window.remainingPercent)
        let resetText: String? = window.resetsAt != nil
            ? Self.resetText(for: window, style: input.resetTimeDisplayStyle, now: input.now)
            : nil
        return Metric(
            id: id,
            title: title,
            percent: percent,
            percentStyle: percentStyle,
            resetText: resetText,
            detailText: window.resetDescription,
            detailLeftText: nil,
            detailRightText: nil,
            pacePercent: nil,
            paceOnTop: true)
    }

    /// Render Ark's extra rate windows (Monthly) with the same Option A data
    /// flow: `detailText` = `resetDescription`, `resetText` guarded by
    /// `resetsAt`. Unknown windows show "Unavailable" via `statusText`.
    private static func arkExtraRateWindowMetrics(
        snapshot: UsageSnapshot,
        input: Input,
        percentStyle: PercentStyle) -> [Metric]
    {
        guard let extraRateWindows = snapshot.extraRateWindows else { return [] }
        return extraRateWindows.map { namedWindow in
            let window = namedWindow.window
            let usageKnown = namedWindow.usageKnown
            let resetText: String? = usageKnown && window.resetsAt != nil
                ? Self.resetText(for: window, style: input.resetTimeDisplayStyle, now: input.now)
                : nil
            let statusText: String? = if usageKnown {
                nil
            } else if let resetText {
                "\(L("Unavailable")) - \(resetText)"
            } else {
                L("Unavailable")
            }
            return Metric(
                id: namedWindow.id,
                title: namedWindow.title,
                percent: Self.clamped(
                    input.usageBarsShowUsed
                        ? window.usedPercent
                        : window.remainingPercent),
                percentStyle: percentStyle,
                statusText: statusText,
                resetText: resetText,
                detailText: usageKnown ? window.resetDescription : nil,
                detailLeftText: nil,
                detailRightText: nil,
                pacePercent: nil,
                paceOnTop: true)
        }
    }
}
