import ArkProbeKit
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// M0 Ark Agent Plan `GetAFPUsage` probe CLI.
///
/// Safety model (docs/TASKS.md M0, AGENTS.md §6):
///   - Credentials are read ONLY from environment variables:
///       VOLCENGINE_ACCESS_KEY_ID, VOLCENGINE_SECRET_ACCESS_KEY
///   - Default mode is DRY-RUN: the request is signed and its redacted shape is
///     printed, but NO network request is made.
///   - A live call requires the explicit `--live` flag AND both env vars. Live
///     runs must be authorized by Bee (M0 rule). Output is always redacted.
///   - No secret material or account identifiers are ever printed.
enum ArkProbeCLI {
    static func main() async {
        let args = Array(CommandLine.arguments.dropFirst())
        let live = args.contains("--live")
        let hostArg = Self.value(for: "--host", in: args)

        let host: ArkAPIConfig.Host
        if let hostArg, let parsed = ArkAPIConfig.Host(rawValue: hostArg) {
            host = parsed
        } else {
            host = ArkAPIConfig.defaultHost
        }

        let env = ProcessInfo.processInfo.environment
        let accessKeyID = env["VOLCENGINE_ACCESS_KEY_ID"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let secretKey = env["VOLCENGINE_SECRET_ACCESS_KEY"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !accessKeyID.isEmpty, !secretKey.isEmpty else {
            FileHandle.standardError.write(Data(
                """
                error: missing credentials. Set VOLCENGINE_ACCESS_KEY_ID and \
                VOLCENGINE_SECRET_ACCESS_KEY in the environment.

                """.utf8))
            exit(2)
        }

        let body = Data("{}".utf8)
        let query = ArkAPIConfig.queryItems()

        let input = VolcengineArkSigner.RequestInput(
            method: "POST",
            host: host.rawValue,
            path: "/",
            query: query,
            contentType: "application/json",
            body: body)

        let signed = VolcengineArkSigner.sign(
            input,
            credentials: .init(accessKeyID: accessKeyID, secretAccessKey: secretKey),
            region: ArkAPIConfig.region,
            service: ArkAPIConfig.service,
            date: Date())

        print(SanitizedUsageReport.renderSignedRequestShape(
            host: host.rawValue,
            method: input.method,
            path: input.path,
            query: query,
            signedHeaders: signed.signedHeaders,
            bodyByteCount: body.count))

        guard live else {
            print("")
            print("dry-run complete. No network request was made.")
            print("Re-run with --live (Bee-authorized) to call the API.")
            return
        }

        await Self.performLiveCall(host: host, query: query, body: body, headers: signed.headers)
    }

    private static func performLiveCall(
        host: ArkAPIConfig.Host,
        query: [(String, String)],
        body: Data,
        headers: [String: String]) async
    {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host.rawValue
        components.path = "/"
        components.queryItems = query.map { URLQueryItem(name: $0.0, value: $0.1) }

        guard let url = components.url else {
            FileHandle.standardError.write(Data("error: failed to build URL.\n".utf8))
            exit(3)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.timeoutInterval = 15
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            print("")
            print("HTTP \(status)")
            if status == 200 {
                let parsed = try GetAFPUsageParser.parse(data)
                print(SanitizedUsageReport.render(parsed))
            } else {
                // Do not echo the raw body (may carry account/request IDs).
                // Extract only the machine-readable error Code, if present.
                let errorCode = ArkErrorResponse.extractErrorCode(from: data)
                print(SanitizedUsageReport.renderErrorDiagnostic(
                    httpStatus: status,
                    bodyByteCount: data.count,
                    errorCode: errorCode))
            }
        } catch {
            FileHandle.standardError.write(Data("live call failed: \(error.localizedDescription)\n".utf8))
            exit(4)
        }
    }

    private static func value(for flag: String, in args: [String]) -> String? {
        guard let idx = args.firstIndex(of: flag), idx + 1 < args.count else { return nil }
        return args[idx + 1]
    }
}

await ArkProbeCLI.main()
