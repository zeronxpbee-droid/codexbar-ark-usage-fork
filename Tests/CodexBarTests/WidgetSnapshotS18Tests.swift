import CodexBarCore
import Foundation
import Testing

/// S18 backward-compatibility tests for `WidgetUsageRowSnapshot` schema.
///
/// Verifies:
/// - Old JSON without `resetsAt`/`detailText` keys decodes successfully with
///   both new fields defaulting to `nil`.
/// - New rows with `resetsAt`/`detailText` survive an encode/decode round-trip.
/// - Rows with `nil` new fields omit the keys in encoded JSON (forward
///   compatibility with older decoders).
struct WidgetSnapshotS18Tests {
    // MARK: - Old JSON decodes without new fields

    @Test
    func oldJSONWithoutNewFieldsDecodesWithNilDefaults() throws {
        // JSON shaped like a pre-S18 snapshot: usageRows have only
        // id/title/percentLeft. This must decode without error.
        let json = Data("""
        {
          "entries": [
            {
              "provider": "codex",
              "updatedAt": "2026-01-01T00:00:00Z",
              "primary": null,
              "secondary": null,
              "tertiary": null,
              "usageRows": [
                {"id": "session", "title": "Session", "percentLeft": 90},
                {"id": "weekly", "title": "Weekly", "percentLeft": 80}
              ],
              "creditsRemaining": null,
              "codeReviewRemainingPercent": null,
              "tokenUsage": null,
              "dailyUsage": []
            }
          ],
          "enabledProviders": ["codex"],
          "usageBarsShowUsed": false,
          "generatedAt": "2026-01-01T00:00:00Z"
        }
        """.utf8)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let snapshot = try decoder.decode(WidgetSnapshot.self, from: json)

        let rows = try #require(snapshot.entries.first?.usageRows)
        #expect(rows.count == 2)
        #expect(rows[0].id == "session")
        #expect(rows[0].title == "Session")
        #expect(rows[0].percentLeft == 90)
        // S18 fields default to nil for old JSON.
        #expect(rows[0].resetsAt == nil)
        #expect(rows[0].detailText == nil)
        #expect(rows[1].resetsAt == nil)
        #expect(rows[1].detailText == nil)
    }

    // MARK: - Round-trip with new fields

    @Test
    func newFieldsSurviveRoundTrip() throws {
        let resetDate = Date(timeIntervalSince1970: 1_742_771_200)
        let row = WidgetSnapshot.WidgetUsageRowSnapshot(
            id: "ark-afp-5h",
            title: "5h",
            percentLeft: 80,
            resetsAt: resetDate,
            detailText: "100 / 500 AFP · 400 remaining")

        let entry = WidgetSnapshot.ProviderEntry(
            provider: .codex,
            updatedAt: Date(),
            primary: nil,
            secondary: nil,
            tertiary: nil,
            usageRows: [row],
            creditsRemaining: nil,
            codeReviewRemainingPercent: nil,
            tokenUsage: nil,
            dailyUsage: [])

        let snapshot = WidgetSnapshot(
            entries: [entry],
            enabledProviders: [.codex],
            usageBarsShowUsed: false,
            generatedAt: Date())

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(snapshot)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(WidgetSnapshot.self, from: data)

        let decodedRow = try #require(decoded.entries.first?.usageRows?.first)
        #expect(decodedRow.id == "ark-afp-5h")
        #expect(decodedRow.title == "5h")
        #expect(decodedRow.percentLeft == 80)
        #expect(decodedRow.resetsAt == resetDate)
        #expect(decodedRow.detailText == "100 / 500 AFP · 400 remaining")
    }

    // MARK: - Nil new fields omit keys in JSON

    @Test
    func nilNewFieldsOmitKeysInJSON() throws {
        let row = WidgetSnapshot.WidgetUsageRowSnapshot(
            id: "session",
            title: "Session",
            percentLeft: 90)

        let entry = WidgetSnapshot.ProviderEntry(
            provider: .codex,
            updatedAt: Date(timeIntervalSince1970: 1_742_771_200),
            primary: nil,
            secondary: nil,
            tertiary: nil,
            usageRows: [row],
            creditsRemaining: nil,
            codeReviewRemainingPercent: nil,
            tokenUsage: nil,
            dailyUsage: [])

        let snapshot = WidgetSnapshot(
            entries: [entry],
            enabledProviders: [.codex],
            usageBarsShowUsed: false,
            generatedAt: Date(timeIntervalSince1970: 1_742_771_200))

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(snapshot)

        // The encoded JSON must NOT contain "resetsAt" or "detailText" keys
        // when both are nil — this preserves forward compatibility with older
        // decoders that do not know about S18 fields.
        let jsonString = String(data: data, encoding: .utf8) ?? ""
        #expect(!jsonString.contains("resetsAt"))
        #expect(!jsonString.contains("detailText"))
    }
}
