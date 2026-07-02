import Foundation

/// Static API facts for the Volcengine Ark Agent Plan `GetAFPUsage` OpenAPI,
/// as confirmed in docs/PROJECT_LOG.md (Entries 002/003). Centralized here so
/// the unresolved host question stays visible and configurable.
public enum ArkAPIConfig {
    public static let action = "GetAFPUsage"
    public static let version = "2024-01-01"
    public static let service = "ark"
    public static let region = "cn-beijing"

    /// RESOLVED (M0 open question #1, docs/PROJECT_LOG.md Entry 015): a
    /// credentialed live probe confirmed the production host. Using the same
    /// signer, action, version, body, and credential pair (only `--host`
    /// changed), `ark.cn-beijing.volcengineapi.com` returned HTTP 200 and the
    /// probe parsed all four AFP windows, while the action-doc example host
    /// `ark.cn-beijing.volces.com` returned HTTP 401. Both cases are retained so
    /// the `--host` override can still target either endpoint, but the default
    /// is the confirmed-working control-plane host.
    public enum Host: String, CaseIterable, Sendable {
        case volces = "ark.cn-beijing.volces.com"
        case volcengineapi = "ark.cn-beijing.volcengineapi.com"
    }

    /// Production/default host, confirmed by the Entry 015 live probe.
    public static let defaultHost: Host = .volcengineapi

    /// Query items required on the signed request.
    public static func queryItems() -> [(String, String)] {
        [
            ("Action", Self.action),
            ("Version", Self.version),
        ]
    }
}
