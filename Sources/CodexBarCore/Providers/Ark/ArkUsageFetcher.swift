import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Normalized Volcengine Ark Agent Plan AFP usage, mapped from the four API
/// windows into CodexBar's rate-window model.
///
/// Window semantics (docs/TASKS.md, 方案 B): the 5-hour window is `primary`,
/// Daily is `secondary`, Weekly is `tertiary`, and Monthly is carried as an
/// extra named window. The menu-bar automatic display selects the highest-risk
/// window via `MenuBarMetricWindowResolver` (S9); these stable slots are what
/// the popover (M2) and Widget (M3+) will read.
public struct ArkUsageSnapshot: Sendable, Equatable {
    public let fiveHour: AFPWindow?
    public let daily: AFPWindow?
    public let weekly: AFPWindow?
    public let monthly: AFPWindow?
    public let updatedAt: Date

    public init(
        fiveHour: AFPWindow?,
        daily: AFPWindow?,
        weekly: AFPWindow?,
        monthly: AFPWindow?,
        updatedAt: Date)
    {
        self.fiveHour = fiveHour
        self.daily = daily
        self.weekly = weekly
        self.monthly = monthly
        self.updatedAt = updatedAt
    }

    public init(response: GetAFPUsageResponse, updatedAt: Date = Date()) {
        self.init(
            fiveHour: response.fiveHour,
            daily: response.daily,
            weekly: response.weekly,
            monthly: response.monthly,
            updatedAt: updatedAt)
    }

    public func toUsageSnapshot() -> UsageSnapshot {
        let monthlyWindow = Self.rateWindow(from: self.monthly)
        let extra: [NamedRateWindow]? = monthlyWindow.map { window in
            [NamedRateWindow(
                id: "ark-afp-monthly",
                title: "Monthly",
                window: window,
                usageKnown: self.monthly?.usedPercent != nil)]
        }

        let identity = ProviderIdentitySnapshot(
            providerID: .ark,
            accountEmail: nil,
            accountOrganization: nil,
            loginMethod: nil)

        return UsageSnapshot(
            primary: Self.rateWindow(from: self.fiveHour),
            secondary: Self.rateWindow(from: self.daily),
            tertiary: Self.rateWindow(from: self.weekly),
            extraRateWindows: extra,
            updatedAt: self.updatedAt,
            identity: identity)
    }

    /// Map a single AFP window into a `RateWindow`. Returns nil when the window
    /// is absent or has no trustworthy quota, so the UI never renders unknown
    /// usage as 0%.
    private static func rateWindow(from afp: AFPWindow?) -> RateWindow? {
        guard let afp, let usedPercent = afp.usedPercent else { return nil }
        let description: String? = if let quota = afp.quota, let used = afp.used {
            "\(Self.format(used))/\(Self.format(quota))"
        } else {
            nil
        }
        return RateWindow(
            usedPercent: usedPercent,
            windowMinutes: nil,
            resetsAt: afp.resetDate,
            resetDescription: description)
    }

    private static func format(_ value: Double) -> String {
        if value == value.rounded() {
            return String(Int(value))
        }
        return String(format: "%.2f", value)
    }
}

public enum ArkUsageError: LocalizedError, Sendable, Equatable {
    case missingCredentials
    case networkError(String)
    /// Carries only the validated, redacted error code (never the raw body).
    case apiError(statusCode: Int, errorCode: String?)
    case emptyOrUnsupported
    case parseFailed

    public var errorDescription: String? {
        switch self {
        case .missingCredentials:
            "Missing Ark credentials. Add your Volcengine IAM Access Key ID and Secret Access Key."
        case let .networkError(message):
            "Ark network error: \(message)"
        case let .apiError(statusCode, errorCode):
            if let errorCode {
                "Ark API error (HTTP \(statusCode), \(errorCode))."
            } else {
                "Ark API error (HTTP \(statusCode))."
            }
        case .emptyOrUnsupported:
            "Ark returned no Agent Plan usage windows for this account."
        case .parseFailed:
            "Failed to parse the Ark usage response."
        }
    }
}

public struct ArkUsageFetcher: Sendable {
    private static let log = CodexBarLog.logger(LogCategories.arkUsage)

    /// Fetch and normalize Agent Plan AFP usage using a signed `GetAFPUsage`
    /// request. Emits only redacted diagnostics (never AK/SK, Authorization,
    /// signatures, RequestId, or raw error bodies).
    public static func fetchUsage(
        credentials: VolcengineArkSigner.Credentials,
        host: ArkAPIConfig.Host = ArkAPIConfig.defaultHost,
        now: Date = Date(),
        session transport: any ProviderHTTPTransport = ProviderHTTPClient.shared) async throws -> ArkUsageSnapshot
    {
        guard !credentials.accessKeyID.isEmpty, !credentials.secretAccessKey.isEmpty else {
            throw ArkUsageError.missingCredentials
        }

        let body = Data("{}".utf8)
        let query = ArkAPIConfig.queryItems()
        let signed = VolcengineArkSigner.sign(
            VolcengineArkSigner.RequestInput(host: host.rawValue, query: query, body: body),
            credentials: credentials,
            region: ArkAPIConfig.region,
            service: ArkAPIConfig.service,
            date: now)

        guard let url = Self.makeURL(host: host, query: query) else {
            throw ArkUsageError.networkError("Failed to construct request URL.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 15
        request.httpBody = body
        for (key, value) in signed.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        let response: ProviderHTTPResponse
        do {
            response = try await transport.response(for: request)
        } catch let error as URLError {
            Self.log.error("Ark request failed: URLError \(error.code.rawValue)")
            throw ArkUsageError.networkError("URLError \(error.code.rawValue)")
        } catch {
            if error is CancellationError { throw error }
            Self.log.error("Ark request failed with a transport error.")
            throw ArkUsageError.networkError("Transport error.")
        }

        guard response.statusCode == 200 else {
            let errorCode = ArkErrorResponse.extractErrorCode(from: response.data)
            Self.log.error("Ark API returned HTTP \(response.statusCode) code=\(errorCode ?? "<unavailable>")")
            throw ArkUsageError.apiError(statusCode: response.statusCode, errorCode: errorCode)
        }

        let parsed: GetAFPUsageResponse
        do {
            parsed = try GetAFPUsageParser.parse(response.data)
        } catch GetAFPUsageParser.ParseError.noWindows {
            Self.log.info("Ark GetAFPUsage returned no AFP windows.")
            throw ArkUsageError.emptyOrUnsupported
        } catch {
            Self.log.error("Ark GetAFPUsage response could not be parsed.")
            throw ArkUsageError.parseFailed
        }

        Self.log.debug("Ark usage parsed windows=\(parsed.windows.count)")
        return ArkUsageSnapshot(response: parsed, updatedAt: now)
    }

    private static func makeURL(host: ArkAPIConfig.Host, query: [(String, String)]) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host.rawValue
        components.path = "/"
        components.queryItems = query.map { URLQueryItem(name: $0.0, value: $0.1) }
        return components.url
    }
}
