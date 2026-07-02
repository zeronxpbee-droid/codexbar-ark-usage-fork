import ArkProbeKit
import Foundation

/// Dependency-free self-test for the M0 Ark probe.
///
/// Why this exists: the reviewer's macOS Command Line Tools environment has no
/// `XCTest` / `swift-testing`, so `swift test` cannot run there. This executable
/// reproduces the same assertions using only the public API and Foundation, so
/// verification is possible with just:
///
///     swift build
///     swift run ark-probe-selftest
///
/// It prints one line per check and exits non-zero if ANY check fails. The
/// XCTest suite in Tests/ is kept for environments that do have a test runner;
/// this file is the portable evidence path.
///
/// All signature expectations are the values independently computed by
/// `reference/volc_sign_reference.py` (NOT by the Swift signer under test).
/// Because a plain `swift build` does not enable `@testable`, only the public
/// API is used here; the internal date/query helpers are exercised indirectly
/// through the public `sign(...)` result (the canonical request embeds both the
/// `x-date` stamp and the encoded, sorted query string).

// MARK: - Tiny assertion harness

final class Checker {
    private(set) var failures = 0
    private(set) var total = 0

    func check(_ name: String, _ condition: Bool) {
        total += 1
        if condition {
            print("PASS  \(name)")
        } else {
            failures += 1
            print("FAIL  \(name)")
        }
    }

    func equal<T: Equatable>(_ name: String, _ actual: T, _ expected: T) {
        total += 1
        if actual == expected {
            print("PASS  \(name)")
        } else {
            failures += 1
            print("FAIL  \(name)")
            print("        expected: \(expected)")
            print("        actual:   \(actual)")
        }
    }
}

let c = Checker()

// MARK: - Fixed, non-real signing inputs (mirror volc_sign_reference.py exactly)

let ak = "AKTESTEXAMPLE000000000"
let sk = "TESTSECRET0000000000000000000000"
let region = "cn-beijing"
let service = "ark"
let host = "ark.cn-beijing.volces.com"
// 2026-07-02T00:00:00Z
let fixedDate = Date(timeIntervalSince1970: 1_782_950_400)

let signed = VolcengineArkSigner.sign(
    VolcengineArkSigner.RequestInput(
        method: "POST",
        host: host,
        path: "/",
        query: [("Action", "GetAFPUsage"), ("Version", "2024-01-01")],
        contentType: "application/json",
        body: Data("{}".utf8)),
    credentials: .init(accessKeyID: ak, secretAccessKey: sk),
    region: region,
    service: service,
    date: fixedDate)

// Independently computed by volc_sign_reference.py.
let expectedBodyHash = "44136fa355b3678a1146ad16f7e8649e94fb4fc21fe77e8310c060f61caaff8a"
let expectedSignedHeaders = "content-type;host;x-content-sha256;x-date"
let expectedScope = "20260702/cn-beijing/ark/request"
let expectedSignature = "0b9d4a47c69fbb15135625cad9f6309b7e478bca238e816897505b9373186e96"
let expectedCanonical = [
    "POST",
    "/",
    "Action=GetAFPUsage&Version=2024-01-01",
    "content-type:application/json",
    "host:ark.cn-beijing.volces.com",
    "x-content-sha256:44136fa355b3678a1146ad16f7e8649e94fb4fc21fe77e8310c060f61caaff8a",
    "x-date:20260702T000000Z",
    "",
    "content-type;host;x-content-sha256;x-date",
    "44136fa355b3678a1146ad16f7e8649e94fb4fc21fe77e8310c060f61caaff8a",
].joined(separator: "\n")

print("== signer ==")
c.equal("bodyHash matches python reference", signed.headers["X-Content-Sha256"], expectedBodyHash)
c.equal("signedHeaders matches python reference", signed.signedHeaders, expectedSignedHeaders)
c.equal("credentialScope matches python reference", signed.credentialScope, expectedScope)
c.equal("canonicalRequest matches python reference", signed.canonicalRequest, expectedCanonical)
c.equal("signature matches python reference", signed.signature, expectedSignature)
// The x-date stamp inside the canonical request proves UTC date formatting.
c.check("canonicalRequest carries UTC x-date stamp", signed.canonicalRequest.contains("x-date:20260702T000000Z"))
c.check("authorization has HMAC-SHA256 prefix", signed.authorization.hasPrefix("HMAC-SHA256 "))
c.check(
    "authorization carries Credential scope",
    signed.authorization.contains("Credential=\(ak)/20260702/cn-beijing/ark/request"))
