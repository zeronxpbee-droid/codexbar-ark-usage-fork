import Foundation
import XCTest
@testable import ArkProbeKit

/// Tests for the M0 probe's static API configuration.
///
/// The production/default host was resolved by the credentialed live probe
/// recorded in docs/PROJECT_LOG.md Entry 015: `ark.cn-beijing.volcengineapi.com`
/// returned HTTP 200 while `ark.cn-beijing.volces.com` returned HTTP 401. These
/// assertions lock in that decision. (The signer/parser test vectors elsewhere
/// deliberately keep using `volces.com` — those are independent algorithm
/// vectors and do NOT represent the default host.)
final class ArkAPIConfigTests: XCTestCase {
    func test_defaultHostIsConfirmedControlPlaneHost() {
        XCTAssertEqual(ArkAPIConfig.defaultHost, .volcengineapi)
        XCTAssertEqual(
            ArkAPIConfig.defaultHost.rawValue,
            "ark.cn-beijing.volcengineapi.com")
    }

    func test_bothHostCasesRemainAvailableForOverride() {
        // The `--host` override depends on both cases existing.
        XCTAssertEqual(ArkAPIConfig.Host.volces.rawValue, "ark.cn-beijing.volces.com")
        XCTAssertEqual(ArkAPIConfig.Host.volcengineapi.rawValue, "ark.cn-beijing.volcengineapi.com")
        XCTAssertEqual(Set(ArkAPIConfig.Host.allCases.map(\.rawValue)), [
            "ark.cn-beijing.volces.com",
            "ark.cn-beijing.volcengineapi.com",
        ])
    }

    func test_staticApiFactsUnchanged() {
        XCTAssertEqual(ArkAPIConfig.action, "GetAFPUsage")
        XCTAssertEqual(ArkAPIConfig.version, "2024-01-01")
        XCTAssertEqual(ArkAPIConfig.service, "ark")
        XCTAssertEqual(ArkAPIConfig.region, "cn-beijing")
    }
}
