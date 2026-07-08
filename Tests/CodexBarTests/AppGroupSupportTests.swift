import Foundation
import Testing
@testable import CodexBarCore

struct AppGroupSupportTests {
    @Test
    func `fork app group identifiers are fixed and ignore team id`() {
        // M5A S21: fork uses fixed group IDs; Team ID is not used for construction.
        #expect(
            AppGroupSupport.currentGroupID(teamID: "Y5PE65HELJ", bundleID: "com.zeronxpbee.codexbar-ark")
                == "group.com.zeronxpbee.codexbar-ark")
        #expect(
            AppGroupSupport.currentGroupID(teamID: "ABCDE12345", bundleID: "com.zeronxpbee.codexbar-ark.debug")
                == "group.com.zeronxpbee.codexbar-ark.debug")
        #expect(
            AppGroupSupport.legacyGroupID(for: "com.zeronxpbee.codexbar-ark")
                == "group.com.zeronxpbee.codexbar-ark")
        #expect(
            AppGroupSupport.legacyGroupID(for: "com.zeronxpbee.codexbar-ark.debug")
                == "group.com.zeronxpbee.codexbar-ark.debug")
    }

    @Test
    func `resolved team id falls back to plist and then empty default`() {
        // M5A S21: defaultTeamID is empty; fork does not use Team ID for groups.
        #expect(
            AppGroupSupport.resolvedTeamID(
                infoDictionaryOverride: [AppGroupSupport.teamIDInfoKey: "ABCDE12345"],
                bundleURLOverride: nil) == "ABCDE12345")
        #expect(
            AppGroupSupport.resolvedTeamID(
                infoDictionaryOverride: nil,
                bundleURLOverride: nil) == AppGroupSupport.defaultTeamID)
        #expect(AppGroupSupport.defaultTeamID.isEmpty)
    }

    @Test
    func `fresh state migration does not copy snapshot`() throws {
        // M5A S21: fresh-state policy — no automatic snapshot/defaults migration.
        let fileManager = FileManager.default
        let root = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: root) }

        let standardSuite = "AppGroupSupportTests-standard-\(UUID().uuidString)"
        let currentSuite = "AppGroupSupportTests-current-\(UUID().uuidString)"
        let legacySuite = "AppGroupSupportTests-legacy-\(UUID().uuidString)"

        let standardDefaults = try #require(UserDefaults(suiteName: standardSuite))
        let currentDefaults = try #require(UserDefaults(suiteName: currentSuite))
        let legacyDefaults = try #require(UserDefaults(suiteName: legacySuite))
        standardDefaults.removePersistentDomain(forName: standardSuite)
        currentDefaults.removePersistentDomain(forName: currentSuite)
        legacyDefaults.removePersistentDomain(forName: legacySuite)

        legacyDefaults.set(true, forKey: "debugDisableKeychainAccess")
        legacyDefaults.set(UsageProvider.cursor.rawValue, forKey: "widgetSelectedProvider")

        let legacySnapshotURL = root.appendingPathComponent(
            "legacy/widget-snapshot.json",
            isDirectory: false)
        try fileManager.createDirectory(
            at: legacySnapshotURL.deletingLastPathComponent(),
            withIntermediateDirectories: true)
        try Data("legacy-snapshot".utf8).write(to: legacySnapshotURL)

        let currentSnapshotURL = root.appendingPathComponent("current/widget-snapshot.json", isDirectory: false)
        let result = AppGroupSupport.migrateLegacyDataIfNeeded(
            bundleID: "com.zeronxpbee.codexbar-ark",
            standardDefaults: standardDefaults,
            currentDefaultsOverride: currentDefaults,
            legacyDefaultsOverride: legacyDefaults,
            currentSnapshotURLOverride: currentSnapshotURL,
            legacySnapshotURLOverride: legacySnapshotURL)

        #expect(result.status == .noChangesNeeded)
        #expect(!result.copiedSnapshot)
        #expect(result.copiedDefaults == 0)
        #expect(!fileManager.fileExists(atPath: currentSnapshotURL.path))
        #expect(currentDefaults.object(forKey: "debugDisableKeychainAccess") == nil)
    }

    @Test
    func `fresh state migration does not copy defaults`() throws {
        // M5A S21: fresh-state policy — legacy defaults are never copied.
        let standardSuite = "AppGroupSupportTests-standard-existing-\(UUID().uuidString)"
        let currentSuite = "AppGroupSupportTests-current-existing-\(UUID().uuidString)"
        let legacySuite = "AppGroupSupportTests-legacy-existing-\(UUID().uuidString)"

        let standardDefaults = try #require(UserDefaults(suiteName: standardSuite))
        let currentDefaults = try #require(UserDefaults(suiteName: currentSuite))
        let legacyDefaults = try #require(UserDefaults(suiteName: legacySuite))
        standardDefaults.removePersistentDomain(forName: standardSuite)
        currentDefaults.removePersistentDomain(forName: currentSuite)
        legacyDefaults.removePersistentDomain(forName: legacySuite)

        currentDefaults.set(false, forKey: "debugDisableKeychainAccess")
        currentDefaults.set(UsageProvider.codex.rawValue, forKey: "widgetSelectedProvider")
        legacyDefaults.set(true, forKey: "debugDisableKeychainAccess")
        legacyDefaults.set(UsageProvider.cursor.rawValue, forKey: "widgetSelectedProvider")

        let result = AppGroupSupport.migrateLegacyDataIfNeeded(
            bundleID: "com.zeronxpbee.codexbar-ark",
            standardDefaults: standardDefaults,
            currentDefaultsOverride: currentDefaults,
            legacyDefaultsOverride: legacyDefaults)

        #expect(result.status == .noChangesNeeded)
        #expect(result.copiedDefaults == 0)
        #expect(!currentDefaults.bool(forKey: "debugDisableKeychainAccess"))
        #expect(currentDefaults.string(forKey: "widgetSelectedProvider") == UsageProvider.codex.rawValue)
    }

    @Test
    func `fork legacy group ids never point at official groups`() {
        // M5A S21: fork legacy candidates must never point at official groups.
        let releaseLegacy = AppGroupSupport.legacyGroupID(for: "com.zeronxpbee.codexbar-ark")
        let debugLegacy = AppGroupSupport.legacyGroupID(for: "com.zeronxpbee.codexbar-ark.debug")
        #expect(!releaseLegacy.contains("steipete"))
        #expect(!debugLegacy.contains("steipete"))
        #expect(releaseLegacy == "group.com.zeronxpbee.codexbar-ark")
        #expect(debugLegacy == "group.com.zeronxpbee.codexbar-ark.debug")
    }
}
