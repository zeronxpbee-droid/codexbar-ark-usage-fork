import Foundation

/// Decodable models for the Volcengine Ark Agent Plan `GetAFPUsage` response,
/// promoted from the M0 probe.
///
/// Confirmed shape (docs/PROJECT_LOG.md Entry 002):
///   - Windows: `AFPFiveHour`, `AFPDaily`, `AFPWeekly`, `AFPMonthly`.
///   - Each window: `Quota`, `Used`, `SubscribeTime`, `ResetTime`.
///   - `SubscribeTime` / `ResetTime` are epoch **milliseconds**.
///
/// The Volcengine OpenAPI envelope typically wraps the payload in
/// `ResponseMetadata` + `Result`. We decode defensively: the four windows are
/// read from `Result` if present, otherwise from the top level.
public struct GetAFPUsageResponse: Sendable, Equatable {
    public let fiveHour: AFPWindow?
    public let daily: AFPWindow?
    public let weekly: AFPWindow?
    public let monthly: AFPWindow?

    public init(fiveHour: AFPWindow?, daily: AFPWindow?, weekly: AFPWindow?, monthly: AFPWindow?) {
        self.fiveHour = fiveHour
        self.daily = daily
        self.weekly = weekly
        self.monthly = monthly
    }

    /// Ordered, non-nil windows with a stable label for display/sanitized output.
    public var windows: [(label: String, window: AFPWindow)] {
        var result: [(String, AFPWindow)] = []
        if let w = fiveHour { result.append(("5h", w)) }
        if let w = daily { result.append(("Daily", w)) }
        if let w = weekly { result.append(("Weekly", w)) }
        if let w = monthly { result.append(("Monthly", w)) }
        return result
    }
}

public struct AFPWindow: Sendable, Equatable, Decodable {
    public let quota: Double?
    public let used: Double?
    /// Epoch milliseconds, as returned by the API.
    public let subscribeTimeMillis: Int64?
    /// Epoch milliseconds, as returned by the API.
    public let resetTimeMillis: Int64?

    public init(quota: Double?, used: Double?, subscribeTimeMillis: Int64?, resetTimeMillis: Int64?) {
        self.quota = quota
        self.used = used
        self.subscribeTimeMillis = subscribeTimeMillis
        self.resetTimeMillis = resetTimeMillis
    }

    private enum CodingKeys: String, CodingKey {
        case quota = "Quota"
        case used = "Used"
        case subscribeTime = "SubscribeTime"
        case resetTime = "ResetTime"
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.quota = try c.decodeIfPresent(Double.self, forKey: .quota)
        self.used = try c.decodeIfPresent(Double.self, forKey: .used)
        self.subscribeTimeMillis = try c.decodeIfPresent(Int64.self, forKey: .subscribeTime)
        self.resetTimeMillis = try c.decodeIfPresent(Int64.self, forKey: .resetTime)
    }

    /// Remaining derived as quota - used, clamped at zero, when both are present.
    public var remaining: Double? {
        guard let quota, let used else { return nil }
        return max(0, quota - used)
    }

    /// Used percentage clamped to 0...100, or nil when quota/used are unavailable
    /// or quota is non-positive (so the caller does not render unknown as 0%).
    public var usedPercent: Double? {
        guard let quota, let used, quota > 0 else { return nil }
        return min(100, max(0, used / quota * 100))
    }

    public var resetDate: Date? {
        guard let ms = resetTimeMillis else { return nil }
        return Date(timeIntervalSince1970: Double(ms) / 1000.0)
    }
}

public enum GetAFPUsageParser {
    public enum ParseError: Error, LocalizedError {
        case invalidJSON
        case noWindows

        public var errorDescription: String? {
            switch self {
            case .invalidJSON: "Response body was not valid JSON."
            case .noWindows: "Response contained none of the expected AFP windows."
            }
        }
    }

    private enum WindowKeys {
        static let fiveHour = "AFPFiveHour"
        static let daily = "AFPDaily"
        static let weekly = "AFPWeekly"
        static let monthly = "AFPMonthly"
    }

    /// Parse a `GetAFPUsage` JSON body. Tolerates the payload being nested in
    /// `Result` or present at the top level. Throws `noWindows` if none of the
    /// four expected windows are found (so an empty/unauthorized body is not
    /// silently treated as zero usage).
    public static func parse(_ data: Data) throws -> GetAFPUsageResponse {
        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ParseError.invalidJSON
        }

        // Prefer a nested `Result` object if the four windows live there.
        let container: [String: Any]
        if let result = root["Result"] as? [String: Any],
           Self.containsAnyWindow(result)
        {
            container = result
        } else {
            container = root
        }

        let decoder = JSONDecoder()
        func window(_ key: String) -> AFPWindow? {
            guard let dict = container[key] as? [String: Any],
                  let sub = try? JSONSerialization.data(withJSONObject: dict),
                  let decoded = try? decoder.decode(AFPWindow.self, from: sub)
            else { return nil }
            return decoded
        }

        let response = GetAFPUsageResponse(
            fiveHour: window(WindowKeys.fiveHour),
            daily: window(WindowKeys.daily),
            weekly: window(WindowKeys.weekly),
            monthly: window(WindowKeys.monthly))

        guard !response.windows.isEmpty else { throw ParseError.noWindows }
        return response
    }

    private static func containsAnyWindow(_ dict: [String: Any]) -> Bool {
        dict[WindowKeys.fiveHour] != nil
            || dict[WindowKeys.daily] != nil
            || dict[WindowKeys.weekly] != nil
            || dict[WindowKeys.monthly] != nil
    }
}
