import Foundation

/// Renders a parsed `GetAFPUsage` response into a redacted, human-readable
/// report. Per docs/PRD.md §9 and AGENTS.md §6, output must contain only the
/// window names and numeric quota fields required for implementation — never
/// credentials, account identifiers, request IDs, or raw response envelopes.
public enum SanitizedUsageReport {
    /// ISO-8601 UTC rendering of a reset time, or `unknown` when absent.
    private static func resetString(_ window: AFPWindow) -> String {
        guard let date = window.resetDate else { return "unknown" }
        let f = ISO8601DateFormatter()
        f.timeZone = TimeZone(identifier: "UTC")
        return f.string(from: date)
    }

    private static func num(_ value: Double?) -> String {
        guard let value else { return "n/a" }
        // Trim trailing .0 for whole numbers, keep up to 2 decimals otherwise.
        if value == value.rounded() {
            return String(Int64(value))
        }
        return String(format: "%.2f", value)
    }

    /// A multi-line report of only numeric quota fields per window.
    public static func render(_ response: GetAFPUsageResponse) -> String {
        var lines: [String] = []
        lines.append("GetAFPUsage windows (redacted — numeric quota fields only):")
        for entry in response.windows {
            let w = entry.window
            lines.append(
                "  \(entry.label.padding(toLength: 8, withPad: " ", startingAt: 0))"
                    + " used=\(Self.num(w.used))"
                    + " quota=\(Self.num(w.quota))"
                    + " remaining=\(Self.num(w.remaining))"
                    + " reset=\(Self.resetString(w))")
        }
        if response.windows.isEmpty {
            lines.append("  (no windows present)")
        }
        return lines.joined(separator: "\n")
    }

    /// Describes the structure of a signed request WITHOUT exposing the
    /// Authorization signature, secret material, or account identifiers. Used
    /// by the dry-run path so a probe can be inspected before any live call.
    public static func renderSignedRequestShape(
        host: String,
        method: String,
        path: String,
        query: [(String, String)],
        signedHeaders: String,
        bodyByteCount: Int) -> String
    {
        var lines: [String] = []
        lines.append("Signed request shape (redacted):")
        lines.append("  \(method) https://\(host)\(path)")
        lines.append("  query: \(query.map { "\($0.0)=\($0.1)" }.joined(separator: "&"))")
        lines.append("  signedHeaders: \(signedHeaders)")
        lines.append("  body: \(bodyByteCount) bytes")
        lines.append("  authorization: <redacted — signature not printed>")
        return lines.joined(separator: "\n")
    }
}
