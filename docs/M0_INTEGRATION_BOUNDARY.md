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
| S6 (APPROVED — M4, Bee 2026-07-05) | `CodexBarWidgetProvider.swift` `ProviderChoice` | add `.ark` enum/display/provider mappings plus intent-specific options filtering so Ark is available only to Usage + static Switcher, not History/Metric | Med — shared enum and intent file, but existing raw values/configurations remain intact | Return `nil` for `.ark`; remove case and filters. |
| S7 (APPROVED — M4, Bee 2026-07-05) | `CodexBarWidgetViews.swift` | preserve S18 row reset/detail, select one highest-risk row for Ark small, render four stable compact Ark rows in medium, and leave non-Ark/large behavior unchanged | Med — shared small/medium/large Usage and Switcher layouts | Remove Ark-specific row projection/selection/presentation. |
| S8 | `ProviderConfigEnvironment.swift` | add Ark-specific projection from `ProviderConfig.apiKey` / `secretKey` into the existing in-memory provider environment | Low–Med — shared credential router, but the edit follows the upstream Bedrock convention and remains an additive provider case/helper. | Remove the Ark case/helper; Ark then has no production credential projection. |
| S9 | `MenuBarMetricWindowResolver.swift` | add an Ark branch for `.automatic` that selects the highest-risk known AFP window and falls back to 5h, then Daily | Med — shared menu policy is provider-switched and frequently extended, but the Ark edit follows existing provider-specific resolver branches and remains line-local. | Remove the Ark branch; generic automatic behavior falls back to stable `primary` (5h), then `secondary` (Daily). |
| S10 | `CodexBarWidgetProvider.swift` `ProviderChoice.init?(provider:)` | add only `case .ark: return nil` to close the exhaustive switch; do not add `ProviderChoice.ark` or a display representation | Low — one compile-only arm; Ark remains unsupported and unselectable in Widgets. | Remove the arm together with S1. |
| S11 | `CodexBarWidgetViews.swift` | add only exhaustive `case .ark` arms for `shortLabel` (`"Ark"`) and a static color; no layout or rendering wiring | Low — two compile-only arms with no new Widget entry path. | Remove both arms together with S1. |
| S12 | `Sources/CodexBarCore/Vendored/CostUsage/CostUsageScanner.swift` `loadDailyReportCancellable` | add only `.ark` to the existing unsupported-provider group that returns `emptyReport` | Low — one compiler-closure arm; Ark gains no local token-cost scanner. | Remove the arm together with S1. |
| S13 | `Sources/CodexBar/UsageStore.swift` provider debug-log switch | add only `.ark` to the existing unimplemented-debug group; do not add a probe or credential-bearing output | Low — one compiler-closure arm; Ark gains no debug-log implementation. | Remove the arm together with S1. |
| S14 | `Sources/CodexBarCore/Generated/CodexParserHash.generated.swift` | run `Scripts/regenerate-codex-parser-hash.sh` after S12 and commit only the generated hash update | Low — mechanical integrity companion to the vendored scanner change; no runtime logic. | Regenerate again after reverting S12. |
| S15 (APPROVED — M2, Bee 2026-07-03) | `Sources/CodexBar/MenuCardView.swift` `UsageMenuCardView.Model.metrics(input:)` | add one Ark router branch: `if input.provider == .ark { return ArkPopoverMetrics.metrics(input:snapshot:) }`; all Ark rendering logic stays in new Ark-owned `ArkPopoverMetrics.swift` | Low–Med — additive provider branch in shared menu-card router; Ark logic isolated | Remove the branch; Ark reverts to standard path (M1 behavior) |
| S17 (APPROVED — M3, Bee 2026-07-05) | `Sources/CodexBar/UsageStore+WidgetSnapshot.swift` `widgetUsageRows` | add one Ark routing branch to an Ark-owned four-window row mapper | Low–Med — additive branch in shared snapshot producer | Remove branch/helper; Ark falls back to primary/secondary rows |
| S18 (APPROVED — M3, Bee 2026-07-05; naming corrected by Codex audit Entry 054) | `Sources/CodexBarCore/WidgetSnapshot.swift` `WidgetUsageRowSnapshot` | add backward-compatible optional `resetsAt` and `detailText` fields | Medium — shared persisted snapshot schema | Remove optional fields and Ark mapping |

All shared edits are additive registrations/wiring. None rename, move, or
reformat upstream code. Each milestone's PR must list the S# points it touches.

## M2 Approved Shared Touchpoint — S15

### Problem

Ark's four AFP windows (5h / Daily / Weekly / Monthly) cannot be rendered
correctly through the standard `metrics(input:)` path with Ark-owned code
alone. Two blockers:

