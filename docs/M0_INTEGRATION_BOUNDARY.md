# M0 Ark Integration Boundary Map

> Status: REVIEWED / M0 COMPLETE (planning artifact retained for integration
> governance). This document maps
> the upstream extension points located during M0 and classifies every planned
> M1–M4 change as either an **Ark-owned new file** or a **required shared
> upstream integration point**. It exists to keep the upstream conflict surface
> small and explicit (AGENTS.md §4.1, docs/PRD.md FR9).

## Upstream baseline

- Baseline commit: `6ab1cbb7daee73b8ad531fbdd420e9aa6eb6d26b` (upstream/main == origin/main).
- `swift-crypto` is already an upstream dependency (resolved 3.15.1); the Ark
  signer will reuse it — no new dependency required.

## Located upstream extension points

| Concern | File | Notes |
|---|---|---|
| Provider ID enum | `Sources/CodexBarCore/Providers/Providers.swift` (`enum UsageProvider`, `enum IconStyle`) | Add `ark` cases. |
| Provider descriptor model | `Sources/CodexBarCore/Providers/ProviderDescriptor.swift` | `ProviderMetadata` / `ProviderBranding` / `ProviderDescriptor`. |
| Descriptor registry | Same file, `descriptorsByID` dict (bootstrap iterates `UsageProvider.allCases` and `preconditionFailure`s on any missing case) | Register `.ark: ArkProviderDescriptor.descriptor`. |
| Implementation registry | `Sources/CodexBar/Providers/Shared/ProviderImplementationRegistry.swift` | Add `case .ark:`. |
| Fetcher/parser pattern | `Sources/CodexBarCore/Providers/<Name>/<Name>UsageFetcher.swift` (e.g. Doubao) | `…UsageSnapshot.toUsageSnapshot()` → `UsageSnapshot`. |
| Multi-window usage model | `Sources/CodexBarCore/UsageFetcher.swift` (`UsageSnapshot`: `primary/secondary/tertiary` + `extraRateWindows: [NamedRateWindow]?`) | 4 AFP windows fit `primary` + `extraRateWindows` (or the three slots + one extra). |
| HMAC-SHA256 signing precedent | `Sources/CodexBarCore/Providers/Bedrock/BedrockAWSSigner.swift` | Structural blueprint for the Ark signer. |
| AK/SK credential storage and resolution | `CodexBarConfig.swift`, `CodexBarConfigStore.swift`, `ProviderConfigEnvironment.swift`, `Bedrock/BedrockSettingsStore.swift`, `Bedrock/BedrockCredentialResolver.swift` | Upstream precedent: store the pair in `ProviderConfig.apiKey` / `secretKey`, persist the resolved config with mode `0600`, and project it into the fetch environment at runtime. |
| Widget snapshot store | `Sources/CodexBarCore/WidgetSnapshot.swift` (`WidgetSnapshot.ProviderEntry`, `usageRows`) | Ark writes into existing snapshot path. |
| Widget provider picker/intent | `Sources/CodexBarWidget/CodexBarWidgetProvider.swift` (`enum ProviderChoice: AppEnum`, `caseDisplayRepresentations`, `init?(provider:)`) | Add `.ark` case + display representation; map instead of returning `nil`. |
| Widget UI | `Sources/CodexBarWidget/CodexBarWidgetViews.swift`, `BurnDownWidgetViews.swift` | Small/medium rendering. |
| Build/test | `swift build`; `make test` (→ `Scripts/test.sh`); `make check` (SwiftFormat + SwiftLint) | Upstream AGENTS.md rules apply. |

## Planned change classification (M1–M4)

### Ark-owned new files (low conflict risk)

- M1: `Sources/CodexBarCore/Providers/Ark/ArkProviderDescriptor.swift`
- M1: `Sources/CodexBarCore/Providers/Ark/ArkUsageFetcher.swift` (+ `ArkUsageSnapshot`)
- M1: `Sources/CodexBarCore/Providers/Ark/VolcengineArkSigner.swift` (promoted from this probe)
- M1: `Sources/CodexBarCore/Providers/Ark/ArkSettingsReader.swift` (AK/SK resolution)
- M1: `Sources/CodexBar/Providers/Ark/ArkProviderImplementation.swift`
- M1/M2: `Tests/CodexBarTests/ArkSignerTests.swift`, `ArkUsageParsingTests.swift`

### Required shared upstream integration points (documented conflict surface)

| # | File | Minimal edit | Conflict risk | Rollback |
|---|---|---|---|---|
| S1 | `Providers.swift` `UsageProvider` | add `case ark` | Low — additive enum case; upstream rarely reorders. | Remove case. |
| S2 | `Providers.swift` `IconStyle` | add `case ark` | Low — additive. | Remove case. |
| S3 | `ProviderDescriptor.swift` `descriptorsByID` | add `.ark:` entry | Low–Med — dict is hot upstream; new providers appended frequently, so merge conflicts are line-local. | Remove entry (bootstrap precondition then fails only if enum case remains). |
| S4 | `ProviderImplementationRegistry.swift` | add `case .ark:` | Low–Med — switch over provider; additive case. | Remove case. |
| S5 | `WidgetSnapshot.swift` | none expected (schema already generic via `usageRows`/windows) | Low — only touched if a new field is truly required. | Revert field. |
| S6 | `CodexBarWidgetProvider.swift` `ProviderChoice` | add `.ark` enum case, display rep, and `init?(provider:)` mapping | Med — this enum is edited on every widget-enabled provider; expect conflicts on upstream sync. | Return `nil` for `.ark` / remove case. |
| S7 | `CodexBarWidgetViews.swift` | minimal row wiring if needed | Low–Med. | Revert wiring. |
| S8 | `ProviderConfigEnvironment.swift` | add Ark-specific projection from `ProviderConfig.apiKey` / `secretKey` into the existing in-memory provider environment | Low–Med — shared credential router, but the edit follows the upstream Bedrock convention and remains an additive provider case/helper. | Remove the Ark case/helper; Ark then has no production credential projection. |
| S9 | `MenuBarMetricWindowResolver.swift` | add an Ark branch for `.automatic` that selects the highest-risk known AFP window and falls back to 5h, then Daily | Med — shared menu policy is provider-switched and frequently extended, but the Ark edit follows existing provider-specific resolver branches and remains line-local. | Remove the Ark branch; generic automatic behavior falls back to stable `primary` (5h), then `secondary` (Daily). |

All shared edits are additive registrations/wiring. None rename, move, or
reformat upstream code. Each milestone's PR must list the S# points it touches.

## Upstream synchronization, conflict review & rollback procedure

1. `git fetch upstream` (never modify the active feature branch during fetch).
2. Review upstream release notes/diffs affecting the files in the table above
   (especially S3, S4, S6).
3. Integrate the upstream update in a dedicated maintenance branch/PR — never
   mixed into an Ark feature PR (AGENTS.md §5).
4. Re-run `swift build`, `make test`, `make check`, Ark signer/parser tests, and
   widget snapshot/preview checks.
5. Report conflicts and behavior changes explicitly; do not auto-merge.
6. Rollback: because Ark logic is isolated in `Providers/Ark/*` new files, a
   revert of the S1–S9 additive edits fully removes Ark without touching other
   providers.

## M0-specific rollback

The M0 probe lives entirely in `Scripts/ark-probe/` as a standalone Swift
Package. It is not referenced by the root `Package.swift` or `Sources/`.
Deleting the directory (or reverting the M0 commit) removes it completely with
zero impact on the app.
