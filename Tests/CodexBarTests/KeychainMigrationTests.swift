import Testing
@testable import CodexBar

struct KeychainMigrationTests {
    @Test
    func `migration list covers known keychain items`() {
        let items = Set(KeychainMigration.itemsToMigrate.map(\.label))
        // M5A S23: fork-owned keychain services use com.zeronxpbee.codexbar-ark.
        let expected: Set = [
            "com.zeronxpbee.codexbar-ark:codex-cookie",
            "com.zeronxpbee.codexbar-ark:claude-cookie",
            "com.zeronxpbee.codexbar-ark:cursor-cookie",
            "com.zeronxpbee.codexbar-ark:factory-cookie",
            "com.zeronxpbee.codexbar-ark:minimax-cookie",
            "com.zeronxpbee.codexbar-ark:minimax-api-token",
            "com.zeronxpbee.codexbar-ark:augment-cookie",
            "com.zeronxpbee.codexbar-ark:copilot-api-token",
            "com.zeronxpbee.codexbar-ark:zai-api-token",
            "com.zeronxpbee.codexbar-ark:synthetic-api-key",
        ]

        let missing = expected.subtracting(items)
        #expect(missing.isEmpty, "Missing migration entries: \(missing.sorted())")
    }

    @Test
    func `migration items never reference official keychain services`() {
        // M5A S23: fork migration must not read official CodexBar keychain services.
        for item in KeychainMigration.itemsToMigrate {
            #expect(!item.service.contains("steipete"), "Fork migration references official service: \(item.service)")
        }
    }
}
