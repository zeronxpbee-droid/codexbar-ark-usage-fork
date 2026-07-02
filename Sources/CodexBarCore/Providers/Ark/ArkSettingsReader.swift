import Foundation

/// Reads Volcengine Ark IAM credentials from a provider environment dictionary.
///
/// Ark uses long-lived IAM Access Key ID + Secret Access Key (see AGENTS.md §6:
/// the Bedrock storage pattern). The production App projects the stored
/// `ProviderConfig.apiKey` / `secretKey` into these environment keys via
/// `ProviderConfigEnvironment` (shared touchpoint S8). The environment path is
/// also what the isolated M0 probe used, keeping the key names consistent.
public enum ArkSettingsReader {
    public static let accessKeyIDKey = "VOLCENGINE_ACCESS_KEY_ID"
    public static let secretAccessKeyKey = "VOLCENGINE_SECRET_ACCESS_KEY"

    public static func accessKeyID(
        environment: [String: String] = ProcessInfo.processInfo.environment) -> String?
    {
        self.cleaned(environment[self.accessKeyIDKey])
    }

    public static func secretAccessKey(
        environment: [String: String] = ProcessInfo.processInfo.environment) -> String?
    {
        self.cleaned(environment[self.secretAccessKeyKey])
    }

    /// True only when both the Access Key ID and Secret Access Key are present.
    public static func hasCredentials(
        environment: [String: String] = ProcessInfo.processInfo.environment) -> Bool
    {
        self.accessKeyID(environment: environment) != nil
            && self.secretAccessKey(environment: environment) != nil
    }

    static func cleaned(_ raw: String?) -> String? {
        guard var value = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return nil
        }

        if (value.hasPrefix("\"") && value.hasSuffix("\"")) ||
            (value.hasPrefix("'") && value.hasSuffix("'"))
        {
            value = String(value.dropFirst().dropLast())
        }

        value = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