1. **Weekly (tertiary) row is gated by `supportsOpus`** (currently `false`).
   Setting `supportsOpus = true` would show the row, but `supportsOpus` is a
   **global switch** that also writes a tertiary row into the Widget snapshot
   (`UsageStore+WidgetSnapshot.swift:162`), which is explicitly deferred to
   M3 (S5/S10/S11 keep Ark out of the Widget). It also changes CLI tertiary
   display, the native menu bar tertiary label, and the Preferences tertiary
   option — all outside M2's popover scope. M2 must not touch the M3 Widget
   snapshot boundary.
2. **Quota is misrouted through `resetDescription`.** Ark's
   `rateWindow(from:)` packs `"used/quota"` into
   `RateWindow.resetDescription`. `UsageFormatter.resetLine` (lines 130-162)
   treats this field as reset text:
   - When `resetsAt` is present (the normal case), `resetDescription` is
     **ignored entirely** — quota never appears.
   - When `resetsAt` is absent, the quota string is rendered as
     `"Resets 100/500"`, which is semantically wrong.

   FR4 requires each row to show used / quota / remaining / reset as distinct
   values; the current standard path cannot express this.

### Approved S15 touch

| Aspect | Value |
|---|---|
| ID | S15 |
| File | `Sources/CodexBar/MenuCardView.swift` |
| Symbol | `UsageMenuCardView.Model.metrics(input:)` (line ~1095, between `.antigravity` and `.minimax` branches) |
| Minimal edit | One additive router branch: `if input.provider == .ark { return ArkPopoverMetrics.metrics(input: input, snapshot: snapshot) }` |
| Conflict risk | Low–Med — shared menu-card router, but additive branch only; all Ark logic stays in Ark-owned file |
| Rollback | Remove the branch; Ark reverts to standard path (M1 behavior: Weekly hidden, Monthly via extraRateWindows) |

### Ark-owned companion file

`Sources/CodexBar/Providers/Ark/ArkPopoverMetrics.swift` (new, Ark-owned):

- Builds the four `[Metric]` rows (5h / Daily / Weekly / Monthly) directly from
  `UsageSnapshot`, reusing `Metric`, `PercentStyle`, and `UsageFormatter`.
- **Quota detail (compatibility trade-off, Option A)**: `RateWindow` has no
  typed used/quota/remaining fields (only `usedPercent`, `resetsAt`,
  `resetDescription`, `windowMinutes`, `nextRegenPercent`). To avoid adding a
  new shared `RateWindow` field (which would require S16), the Ark-owned
  `rateWindow(from:)` mapper packs a **complete display string** into
  `RateWindow.resetDescription`, e.g. `"100 / 500 AFP · 400 remaining"` —
  containing used, quota, AND remaining (remaining = quota − used). This is a
  **mapper format change** from M1's `"used/quota"`: the `resetDescription`
  content is enriched so that `detailText` carries all three numeric values,
  satisfying FR4's four-value requirement (used/quota/remaining/reset)
  regardless of which percent-mode (`usageBarsShowUsed`) the user selected.
  `Metric.percent` still shows used% or remaining% (per `usageBarsShowUsed`),
  but `detailText` supplements with the full numeric trio. `ArkPopoverMetrics`
  reads `window.resetDescription` directly into `Metric.detailText` — treating
  it as **opaque display text, never parsing it back into numeric values**.
  `resetDescription` is semantically a reset field (per upstream comment:
  "Optional textual reset description, used by Claude CLI UI scrape"), but Ark
  reuses it as a quota-detail carrier because `RateWindow` has no dedicated
  quota slot. This borrow is documented and isolated to Ark's presentation
  layer; it does not leak into `resetText`.
- **Reset text**: `resetText` is generated ONLY from `resetsAt`, via
  `UsageFormatter.resetLine` invoked only when `resetsAt != nil`. When
  `resetsAt` is nil, `resetText` is nil — it never falls back to
  `resetDescription`, so quota text never appears as `"Resets …"`.
- Unknown/missing windows are omitted (guard `usedPercent`), never rendered as
  0%; Monthly `usageKnown=false` shows "Unavailable" via `statusText`.
- Error/stale states reuse the existing `Input.lastError` / `placeholder`
  paths — no parallel architecture.
- **Test coverage required**:
  - All four windows complete (used/quota/remaining/reset all present).
  - `usageBarsShowUsed = true` (percent shows used%) and `= false` (remaining%)
    — `detailText` must show the full numeric trio in both modes.
  - `resetsAt` present (`resetText` from `UsageFormatter.resetLine`) and absent
    (`resetText = nil`, no fallback to `resetDescription`).
  - Missing/partial windows (omitted, not rendered as 0%).
  - Monthly `usageKnown = false` (statusText = "Unavailable").
  - Error/stale states (lastError, placeholder paths).

