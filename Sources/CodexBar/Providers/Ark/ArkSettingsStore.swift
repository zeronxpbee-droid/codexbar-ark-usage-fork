import CodexBarCore
import Foundation

extension SettingsStore {
    /// Volcengine Ark Access Key ID, stored in the shared `ProviderConfig.apiKey`
    /// (AGENTS.md §6: Ark uses no Keychain; the official config.json — written at
    /// 0600 by CodexBarConfigStore — is the single source of truth). Projected to
    /// `VOLCENGINE_ACCESS_KEY_ID` for the fetcher via ProviderConfigEnvironment (S8).
    var arkAccessKeyID: String {
        get { self.configSnapshot.providerConfig(for: .ark)?.sanitizedAPIKey ?? "" }
        set {
            self.updateProviderConfig(provider: .ark) { entry in
                entry.apiKey = self.normalizedConfigValue(newValue)
            }
            self.logSecretUpdate(provider: .ark, field: "accessKeyID", value: newValue)
        }
    }

    /// Volcengine Ark Secret Access Key, stored in `ProviderConfig.secretKey` and
    /// projected to `VOLCENGINE_SECRET_ACCESS_KEY`.
    var arkSecretAccessKey: String {
        get { self.configSnapshot.providerConfig(for: .ark)?.sanitizedSecretKey ?? "" }
        set {
            self.updateProviderConfig(provider: .ark) { entry in
                entry.secretKey = self.normalizedConfigValue(newValue)
            }
            self.logSecretUpdate(provider: .ark, field: "secretAccessKey", value: newValue)
        }
    }
}
