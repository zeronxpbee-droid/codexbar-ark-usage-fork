import Foundation

/// Static API facts for the Volcengine Ark Agent Plan `GetAFPUsage` OpenAPI,
/// as confirmed in docs/PROJECT_LOG.md (Entries 002/003). Centralized here so
/// the unresolved host question stays visible and configurable.
public enum ArkAPIConfig {
    public static let action = "GetAFPUsage"
    public static let version = "2024-01-01"
    public static let service = "ark"
    public static let region = "cn-beijing"

    /// UNRESOLVED (M0 open question #1): the `GetAFPUsage` request example uses
    /// `ark.cn-beijing.volces.com`, while the general control-plane Base URL
    /// documentation lists `ark.cn-beijing.volcengineapi.com`. Both are exposed
    /// here so a probe run can try each; production host must be confirmed
    /// before M1.
    public enum Host: String, CaseIterable, Sendable {
        case volces = "ark.cn-beijing.volces.com"
        case volcengineapi = "ark.cn-beijing.volcengineapi.com"
    }

    public static let defaultHost: Host = .volces

    /// Query items required on the signed request.
    public static func queryItems() -> [(String, String)] {
        [
            ("Action", Self.action),
            ("Version", Self.version),
        ]
    }
}