c.check(
    "authorization carries SignedHeaders",
    signed.authorization.contains("SignedHeaders=content-type;host;x-content-sha256;x-date"))
c.check("authorization carries Signature", signed.authorization.contains("Signature=\(expectedSignature)"))
c.check("secret never leaks into authorization", !signed.authorization.contains(sk))
// Session token support was removed for M0: no X-Security-Token header.
c.check("no X-Security-Token header emitted", signed.headers["X-Security-Token"] == nil)

// Query encoding + sorting (space escaped, keys sorted) via the public sign path.
let encoded = VolcengineArkSigner.sign(
    VolcengineArkSigner.RequestInput(
        host: host,
        query: [("b", "2"), ("a", "1 2")],
        body: Data("{}".utf8)),
    credentials: .init(accessKeyID: ak, secretAccessKey: sk),
    region: region,
    service: service,
    date: fixedDate)
c.check(
    "canonical query is sorted and space-encoded",
    encoded.canonicalRequest.contains("\na=1%202&b=2\n"))

// MARK: - Parser

print("== parser ==")
let topLevel = Data("""
{
  "AFPFiveHour": { "Quota": 100, "Used": 25, "SubscribeTime": 1782950400000, "ResetTime": 1782968400000 },
  "AFPDaily":    { "Quota": 1000, "Used": 300, "SubscribeTime": 1782950400000, "ResetTime": 1783036800000 },
  "AFPWeekly":   { "Quota": 5000, "Used": 1200, "SubscribeTime": 1782950400000, "ResetTime": 1783555200000 },
  "AFPMonthly":  { "Quota": 20000, "Used": 4500.5, "SubscribeTime": 1782950400000, "ResetTime": 1785542400000 }
}
""".utf8)

do {
    let r = try GetAFPUsageParser.parse(topLevel)
    c.equal("parse top-level: window count", r.windows.count, 4)
    c.equal("parse top-level: fiveHour.quota", r.fiveHour?.quota, 100)
    c.equal("parse top-level: fiveHour.remaining", r.fiveHour?.remaining, 75)
    c.equal("parse top-level: monthly.remaining (fractional)", r.monthly?.remaining, 15499.5)
    let expectedReset: Date? = Date(timeIntervalSince1970: 1_782_968_400)
    c.equal(
        "parse top-level: resetDate from epoch ms",
        r.fiveHour?.resetDate,
        expectedReset)
} catch {
    c.check("parse top-level did not throw", false)
}

let nested = Data("""
{ "ResponseMetadata": { "RequestId": "redact-me" },
  "Result": { "AFPWeekly": { "Quota": 5000, "Used": 1200 } } }
""".utf8)
do {
    let r = try GetAFPUsageParser.parse(nested)
    c.equal("parse nested Result: weekly.quota", r.weekly?.quota, 5000)
} catch {
    c.check("parse nested Result did not throw", false)
}

do {
    let r = try GetAFPUsageParser.parse(Data("{ \"AFPDaily\": { \"Quota\": 500 } }".utf8))
    c.equal("parse missing fields: window count", r.windows.count, 1)
    c.check("parse missing fields: used is nil", r.daily?.used == nil)
    c.check("parse missing fields: remaining is nil", r.daily?.remaining == nil)
    c.check("parse missing fields: resetDate is nil", r.daily?.resetDate == nil)
} catch {
    c.check("parse missing fields did not throw", false)
}

do {
    _ = try GetAFPUsageParser.parse(Data("{}".utf8))
    c.check("empty body throws noWindows", false)
} catch let e as GetAFPUsageParser.ParseError {
    c.equal("empty body throws noWindows", e, .noWindows)
} catch {
    c.check("empty body throws noWindows (wrong error)", false)
}

do {
    _ = try GetAFPUsageParser.parse(Data("not json".utf8))
    c.check("invalid JSON throws invalidJSON", false)
} catch let e as GetAFPUsageParser.ParseError {
    c.equal("invalid JSON throws invalidJSON", e, .invalidJSON)
} catch {
    c.check("invalid JSON throws invalidJSON (wrong error)", false)
}

// MARK: - Sanitized output