### Why Ark-owned code alone is insufficient

`metrics(input:)` is the provider router entry point. Without an Ark branch,
Ark falls through to the standard path, which gates tertiary on
`supportsOpus` and reuses `RateWindow.resetDescription` for quota — both
broken for Ark's four-window model. An Ark-owned presentation file cannot
intercept the router without S15; it would be dead code.

### Out of scope for S15

- No change to `supportsOpus` (stays `false`).
- No change to Widget snapshot, CLI, menu bar, or Preferences tertiary paths.
- No change to `ArkProviderDescriptor` metadata fields beyond what M1 set.
- No change to `ArkUsageFetcher.toUsageSnapshot()` window-slot mapping (M1
  primary/secondary/tertiary/extraRateWindows assignment preserved). The
  Ark-owned `rateWindow(from:)` mapper IS modified: `resetDescription` content
  changes from M1's `"used/quota"` to a complete display string
  `"used / quota AFP · remaining remaining"` to satisfy FR4's four-value
  requirement. This is an Ark-owned file change, not a shared-file change.
- **No string parsing of `resetDescription`** to recover numeric used/quota
  values. The quota text is displayed as-is; any future need for numeric
  quota fields requires Option B (S16).

### Future alternative — Option B (not proposed for M2)

Add a typed Ark quota payload (e.g. `ArkQuotaDetail { used: Double?, quota:
Double?, remaining: Double? }`) attached to `UsageSnapshot` or `RateWindow`.
This would remove the `resetDescription` compatibility borrow but requires a
new shared `RateWindow` or `UsageSnapshot` field — a new **S16** touchpoint.
Defer to a future milestone if the compatibility trade-off proves insufficient.

## M3 Independent Preflight — Approved S17/S18

The generic snapshot producer already creates an Ark `ProviderEntry`, but its
default row mapper emits only primary/secondary because tertiary is gated by
`supportsOpus`; Monthly lives in `extraRateWindows` and is not represented in
`ProviderEntry`. Therefore four-window Ark snapshot integration requires S17.

The current row schema preserves only `id`, `title`, and `percentLeft`. If M3
must hand M4 reset timestamps and the complete M2 used/quota/remaining display
detail, S18 is also required. Bee approved the M4-ready S17+S18 contract on
2026-07-05.

S18 fields are `resetsAt: Date?` and `detailText: String?`, both
backward-compatible optional values. The original approval record used
singular `resetAt`; Codex corrected the unreleased field name during Entry 054
to match the existing `RateWindow.resetsAt` and upstream naming convention
before M3 merge. Ark maps the M2 opaque complete quota string directly to
`detailText` without parsing and maps the real window reset date to
`resetsAt`. S17 produces stable 5h/Daily/Weekly/Monthly rows without changing
`supportsOpus` or enabling Widget selection/UI.

## M4 Independent Preflight — Proposed S6/S7

M3 merge commit `9a24cf7356b6cace5fdbaeac5424609093245887`
provides the app-owned four-row snapshot contract. M4 needs no new snapshot or
network touchpoint, but it cannot be implemented safely by changing the old
Ark compile stub alone:

- `ProviderChoice` is shared by Usage, History, Metric, and the static
  switcher. A direct `.ark` case makes Ark selectable in History and Metric,
  even though Ark currently supplies neither daily history nor credits/cost
  metrics. Bee must choose an intent-specific Usage/Switcher restriction or
  explicitly accept that broader picker exposure.
- `WidgetUsageRow.rows` currently drops S18 `resetsAt` and `detailText`;
  `UsageBarRow` renders percentage only. S7 is required to consume M3 data.
- Ark currently receives no small/medium row limit. Small would render four
  rows; medium would render four percentage-only rows. Bee must choose the
  small-row policy and confirm the proposed medium compact layout before S7.

Bee approved the recommended policy on 2026-07-05:

- Ark is available in Usage + static Switcher only. History and Metric must
  exclude it through intent-specific options filtering; burn-down remains
  unchanged.
- Small selects the known row with the lowest remaining percentage, preserving
  stable order on ties and falling back to the first stable unavailable row.
- Medium retains all four available rows in stable order.
- Ark detail remains opaque display text; reset derives only from `resetsAt`.
- Compact fit fallbacks may omit lower-priority text but must not crowd or
  displace provider/updated state.

S6 and S7 are approved only within that policy and the exact file/test boundary
in `docs/TASKS.md`.

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
   revert of the applicable S1–S14 additive edits fully removes Ark without
   touching other providers.

## M0-specific rollback

The M0 probe lives entirely in `Scripts/ark-probe/` as a standalone Swift
Package. It is not referenced by the root `Package.swift` or `Sources/`.
Deleting the directory (or reverting the M0 commit) removes it completely with
zero impact on the app.
