import Foundation
#if os(macOS)
import Security
#endif

public enum AppGroupSupport {
    // M5A S21: fork uses fixed App Group IDs; Team ID is no longer used for
    // group construction. defaultTeamID remains as an empty fallback for
    // resolvedTeamID() callers, but currentGroupID ignores it.
    public static let defaultTeamID = ""
    public static let teamIDInfoKey = "CodexBarTeamID"
    public static let legacyReleaseGroupID = "group.com.zeronxpbee.codexbar-ark"
    public static let legacyDebugGroupID = "group.com.zeronxpbee.codexbar-ark.debug"
    public static let widgetSnapshotFilename = "widget-snapshot.json"
    public static let migrationVersion = 1
    public static let migrationVersionKey = "appGroupMigrationVersion"
    private static let sharedDefaultsMigrationKeys = [
        "debugDisableKeychainAccess",
        "widgetSelectedProvider",
    ]

    public struct MigrationResult: Sendable {
        public enum Status: String, Sendable {
            case alreadyCompleted
            case targetUnavailable
            case noChangesNeeded
            case migrated
        }

        public let status: Status
        public let copiedSnapshot: Bool
        public let copiedDefaults: Int

        public init(status: Status, copiedSnapshot: Bool = false, copiedDefaults: Int = 0) {
            self.status = status
            self.copiedSnapshot = copiedSnapshot
            self.copiedDefaults = copiedDefaults
        }
    }

    public static func currentGroupID(for bundleID: String? = Bundle.main.bundleIdentifier) -> String {
        self.currentGroupID(teamID: self.resolvedTeamID(), bundleID: bundleID)
    }

    static func currentGroupID(teamID: String, bundleID: String?) -> String {
        // M5A S21: fork uses fixed App Group IDs; Team ID is not used.
        let base = "group.com.zeronxpbee.codexbar-ark"
        return self.isDebugBundleID(bundleID) ? "\(base).debug" : base
    }

    public static func resolvedTeamID(bundle: Bundle = .main) -> String {
        self.resolvedTeamID(
            infoDictionaryOverride: bundle.infoDictionary,
            bundleURLOverride: bundle.bundleURL)
    }

    static func resolvedTeamID(
        infoDictionaryOverride: [String: Any]?,
        bundleURLOverride: URL?) -> String
    {
        if let teamID = self.codeSignatureTeamID(bundleURL: bundleURLOverride) {
            return teamID
        }
        if let teamID = infoDictionaryOverride?[self.teamIDInfoKey] as? String,
           !teamID.isEmpty
        {
            return teamID
        }
        return self.defaultTeamID
    }

    public static func legacyGroupID(for bundleID: String? = Bundle.main.bundleIdentifier) -> String {
        self.isDebugBundleID(bundleID) ? self.legacyDebugGroupID : self.legacyReleaseGroupID
    }

    public static func sharedDefaults(
        bundleID: String? = Bundle.main.bundleIdentifier,
        fileManager: FileManager = .default)
        -> UserDefaults?
    {
        guard self.currentContainerURL(bundleID: bundleID, fileManager: fileManager) != nil else { return nil }
        return UserDefaults(suiteName: self.currentGroupID(for: bundleID))
    }

    public static func currentContainerURL(
        bundleID: String? = Bundle.main.bundleIdentifier,
        fileManager: FileManager = .default)
        -> URL?
    {
        #if os(macOS)
        fileManager.containerURL(forSecurityApplicationGroupIdentifier: self.currentGroupID(for: bundleID))
        #else
        nil
        #endif
    }

    public static func snapshotURL(
        bundleID: String? = Bundle.main.bundleIdentifier,
        fileManager: FileManager = .default,
        homeDirectory: URL = FileManager.default.homeDirectoryForCurrentUser)
        -> URL
    {
        if let container = self.currentContainerURL(bundleID: bundleID, fileManager: fileManager) {
            return container.appendingPathComponent(self.widgetSnapshotFilename, isDirectory: false)
        }

        let directory = self.localFallbackDirectory(fileManager: fileManager, homeDirectory: homeDirectory)
        return directory.appendingPathComponent(self.widgetSnapshotFilename, isDirectory: false)
    }

    public static func localFallbackDirectory(
        fileManager: FileManager = .default,
        homeDirectory _: URL = FileManager.default.homeDirectoryForCurrentUser)
        -> URL
    {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        let directory = base.appendingPathComponent("CodexBarArk", isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    public static func legacyContainerCandidateURL(
        bundleID: String? = Bundle.main.bundleIdentifier,
        homeDirectory: URL = FileManager.default.homeDirectoryForCurrentUser)
        -> URL
    {
        homeDirectory
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Group Containers", isDirectory: true)
            .appendingPathComponent(self.legacyGroupID(for: bundleID), isDirectory: true)
    }

    public static func migrateLegacyDataIfNeeded(
        bundleID: String? = Bundle.main.bundleIdentifier,
        standardDefaults: UserDefaults = .standard,
        fileManager: FileManager = .default,
        homeDirectory: URL = FileManager.default.homeDirectoryForCurrentUser,
        currentDefaultsOverride: UserDefaults? = nil,
        legacyDefaultsOverride: UserDefaults? = nil,
        currentSnapshotURLOverride: URL? = nil,
        legacySnapshotURLOverride: URL? = nil)
        -> MigrationResult
    {
        // M5A S21: fresh-state policy — no automatic config/App Group/defaults/
        // snapshot migration or copying. Fork starts with isolated state.
        // Method signature retained for compatibility; all parameters unused.
        _ = bundleID
        _ = standardDefaults
        _ = fileManager
        _ = homeDirectory
        _ = currentDefaultsOverride
        _ = legacyDefaultsOverride
        _ = currentSnapshotURLOverride
        _ = legacySnapshotURLOverride
        return MigrationResult(status: .noChangesNeeded)
    }

    private static func isDebugBundleID(_ bundleID: String?) -> Bool {
        guard let bundleID, !bundleID.isEmpty else { return false }
        return bundleID.contains(".debug")
    }

    private static func codeSignatureTeamID(bundleURL: URL?) -> String? {
        #if os(macOS)
        guard let bundleURL else { return nil }

        var staticCode: SecStaticCode?
        guard SecStaticCodeCreateWithPath(bundleURL as CFURL, SecCSFlags(), &staticCode) == errSecSuccess,
              let code = staticCode
        else {
            return nil
        }

        var infoCF: CFDictionary?
        guard SecCodeCopySigningInformation(
            code,
            SecCSFlags(rawValue: kSecCSSigningInformation),
            &infoCF) == errSecSuccess,
            let info = infoCF as? [String: Any],
            let teamID = info[kSecCodeInfoTeamIdentifier as String] as? String,
            !teamID.isEmpty
        else {
            return nil
        }
        return teamID
        #else
        _ = bundleURL
        return nil
        #endif
    }
}
