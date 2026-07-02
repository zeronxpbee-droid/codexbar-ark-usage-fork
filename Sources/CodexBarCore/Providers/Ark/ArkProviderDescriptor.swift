import Foundation

public enum ArkProviderDescriptor {
    public static let descriptor: ProviderDescriptor = Self.makeDescriptor()

    static func makeDescriptor() -> ProviderDescriptor {
        ProviderDescriptor(
            id: .ark,
            metadata: ProviderMetadata(
                id: .ark,
                displayName: "Volcengine Ark",
                sessionLabel: "5h",
                weeklyLabel: "Daily",
                opusLabel: nil,
                supportsOpus: false,
                supportsCredits: false,
                creditsHint: "",
                toggleTitle: "Show Volcengine Ark Agent Plan usage",
                cliName: "ark",
                defaultEnabled: false,
                isPrimaryProvider: false,
                usesAccountFallback: false,
                dashboardURL: "https://console.volcengine.com/ark/region:ark+cn-beijing/openManagement?LLM=%7B%7D&advancedActiveKey=subscribe",
                statusPageURL: nil),
            branding: ProviderBranding(
                iconStyle: .ark,
                iconResourceName: "ProviderIcon-ark",
                color: ProviderColor(red: 51 / 255, green: 112 / 255, blue: 255 / 255)),
            tokenCost: ProviderTokenCostConfig(
                supportsTokenCost: false,
                noDataMessage: { "Volcengine Ark cost summary is not available." }),
            fetchPlan: ProviderFetchPlan(
                sourceModes: [.auto, .api],
                pipeline: ProviderFetchPipeline(resolveStrategies: { _ in [ArkAPIFetchStrategy()] })),
            cli: ProviderCLIConfig(
                name: "ark",
                aliases: ["volcengine-ark", "ark-afp"],
                versionDetector: nil))
    }
}

struct ArkAPIFetchStrategy: ProviderFetchStrategy {
    let id: String = "ark.api"
    let kind: ProviderFetchKind = .apiToken

    func isAvailable(_ context: ProviderFetchContext) async -> Bool {
        ArkSettingsReader.hasCredentials(environment: context.env)
    }

    func fetch(_ context: ProviderFetchContext) async throws -> ProviderFetchResult {
        guard
            let accessKeyID = ArkSettingsReader.accessKeyID(environment: context.env),
            let secretAccessKey = ArkSettingsReader.secretAccessKey(environment: context.env)
        else {
            throw ArkUsageError.missingCredentials
        }

        let credentials = VolcengineArkSigner.Credentials(
            accessKeyID: accessKeyID,
            secretAccessKey: secretAccessKey)
        let usage = try await ArkUsageFetcher.fetchUsage(credentials: credentials)
        return self.makeResult(
            usage: usage.toUsageSnapshot(),
            sourceLabel: "api")
    }

    func shouldFallback(on _: any Error, context _: ProviderFetchContext) -> Bool {
        false
    }
}
