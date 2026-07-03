import Foundation
import Testing
@testable import CodexBarCore

/// Ark credential handling: the S8 environment projection (config -> VOLCENGINE_*
/// env keys) and the config-store round-trip with private (0600) permissions.
/// All credentials are FAKE. Ark deliberately does NOT use the Keychain: the
/// Access Key ID lives in `ProviderConfig.apiKey` and the Secret Access Key in
/// `ProviderConfig.secretKey`, persisted by `CodexBarConfigStore` at 0600.
struct ArkCredentialProjectionTests {
    private let fakeAccessKeyID = "AKFAKE000000000000EXAMPLE"
    private let fakeSecretAccessKey = "FAKESECRET0000000000000000000000EXAMPLE"

    // MARK: - S8 projection

    @Test
    func `ark config projects access key id and secret into VOLCENGINE env keys`() {
        let config = ProviderConfig(
            id: .ark,
            apiKey: fakeAccessKeyID,
            secretKey: fakeSecretAccessKey)
        let env = ProviderConfigEnvironment.applyProviderConfigOverrides(
            base: [:],
            provider: .ark,
            config: config)

        #expect(env[ArkSettingsReader.accessKeyIDKey] == fakeAccessKeyID)
        #expect(env[ArkSettingsReader.secretAccessKeyKey] == fakeSecretAccessKey)
        #expect(ArkSettingsReader.hasCredentials(environment: env))
        // AK and SK are projected into distinct keys — never concatenated.
        #expect(ArkSettingsReader.accessKeyIDKey != ArkSettingsReader.secretAccessKeyKey)
        #expect(env[ArkSettingsReader.accessKeyIDKey] != env[ArkSettingsReader.secretAccessKeyKey])
    }

    @Test
    func `ark projection skips empty credential fields`() {
        let config = ProviderConfig(id: .ark, apiKey: "", secretKey: "")
        let env = ProviderConfigEnvironment.applyProviderConfigOverrides(
            base: [:],
            provider: .ark,
            config: config)

        #expect(env[ArkSettingsReader.accessKeyIDKey] == nil)
        #expect(env[ArkSettingsReader.secretAccessKeyKey] == nil)
        #expect(!ArkSettingsReader.hasCredentials(environment: env))
    }

    // MARK: - Config store round-trip + 0600 permissions

    @Test
    func `ark credentials round-trip through the config store at 0600`() throws {
        #if os(macOS) || os(Linux)
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("ark-config-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: fileURL) }

        let store = CodexBarConfigStore(fileURL: fileURL)
        let config = CodexBarConfig(
            version: 1,
            providers: [
                ProviderConfig(
                    id: .ark,
                    enabled: true,
                    apiKey: fakeAccessKeyID,
                    secretKey: fakeSecretAccessKey),
            ])
        try store.save(config)

        // The persisted file must be private to the user.
        let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
        let permissions = try #require(attributes[.posixPermissions] as? NSNumber)
        #expect(permissions.intValue & 0o777 == 0o600)

        // Round-trip preserves both credential fields in their dedicated slots.
        // `load()` returns an optional config; unwrap it before the lookup.
        let loaded = try #require(try store.load())
        let arkConfig = try #require(loaded.providerConfig(for: .ark))
        #expect(arkConfig.apiKey == fakeAccessKeyID)
        #expect(arkConfig.secretKey == fakeSecretAccessKey)

        // And the loaded config projects cleanly into the runtime environment.
        let env = ProviderConfigEnvironment.applyProviderConfigOverrides(
            base: [:],
            provider: .ark,
            config: arkConfig)
        #expect(env[ArkSettingsReader.accessKeyIDKey] == fakeAccessKeyID)
        #expect(env[ArkSettingsReader.secretAccessKeyKey] == fakeSecretAccessKey)
        #else
        #expect(Bool(true))
        #endif
    }
}
