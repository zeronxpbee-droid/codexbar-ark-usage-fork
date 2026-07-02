import Foundation
import Testing
@testable import CodexBarCore

/// Fetcher-level behavior for `ArkUsageFetcher.fetchUsage`, exercised end-to-end
/// through an in-memory `ProviderHTTPTransport` stub (no real network, no real
/// credentials). Covers the M1 Definition-of-Done error states: successful 200,
/// unauthorized (401/403), timeout/network, empty/unsupported (no windows),
/// malformed response, and cancellation. Also asserts that error material stays
/// redacted (never the secret, RequestId, or raw body).
struct ArkUsageFetcherTests {
    // FAKE credentials — never real.
    private static let credentials = VolcengineArkSigner.Credentials(
        accessKeyID: "AKFAKE000000000000EXAMPLE",
        secretAccessKey: "FAKESECRET0000000000000000000000EXAMPLE")

    private func transport(
        status: Int,
        body: String) -> ProviderHTTPTransportHandler
    {
        ProviderHTTPTransportHandler { request in
            let url = try #require(request.url)
            let response = try #require(HTTPURLResponse(
                url: url,
                statusCode: status,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]))
            return (Data(body.utf8), response)
        }
    }

    private func transport(
        throwing error: Error) -> ProviderHTTPTransportHandler
    {
        ProviderHTTPTransportHandler { _ in throw error }
    }

    // MARK: - Success

    @Test
    func `successful 200 parses all four AFP windows`() async throws {
        let body = """
        {
          "ResponseMetadata": { "RequestId": "REQ-SHOULD-NOT-SURFACE" },
          "Result": {
            "AFPFiveHour": { "Quota": 100, "Used": 25, "SubscribeTime": 1700000000000, "ResetTime": 1700018000000 },
            "AFPDaily":    { "Quota": 200, "Used": 40, "SubscribeTime": 1700000000000, "ResetTime": 1700086400000 },
            "AFPWeekly":   { "Quota": 700, "Used": 350, "SubscribeTime": 1700000000000, "ResetTime": 1700604800000 },
            "AFPMonthly":  { "Quota": 3000, "Used": 300, "SubscribeTime": 1700000000000, "ResetTime": 1702592000000 }
          }
        }
        """
        let now = Date(timeIntervalSince1970: 1_782_950_400)
        let snapshot = try await ArkUsageFetcher.fetchUsage(
            credentials: Self.credentials,
            now: now,
            session: transport(status: 200, body: body))

        #expect(snapshot.fiveHour?.usedPercent == 25)
        #expect(snapshot.daily?.usedPercent == 20)
        #expect(snapshot.weekly?.usedPercent == 50)
        #expect(snapshot.monthly?.usedPercent == 10)
        #expect(snapshot.updatedAt == now)
    }

    // MARK: - Missing credentials (short-circuits before any transport call)

    @Test
    func `missing credentials throws before any network call`() async {
        var touched = false
        let spy = ProviderHTTPTransportHandler { _ in
            touched = true
            throw URLError(.badServerResponse)
        }
        await #expect(throws: ArkUsageError.missingCredentials) {
            _ = try await ArkUsageFetcher.fetchUsage(
                credentials: .init(accessKeyID: "", secretAccessKey: ""),
                session: spy)
        }
        #expect(touched == false)
    }

    // MARK: - Unauthorized

    @Test
    func `unauthorized 401 surfaces a redacted api error`() async {
        let body = """
        {
          "ResponseMetadata": {
            "RequestId": "REQ-SENSITIVE",
            "Error": { "Code": "UnauthorizedOperation", "Message": "signature ak=\(Self.credentials.accessKeyID)" }
          }
        }
        """
        await #expect(throws: ArkUsageError.apiError(statusCode: 401, errorCode: "UnauthorizedOperation")) {
            _ = try await ArkUsageFetcher.fetchUsage(
                credentials: Self.credentials,
                session: transport(status: 401, body: body))
        }
    }

    @Test
    func `forbidden 403 error description never leaks credential or request id`() async {
        let secret = Self.credentials.secretAccessKey
        let body = """
        { "ResponseMetadata": { "RequestId": "REQ-XYZ", "Error": { "Code": "SignatureDoesNotMatch",
          "Message": "sk=\(secret)" } } }
        """
        do {
            _ = try await ArkUsageFetcher.fetchUsage(
                credentials: Self.credentials,
                session: transport(status: 403, body: body))
            Issue.record("expected an ArkUsageError")
        } catch let error as ArkUsageError {
            let description = error.errorDescription ?? ""
            #expect(description.contains("403"))
            #expect(description.contains("SignatureDoesNotMatch"))
            #expect(!description.contains(secret))
            #expect(!description.contains("REQ-XYZ"))
        } catch {
            Issue.record("unexpected error type: \(error)")
        }
    }

    // MARK: - Timeout / network

    @Test
    func `url error timeout maps to a network error`() async {
        do {
            _ = try await ArkUsageFetcher.fetchUsage(
                credentials: Self.credentials,
                session: transport(throwing: URLError(.timedOut)))
            Issue.record("expected an ArkUsageError")
        } catch let ArkUsageError.networkError(message) {
            // Carries only the URLError code, never anything sensitive.
            #expect(message.contains("\(URLError.timedOut.rawValue)"))
            #expect(!message.contains(Self.credentials.secretAccessKey))
        } catch {
            Issue.record("unexpected error: \(error)")
        }
    }

    @Test
    func `non url transport error maps to a generic network error`() async {
        struct Boom: Error {}
        await #expect(throws: ArkUsageError.networkError("Transport error.")) {
            _ = try await ArkUsageFetcher.fetchUsage(
                credentials: Self.credentials,
                session: transport(throwing: Boom()))
        }
    }

    // MARK: - Empty / unsupported

    @Test
    func `200 with no AFP windows maps to emptyOrUnsupported`() async {
        let body = #"{ "Result": { "SomethingElse": {} } }"#
        await #expect(throws: ArkUsageError.emptyOrUnsupported) {
            _ = try await ArkUsageFetcher.fetchUsage(
                credentials: Self.credentials,
                session: transport(status: 200, body: body))
        }
    }

    // MARK: - Malformed

    @Test
    func `200 with a non-json body maps to parseFailed`() async {
        await #expect(throws: ArkUsageError.parseFailed) {
            _ = try await ArkUsageFetcher.fetchUsage(
                credentials: Self.credentials,
                session: transport(status: 200, body: "not json at all"))
        }
    }

    // MARK: - Cancellation

    @Test
    func `cancellation is propagated, not swallowed as a network error`() async {
        let cancelling = ProviderHTTPTransportHandler { _ in throw CancellationError() }
        await #expect(throws: CancellationError.self) {
            _ = try await ArkUsageFetcher.fetchUsage(
                credentials: Self.credentials,
                session: cancelling)
        }
    }
}
