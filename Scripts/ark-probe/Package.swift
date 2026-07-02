// swift-tools-version:5.9
import PackageDescription

// Standalone, isolated M0 probe package for the Volcengine Ark Agent Plan
// `GetAFPUsage` OpenAPI. This package is intentionally NOT part of the root
// CodexBar Package.swift and does not import CodexBar/CodexBarCore. It exists
// only to validate the signing + response shape before any provider/widget
// integration (see docs/TASKS.md, M0).
//
// swift-crypto is pinned to the exact version the main project resolves
// (3.15.1) so the HMAC-SHA256 primitives match the eventual production signer.
// Package.resolved is committed alongside this manifest for reproducibility.
let package = Package(
    name: "ArkProbe",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(name: "ArkProbeKit", targets: ["ArkProbeKit"]),
        .executable(name: "ark-probe", targets: ["ArkProbe"]),
        .executable(name: "ark-probe-selftest", targets: ["ArkProbeSelfTest"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto", exact: "3.15.1"),
    ],
    targets: [
        .target(
            name: "ArkProbeKit",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
            ]),
        .executableTarget(
            name: "ArkProbe",
            dependencies: ["ArkProbeKit"]),
        .executableTarget(
            name: "ArkProbeSelfTest",
            dependencies: ["ArkProbeKit"]),
        .testTarget(
            name: "ArkProbeKitTests",
            dependencies: ["ArkProbeKit"]),
    ])
