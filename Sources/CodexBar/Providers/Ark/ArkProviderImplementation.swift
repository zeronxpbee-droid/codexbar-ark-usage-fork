import AppKit
import CodexBarCore
import Foundation
import SwiftUI

struct ArkProviderImplementation: ProviderImplementation {
    let id: UsageProvider = .ark

    @MainActor
    func presentation(context _: ProviderPresentationContext) -> ProviderPresentation {
        ProviderPresentation { _ in "api" }
    }

    @MainActor
    func observeSettings(_ settings: SettingsStore) {
        _ = settings.arkAccessKeyID
        _ = settings.arkSecretAccessKey
    }

    @MainActor
    func isAvailable(context: ProviderAvailabilityContext) -> Bool {
        ArkSettingsReader.hasCredentials(environment: context.environment)
    }

    @MainActor
    func settingsFields(context: ProviderSettingsContext) -> [ProviderSettingsFieldDescriptor] {
        [
            ProviderSettingsFieldDescriptor(
                id: "ark-access-key-id",
                title: "Access Key ID",
                subtitle: "Volcengine IAM Access Key ID. Can also be set with VOLCENGINE_ACCESS_KEY_ID.",
                kind: .secure,
                placeholder: "AKLT...",
                binding: context.stringBinding(\.arkAccessKeyID),
                actions: [],
                isVisible: nil,
                onActivate: nil),
            ProviderSettingsFieldDescriptor(
                id: "ark-secret-access-key",
                title: "Secret Access Key",
                subtitle: "Volcengine IAM Secret Access Key. Can also be set with VOLCENGINE_SECRET_ACCESS_KEY.",
                kind: .secure,
                placeholder: "",
                binding: context.stringBinding(\.arkSecretAccessKey),
                actions: [],
                isVisible: nil,
                onActivate: nil),
        ]
    }
}