print("== sanitizer ==")
let envelope = Data("""
{
  "ResponseMetadata": { "RequestId": "SECRET-REQUEST-ID", "Account": "2100000000" },
  "Result": {
    "AFPFiveHour": { "Quota": 100, "Used": 25, "SubscribeTime": 1782950400000, "ResetTime": 1782968400000 }
  }
}
""".utf8)
do {
    let r = try GetAFPUsageParser.parse(envelope)
    let report = SanitizedUsageReport.render(r)
    c.check("report contains used=25", report.contains("used=25"))
    c.check("report contains quota=100", report.contains("quota=100"))
    c.check("report contains remaining=75", report.contains("remaining=75"))
    c.check("report contains 5h label", report.contains("5h"))
    c.check("report hides RequestId value", !report.contains("SECRET-REQUEST-ID"))
    c.check("report hides Account value", !report.contains("2100000000"))
    c.check("report hides RequestId key", !report.contains("RequestId"))
    c.check("report hides Account key", !report.contains("Account"))
} catch {
    c.check("sanitizer parse did not throw", false)
}

let shape = SanitizedUsageReport.renderSignedRequestShape(
    host: "ark.cn-beijing.volces.com",
    method: "POST",
    path: "/",
    query: [("Action", "GetAFPUsage"), ("Version", "2024-01-01")],
    signedHeaders: "content-type;host;x-content-sha256;x-date",
    bodyByteCount: 2)
c.check("request shape marks authorization redacted", shape.contains("redacted"))
c.check("request shape never prints signature=", !shape.lowercased().contains("signature="))

// MARK: - Non-2xx error diagnostic (fictional fixtures)

print("== error diagnostic ==")
let errorEnvelope = Data("""
{
  "ResponseMetadata": {
    "RequestId": "FAKE-REQ-ID-DO-NOT-LEAK-0001",
    "Error": {
      "Code": "SignatureDoesNotMatch",
      "Message": "signature mismatch; secret leak canary 9F3A"
    }
  }
}
""".utf8)

let extractedCode = ArkErrorResponse.extractErrorCode(from: errorEnvelope)
c.equal("error code: prefers ResponseMetadata.Error.Code", extractedCode, "SignatureDoesNotMatch")
c.equal(
    "error code: top-level Error fallback",
    ArkErrorResponse.extractErrorCode(from: Data("{ \"Error\": { \"Code\": \"AccessDenied\" } }".utf8)),
    "AccessDenied")
c.check("error code: nil when absent", ArkErrorResponse.extractErrorCode(from: Data("{}".utf8)) == nil)
c.check("error code: nil on invalid JSON", ArkErrorResponse.extractErrorCode(from: Data("not json".utf8)) == nil)

let diag = SanitizedUsageReport.renderErrorDiagnostic(
    httpStatus: 401,
    bodyByteCount: errorEnvelope.count,
    errorCode: extractedCode)
c.check("diagnostic shows httpStatus", diag.contains("httpStatus: 401"))
c.check("diagnostic shows bodyBytes", diag.contains("bodyBytes: \(errorEnvelope.count)"))
c.check("diagnostic shows errorCode", diag.contains("errorCode: SignatureDoesNotMatch"))
c.check("diagnostic hides RequestId value", !diag.contains("FAKE-REQ-ID-DO-NOT-LEAK-0001"))
c.check("diagnostic hides RequestId key", !diag.contains("RequestId"))
c.check("diagnostic hides Message text", !diag.contains("signature mismatch"))
c.check("diagnostic hides Message key", !diag.contains("Message"))
c.check("diagnostic hides secret canary", !diag.contains("9F3A"))

let diagUnavailable = SanitizedUsageReport.renderErrorDiagnostic(
    httpStatus: 401,
    bodyByteCount: 302,
    errorCode: ArkErrorResponse.extractErrorCode(
        from: Data("{ \"ResponseMetadata\": { \"RequestId\": \"FAKE-REQ-ID-0002\" } }".utf8)))
c.check("diagnostic marks <unavailable> when no code", diagUnavailable.contains("errorCode: <unavailable>"))
c.check("diagnostic (unavailable) still hides RequestId", !diagUnavailable.contains("FAKE-REQ-ID-0002"))

// MARK: - Summary

print("")
if c.failures == 0 {
    print("SELFTEST OK — \(c.total) checks passed")
    exit(0)
} else {
    print("SELFTEST FAILED — \(c.failures)/\(c.total) checks failed")
    exit(1)
}
