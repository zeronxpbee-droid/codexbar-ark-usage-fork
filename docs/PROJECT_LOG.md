# PROJECT_LOG.md — Historical Truth

> This file records what happened, what changed, what passed or failed, and what decisions were made. It does not own the current active goal; `docs/TASKS.md` does.
>
> **Archived history:** Entry 001–018 (M0 Ark probe phase, closed at Entry 018) have been moved to [`PROJECT_LOG_archive.md`](./PROJECT_LOG_archive.md) to keep this file small. This file holds active entries from **Entry 019 onward**.

## Entry 019 — M1 Gate Opened and Development Branch Created

Date: 2026-07-02
Actor: Bee (approval) + Codex (repository operation)
Type: Milestone Transition / Branch Setup
Status: CREATED / APPROVED

### Active Goal

M1 — Ark Provider Menu Bar MVP

### LOOP Result

Bee requested the prompt for Claude to enter the next development milestone.
Claude correctly stopped because both mandatory gates still showed M0/main.
Codex verified the merged M0 baseline, created the dedicated M1 branch, and
updated the complete task structure before any product code was written.

### Summary

- M0 PR #1 was already merged into `main`.
- Confirmed M0 merge baseline:
  `2ec7378bb981b393532d9506c2b8303a0889f63e`.
- Created and checked out:
  `feature/m1-ark-provider-menu-bar`.
- Advanced `docs/TASKS.md` from M0 to M1, including objective, allowed scope,
  forbidden scope, next developer task, and Definition of Done.
- M1 shared-file scope is restricted to S1–S4; M2 popover and M3–M4 Widget
  work remain forbidden.
- No product source, tests, README, remotes, upstream state, or credentials were
  changed.

### Decision

M1 is approved for Claude / GLM development on the assigned branch. Claude may
proceed only after LOOP and the documented secure-credential / usage-mapping
preflight. If either requires scope beyond S1–S4, development must stop for a
new Bee/Codex decision.

### Next Action

Codex commits this governance transition locally. Claude resumes on
`feature/m1-ark-provider-menu-bar`, produces the required pre-coding report,
and implements only the authorized M1 scope in additive local commits without
push.

## Entry 020 — M1 Credential Storage Boundary Aligned with Upstream

Date: 2026-07-02
Actor: Bee (decision) + Codex (governance update)
Type: Decision / Documentation
Status: APPROVED

### Active Goal

M1 — Ark Provider Menu Bar MVP

### LOOP Result

The smallest useful loop was limited to resolving the documented credential
blocker. Codex compared the fork rules, M1 scope, and upstream Bedrock
credential path; no product implementation was changed.

### Summary

- Bee chose upstream compatibility over an Ark-specific Keychain subsystem.
- Ark M1 will follow upstream Bedrock's static-credential pattern:
  - Access Key ID in `ProviderConfig.apiKey`.
  - Secret Access Key in `ProviderConfig.secretKey`.
  - Persistence through `CodexBarConfigStore` with POSIX mode `0600`.
  - Runtime projection through `ProviderConfigEnvironment`.
- Added S8 as the single additional M1 shared integration point required for
  that projection.
- Clarified that mode `0600` is filesystem-permission protection, not at-rest
  encryption.
- No source code, tests, credentials, generated config, or remotes were changed.

### Files Changed

- `AGENTS.md`
- `docs/PRD.md`
- `docs/TASKS.md`
- `docs/M0_INTEGRATION_BOUNDARY.md`
- `docs/PROJECT_LOG.md`

### Evidence

- Upstream `BedrockSettingsStore` stores its pair in
  `ProviderConfig.apiKey` / `secretKey`.
- Upstream `CodexBarConfigStore` serializes config to the resolved
  `config.json` and applies POSIX mode `0600`.
- Upstream `ProviderConfigEnvironment.applyBedrockOverrides` projects the pair
  into the provider's in-memory environment.
- Upstream documentation states that API keys are stored in the resolved
  CodexBar config (`~/.config/codexbar/config.json` for new installs, with the
  legacy path still supported) and the CLI writes the file with `0600`
  permissions.

### Issues / Risks

- The AK/SK pair is not encrypted at rest; the current user or a privileged
  process able to read the config file can obtain it.
- S8 is a shared upstream file and therefore adds one line-local conflict
  surface during future upstream synchronization.
- These risks are explicitly accepted to avoid a competing credential
  subsystem and reduce long-term fork divergence.

### Decision

The previous blanket ban on unencrypted local credential storage is narrowed:
the upstream CodexBar config store with enforced mode `0600` is the sole
approved static-provider exception. Custom plaintext credential files remain
forbidden. M1 may touch S1–S4 and S8 only.

### Next Action

Claude / GLM re-reads the updated governance documents, confirms the approved
S8 plan, and proceeds with the smallest M1 implementation loop. It must stop
again if implementation requires any shared touchpoint beyond S1–S4 and S8.

## Entry 021 — M1 Menu-Bar Window Resolver Boundary Approved

Date: 2026-07-02
Actor: Bee (decision) + Codex (governance update)
Type: Decision / Documentation
Status: APPROVED

### Active Goal

M1 — Ark Provider Menu Bar MVP

### LOOP Result

Claude correctly stopped after proving that generic automatic menu-bar
selection reads only the stable primary/secondary lanes and does not evaluate
all Ark AFP windows. The smallest compatible loop is one additive,
provider-specific resolver branch; no product code was changed in this
governance step.

### Summary

- Approved window-selection plan B, matching existing upstream
  provider-specific branches in `MenuBarMetricWindowResolver`.
- Ark keeps stable snapshot semantics instead of dynamically replacing
  `primary`:
  - 5h remains the primary lane.
  - Daily remains the secondary lane.
  - Weekly and Monthly retain stable provider-owned mappings.
- Added S9 for Ark `.automatic` menu-bar selection across known AFP windows.
- If no valid highest-risk candidate is available, S9 falls back to 5h and
  then Daily.
- No source code, tests, credentials, config, remotes, or branches were
  changed.

### Files Changed

- `docs/TASKS.md`
- `docs/M0_INTEGRATION_BOUNDARY.md`
- `docs/PROJECT_LOG.md`

### Evidence

- Generic `MenuBarMetricWindowResolver.automaticWindow` returns
  `snapshot.primary ?? snapshot.secondary` for providers without a dedicated
  branch.
- Existing providers including Antigravity, z.ai, Copilot, Cursor, and MiniMax
  already use provider-specific automatic resolver logic.
- Keeping time-window identity stable avoids leaking menu presentation policy
  into Ark's response-to-snapshot mapper and reduces later M2/Widget ambiguity.

### Issues / Risks

- S9 adds one shared upstream menu-policy touchpoint and may require a
  line-local conflict resolution when upstream adds or reorganizes provider
  branches.
- Highest-risk selection must ignore unknown/placeholder windows and be covered
  by focused tests, including the 5h-to-Daily fallback order.

### Decision

M1 may touch S1–S4, S8, and S9 only. The S9 resolver is preferred over
dynamically assigning the highest-risk window to `UsageSnapshot.primary`
because it follows upstream convention and preserves stable data semantics.

### Next Action

Claude / GLM performs its final pre-coding LOOP check and implements the
smallest complete M1 loop. It must stop and report again before touching any
shared file outside S1–S4, S8, and S9.

## Entry 022 — M1 Ark Core Implemented (S1–S4/S8/S9 partial); Widget Compile-Stub Blocker Reported

Date: 2026-07-02
Actor: Claude Developer (implementation + report) + Bee (decision)
Type: Development / Decision
Status: BLOCKED (coding paused pending Codex boundary registration)

### Active Goal

M1 — Ark Provider Menu Bar MVP

### LOOP Result

Applied LOOP as a checklist. Gather/Reason/Act produced the Ark-owned core and
the additive S1–S4/S8 registrations. During Verify (static blast-radius review
of the S1 enum change before any build), Claude found that S1 unavoidably breaks
the forbidden Widget target and stopped to report rather than silently editing
S5–S7 files. Recorder step captured the decision here and in TASKS.md.

### Summary

Implemented the Ark provider core and wired the approved shared touchpoints,
then hit a hard scope conflict and paused.

Completed this session (additive only, build/test deferred to Codex —
UNVERIFIED, no Swift toolchain in the dev environment):

- Ark-owned new files:
  - `Sources/CodexBarCore/Providers/Ark/VolcengineArkSigner.swift` (promoted from M0)
  - `Sources/CodexBarCore/Providers/Ark/ArkAPIConfig.swift`
  - `Sources/CodexBarCore/Providers/Ark/GetAFPUsageResponse.swift` (+ `AFPWindow.usedPercent`)
  - `Sources/CodexBarCore/Providers/Ark/ArkErrorResponse.swift`
  - `Sources/CodexBarCore/Providers/Ark/ArkSettingsReader.swift`
  - `Sources/CodexBarCore/Providers/Ark/ArkUsageFetcher.swift` (+ `ArkUsageSnapshot`, `ArkUsageError`)
  - `Sources/CodexBarCore/Providers/Ark/ArkProviderDescriptor.swift` (+ `ArkAPIFetchStrategy`)
  - `Sources/CodexBar/Providers/Ark/ArkProviderImplementation.swift`
  - `Sources/CodexBar/Providers/Ark/ArkSettingsStore.swift`
- Shared touchpoints applied:
  - S1 — `UsageProvider` `case ark` (Providers.swift)
  - S2 — `IconStyle` `case ark` (Providers.swift)
  - S3 — `descriptorsByID[.ark]` (ProviderDescriptor.swift)
  - S4 — `case .ark:` (ProviderImplementationRegistry.swift)
  - S8 — `applyArkOverrides` + `.ark` in `applyDedicatedProviderOverrides` (ProviderConfigEnvironment.swift):
    `apiKey → VOLCENGINE_ACCESS_KEY_ID`, `secretKey → VOLCENGINE_SECRET_ACCESS_KEY`
  - Also added `LogCategories.arkUsage`.
- Window mapping (方案 B): 5h → `primary`, Daily → `secondary`, Weekly →
  `tertiary`, Monthly → `extraRateWindows`. Windows with unknown usage are
  omitted (never rendered as 0%).

Not yet done (blocked): S9 resolver branch, M1 tests, local commit.

### Blocker (STOP-and-report per TASKS.md item 5)

S1 (`UsageProvider.ark`) is mandatory for M1 but breaks the **CodexBarWidget**
target, which contains 3 exhaustive `switch` statements over `UsageProvider`
with no `default:`:

1. `Sources/CodexBarWidget/CodexBarWidgetProvider.swift:55` — `ProviderChoice.init?(provider:)`
2. `Sources/CodexBarWidget/CodexBarWidgetViews.swift:271` — `shortLabel`
3. `Sources/CodexBarWidget/CodexBarWidgetViews.swift:801` — provider color switch

Without an `.ark` arm in each, the whole workspace fails to compile. Widget
files are M1-forbidden (S5–S7). `IconStyle` (S2) is safe — dispatched via a
`styleKeyLookup[style] ?? 0` dictionary, not an exhaustive switch. All
`CLIDiagnoseCommand.swift` provider switches have `default:` and are safe.

### Decision (Bee, 2026-07-02)

Option 1 approved IN PRINCIPLE, but coding STAYS PAUSED until Codex formally
registers the compile-stub boundary. When unpaused, ONLY these 3 additive lines
are permitted:

1. `ProviderChoice.init?(provider:)` → `case .ark: return nil` (Ark not
   selectable in the M1 widget).
2. `shortLabel` → `case .ark: "Ark"`.
3. Widget color switch → `case .ark:` static color.

Forbidden even under this exception: a new `ProviderChoice.ark` enum case,
`DisplayRepresentation`, Widget picker entry, snapshot logic, or any real Widget
display logic (those remain M3–M4). This is a compile-only stub exception, not a
widening of M1 feature scope.

### Files Changed (working tree only — NOT committed)

- Ark-owned new files and S1–S4/S8 edits listed above.
- `docs/PROJECT_LOG.md` (this entry).
- `docs/TASKS.md` (status update — pending in the same paused batch).

### Evidence

- Static exhaustiveness review: `CodexBarWidgetProvider.swift:55–112` covers
  every provider through `.zed` with explicit arms and no `default:`.
- `CodexBarWidgetViews.swift` `shortLabel` (271–326) and color switch (801–908)
  likewise terminate at `.zed` with no `default:`.
- `IconRenderer.swift:802` `styleKeyLookup` is an `[IconStyle: Int]` dictionary
  with `?? 0` fallback — S2 needs no downstream edits.
- No build/test run: the dev environment has no Swift toolchain; Codex must
  compile and run `swift build` / `make test` / `make check`.

### Issues / Risks

- Coding is paused mid-M1. S9, tests, and the additive local commit are pending
  the boundary registration.
- The 3 Widget stub lines are the minimum to keep the workspace compiling; they
  add one shared conflict surface (S6 partial) beyond the originally scoped
  S1–S4/S8/S9, hence the escalation.

### Next Action

Codex: register/confirm the compile-stub boundary for the 3 Widget lines. Once
confirmed, Claude will (1) add the 3 stub lines exactly as specified, (2)
implement the S9 Ark highest-risk resolver branch, (3) write M1 tests, (4) run
static checks, update this log + TASKS.md, and create a single additive local
commit (no push). Build/test verification remains Codex's responsibility.

## Entry 023 — M1 Widget Compile-Only Boundary Registered

Date: 2026-07-02
Actor: Bee (approval) + Codex (boundary registration)
Type: Decision / Documentation
Status: APPROVED / RESUMED

### Active Goal

M1 — Ark Provider Menu Bar MVP

### LOOP Result

Codex verified Claude's blast-radius report against the three exhaustive Widget
switches. Because S1 cannot compile without explicit Ark arms, the smallest
useful loop is a three-line compiler-closure exception that keeps all Widget
capability disabled.

### Summary

- Registered S10 for one compile-only arm in
  `CodexBarWidgetProvider.swift`:
  `ProviderChoice.init?(provider: .ark)` returns `nil`.
- Registered S11 for two compile-only arms in
  `CodexBarWidgetViews.swift`: short label `"Ark"` and a static color.
- Ark remains absent from `ProviderChoice`, `caseDisplayRepresentations`,
  supported-provider filtering, Widget snapshot behavior, and Widget layout.
- M3–M4 remain the exclusive milestones for functional Ark Widget support.
- Existing uncommitted Ark implementation files were not edited by Codex.

### Files Changed

- `docs/TASKS.md`
- `docs/M0_INTEGRATION_BOUNDARY.md`
- `docs/PROJECT_LOG.md`

### Evidence

- `ProviderChoice.init?(provider:)`, `ProviderSwitchChip.shortLabel`, and
  `WidgetColors.color(for:)` exhaustively switch over `UsageProvider` without
  `default` clauses.
- Adding S1 `UsageProvider.ark` therefore requires explicit cases for the
  Widget target to compile.
- Returning `nil` from `ProviderChoice.init?(provider: .ark)` prevents Ark
  from entering the Widget provider picker or supported-provider list.

### Issues / Risks

- S10/S11 touch Widget-owned files earlier than the functional Widget
  milestones and add small line-local upstream conflict surfaces.
- Any change beyond the exact three arms is out of M1 scope and requires a new
  stop-and-report decision.

### Decision

M1 is resumed with shared touchpoints S1–S4 and S8–S11. S10/S11 are
compiler-closure exceptions only and do not authorize Widget functionality.

### Next Action

Claude resumes the paused implementation: add exactly the S10/S11 arms,
complete S9 and targeted tests, run available static checks, update the M1
implementation record/status, and create the additive local commit without
push.

## Entry 024 — M1 Ark Core Complete (S1–S4/S8–S11 + Tests); Build/Test Deferred to Codex

Date: 2026-07-02
Actor: Claude Developer
Type: Development
Status: IMPLEMENTED / UNVERIFIED

### Active Goal

M1 — Ark Provider Menu Bar MVP

### LOOP Result

Applied LOOP strictly (production-impacting, multi-file). Gather: re-read the
approved touchpoint list and the blueprint tests (ProviderConfigEnvironment,
MenuBarMetricWindowResolver, CodexOAuthCredentialsStorePermissions). Act: added
S9 and the five targeted test files. Verify: confirmed every referenced public
API (`ArkSettingsReader` keys + `hasCredentials`, `AFPWindow`/`RateWindow`/
`NamedRateWindow`/`UsageSnapshot` inits, `CodexBarConfigStore` save/load,
`ArkErrorResponse.extractErrorCode`) exists with the signatures the tests call,
and that `git diff --check` is clean with all tracked edits additive (+57/−0).
Record: this entry. Stop: no Swift toolchain in the workspace, so build/test
execution is the safe restart boundary handed to Codex.

### Summary

- S9: `MenuBarMetricWindowResolver.automaticWindow` now routes `.ark` to a new
  `mostConstrainedArkWindow` helper that picks the highest used-% lane across
  5h `primary`, Daily `secondary`, Weekly `tertiary`, and the Monthly extra
  window (`ark-afp-monthly`, only when `usageKnown`), falling back to 5h then
  Daily. Additive branch; no other provider behavior changed.
- S10/S11 Widget compile-only stubs confirmed present (Ark → `nil` in
  `ProviderChoice.init?`; `"Ark"` short label; static color). No functional
  Widget capability added.
- Added five Swift Testing suites (no network, no real credentials):
  - `ArkVolcengineSignerTests` — pins the production signer against the M0
    independent Python reference vectors (canonical request, scope terminator
    `request`, signature, Authorization; secret never leaked in any header).
  - `ArkGetAFPUsageParsingTests` — parser (nested/top-level, noWindows,
    invalidJSON, non-positive quota → unknown) and 方案 B AFP→UsageSnapshot
    mapping (5h/Daily/Weekly→lanes, Monthly→extra, unknown omitted).
  - `ArkMenuBarMetricWindowResolverTests` — S9 highest-risk selection + 5h/
    Daily fallback + unknown-monthly exclusion.
  - `ArkCredentialProjectionTests` — S8 AK/SK projection into distinct
    `VOLCENGINE_*` keys (never concatenated) + config-store round-trip with
    0600 permissions (FAKE credentials; does not assert creds absent from JSON).
  - `ArkRedactionTests` — `ArkUsageError` descriptions and `ArkErrorResponse`
    extraction never surface the secret, RequestId, Message, or raw body.

### Files Changed

- `Sources/CodexBar/MenuBarMetricWindowResolver.swift` (S9, +21)
- `Sources/CodexBar/Providers/Shared/ProviderImplementationRegistry.swift` (S4, +1)
- `Sources/CodexBarCore/Config/ProviderConfigEnvironment.swift` (S8, +27)
- `Sources/CodexBarCore/Logging/LogCategories.swift` (+1)
- `Sources/CodexBarCore/Providers/ProviderDescriptor.swift` (S3, +1)
- `Sources/CodexBarCore/Providers/Providers.swift` (S1/S2, +2)
- `Sources/CodexBarWidget/CodexBarWidgetProvider.swift` (S10, +1)
- `Sources/CodexBarWidget/CodexBarWidgetViews.swift` (S11, +3)
- New Ark core: `Sources/CodexBarCore/Providers/Ark/` (ArkAPIConfig,
  ArkErrorResponse, ArkProviderDescriptor, ArkSettingsReader, ArkUsageFetcher,
  GetAFPUsageResponse, VolcengineArkSigner) and
  `Sources/CodexBar/Providers/Ark/` (ArkProviderImplementation, ArkSettingsStore)
- New tests: `Tests/CodexBarTests/Ark{VolcengineSigner,GetAFPUsageParsing,
  MenuBarMetricWindowResolver,CredentialProjection,Redaction}Tests.swift`

### Evidence

- `git diff --check` clean; tracked diffstat +57/−0 across exactly the eight
  approved shared files.
- API-signature verification (see LOOP Result) done by reading each source of
  truth in this session.
- `swift build` / `swift test` NOT run — no Swift 6 toolchain in the Linux
  workspace. Compilation and test execution are DEFERRED to Codex.

### Issues / Risks

- Implementation is UNVERIFIED until Codex builds and runs the suite; a
  signature or exhaustiveness miss would only surface at compile time.
- Test signature vectors are pinned to the M0 reference; if the production
  signer diverges the signer suite will fail (intended).

### Decision

M1 developer scope (S1–S4, S8–S11 + tests) is code-complete. Correctness is
gated on Codex build/test verification.

### Next Action

Codex builds `CodexBar`/`CodexBarCore`/`CodexBarWidget`, runs the five Ark test
suites, and records PASS/FAIL. No push/branch/PR/merge by Claude.

## Entry 025 — M1 Ark Provider First Audit

Date: 2026-07-02
Actor: Codex
Type: Review
Status: FAIL

### Active Goal

M1 — Ark Provider Menu Bar MVP

### LOOP Result

Reviewed developer commit
`535444380909cc47a48c401e22474efab5e41669` against the M1 Definition of
Done, approved S1–S4/S8–S11 boundary, upstream rules, credential policy, and
complete M1 diff from merged M0 baseline `2ec7378b`. Required evidence was
scope isolation, clean Git state, full-target compilation, targeted Ark tests,
credential/error redaction, stable window mapping, and non-functional Widget
stubs. No product source was modified by Codex.

### Summary

The Ark-owned signer, parser, credential projection, stable window mapping,
S9 resolver, and S10/S11 Widget stubs are directionally consistent with the
approved design. The commit nevertheless fails M1 acceptance because adding
`UsageProvider.ark` left two additional exhaustive switches unhandled. The
first is a compiler-confirmed Core failure; the second is an App switch with
the same exhaustive shape and no `default`. The submitted fetcher tests also
do not execute the HTTP/network error paths required by the M1 Definition of
Done.

Claude's temporary-index commit left the real Git index stale, producing false
deleted/untracked status entries. Codex verified every working-tree blob
against commit `53544438`, removed the unowned zero-byte lock, and synchronized
only the real index to HEAD with `git read-tree --reset HEAD`. No working-tree
file or developer commit was changed; the repository is clean.

### Evidence

- Reviewed commit: `535444380909cc47a48c401e22474efab5e41669`.
- Parent: governance commit `dcd7d9ce21cf699b9aa02eb07aee138827881a8f`.
- `git diff --check dcd7d9ce..53544438`: PASS.
- Complete M1 diff from `2ec7378b` contains only approved governance,
  Ark-owned files, tests, and documented shared touchpoints.
- Targeted added-line secret scan found only deliberately fake test
  credentials and documented environment-variable names.
- Credential storage/projection follows the approved upstream-compatible
  `ProviderConfig.apiKey` / `secretKey` + mode `0600` design.
- Direct `swift build` initially reached an environment-only Sparkle binary
  artifact download stall. Codex independently downloaded the official 2.9.3
  artifact and verified its SHA-256 exactly matched Sparkle's package manifest.
- To separate that dependency-download issue from source compilation, Codex
  built an archive of exact commit `53544438` in `/private/tmp` with only the
  optional Sparkle package/dependency removed from the temporary manifest.
  `CodexBarCore` compilation then failed at
  `Sources/CodexBarCore/Vendored/CostUsage/CostUsageScanner.swift:437`:
  `switch must be exhaustive`, with compiler note `add missing case: '.ark'`.
- Static inspection found the same missing `.ark` arm in the no-default debug
  switch at `Sources/CodexBar/UsageStore.swift:1050`.
- In the temporary diagnostic copy only, adding both unsupported-feature arms
  allowed compilation to proceed through Ark Core and into the App target;
  no repository source was changed.
- The five submitted Ark suites contain signer, parser/mapping, resolver,
  credential/config, and redaction assertions, but none defines a mock
  `ProviderHTTPTransport` or calls `ArkUsageFetcher.fetchUsage`.
- Tests were not run because the submitted source does not compile.
- `make check` could not be started after the build failure because the local
  tool approval service reported its own usage limit. This is not counted as a
  source failure, but must be rerun on the corrective commit.

### Findings

1. **[P1] Close the Core cost-scanner exhaustive switch.**
   `CostUsageScanner.loadDailyReportCancellable` does not handle `.ark`, so
   `CodexBarCore` cannot compile. Ark has no local token-cost scanner in M1;
   add it to the existing unsupported-provider group that returns
   `emptyReport`. This is a proposed new shared compile-closure touchpoint
   **S12** and requires Bee/Codex boundary approval before implementation.

2. **[P1] Close the App debug-log exhaustive switch.**
   `UsageStore`'s provider debug-log switch also omits `.ark` and has no
   `default`, so the App will fail after finding 1 is fixed. Add Ark only to
   the existing unimplemented-debug group; do not add credential values or a
   real debug probe. This is proposed shared touchpoint **S13** and likewise
   requires boundary approval.

3. **[P1] Add fetcher-level mock transport/error-state tests.**
   The M1 Definition of Done requires tested unauthorized, timeout/network,
   empty/unsupported, unknown/malformed, and safe error behavior. Current tests
   construct error enums and test the parser but never execute
   `ArkUsageFetcher.fetchUsage`. Add an in-memory `ProviderHTTPTransport` stub
   covering at least successful 200, 401/403 redacted error, timeout/network,
   no-windows/unsupported, malformed response, and cancellation behavior. No
   real network or credentials are permitted.

4. **[P2] Supply or reference a real Ark provider icon resource.**
   `ArkProviderDescriptor` references `ProviderIcon-ark`, but
   `Sources/CodexBar/Resources/ProviderIcon-ark.svg` does not exist. As a
   result, `ProviderBrandIcon.image(for: .ark)` returns `nil`, leaving Ark
   without its configured brand icon in Settings/brand-icon display modes.
   Add an Ark-owned SVG resource (with provenance recorded) or use an existing
   accurate resource, and extend the provider-icon resource test.

### Decision

FAIL. Do not push or open the M1 PR for commit `53544438`. The developer must
submit an additive corrective commit; no amend, rebase, or reset of the
developer commit is authorized.

S12/S13 are not yet authorized implementation scope. They are proposed as the
minimum compile-only closures forced by S1, analogous to S10/S11. Bee must
approve them before Claude touches those shared files.

### Next Action

Bee approves or rejects proposed S12/S13. If approved, Codex updates the
integration boundary and M1 allowed scope. Claude then fixes findings 1–4,
runs `swift build`, the focused Ark suites, `make test`, and `make check` where
available, updates the implementation record/status, and creates a new local
commit without push. Codex re-audits the additive correction.

## Entry 026 — Bee Approves M1 S12/S13 Compile Closures

Date: 2026-07-03
Actor: Bee + Codex
Type: Decision / Documentation
Status: APPROVED

### Active Goal

M1 — Ark Provider Menu Bar MVP

### LOOP Result

The smallest corrective loop is to authorize only the two shared exhaustive
switch arms proven necessary by Entry 025. Product behavior, Widget scope, and
unrelated providers remain unchanged. Rollback removes the two arms together
with S1.

### Summary

Bee explicitly approved S12 and S13. Codex registered both touchpoints in the
integration boundary and added them to the M1 developer scope.

### Files Changed

- `docs/TASKS.md`
- `docs/M0_INTEGRATION_BOUNDARY.md`
- `docs/PROJECT_LOG.md`

### Evidence

- A native `swift build`, rerun after Bee allowed SwiftPM's macOS Keychain
  request and Sparkle downloaded successfully, failed at
  `CostUsageScanner.swift:437` with `switch must be exhaustive` and compiler
  guidance to add `.ark`.
- Entry 025 records the second no-default exhaustive switch in
  `UsageStore.swift`.
- Bee approved both proposed compile-closure touchpoints on 2026-07-03.

### Decision

- S12 authorizes only adding `.ark` to the existing unsupported cost-scanner
  group returning `emptyReport`.
- S13 authorizes only adding `.ark` to the existing unimplemented debug-log
  group, without a real debug probe or credential-bearing output.
- Neither touchpoint authorizes new Ark product behavior, unrelated refactors,
  or functional Widget work.

### Next Action

Claude fixes all four Entry 025 findings in an additive local commit, runs the
required build/tests/checks, updates the implementation record, and does not
push. Codex then re-audits the correction.

## Entry 027 — M1 Corrective Commit (S12/S13 + Fetcher Tests + Ark Icon)

Date: 2026-07-03
Actor: Claude Developer
Type: Development
Status: IMPLEMENTED / UNVERIFIED

### Active Goal

M1 — Ark Provider Menu Bar MVP

### LOOP Result

Applied LOOP strictly (production-impacting correction after an audit FAIL).
Gather: read Entry 025 findings 1–4 and Entry 026's S12/S13 authorization, then
located every exhaustive `switch provider` over `UsageProvider` that still
omitted `.ark`. Reason: the CLI's three provider switches all carry `default:`
(safe); only the Core cost-scanner and App debug-log switches were real
blockers, exactly matching the audit. Act: added the two approved compile
closures, the fetcher error-state suite, and the missing icon. Verify: `git
diff --check` clean; source diff is +7/−3 across four files plus two new files;
XML well-formed; Resources bundled via `.process`. Record: this entry. Stop:
build/test still owned by Codex (no Swift toolchain here).

### Summary

- Finding 1 (S12): `CostUsageScanner.loadDailyReportCancellable` now lists
  `.ark` in the existing unsupported-provider group returning `emptyReport`.
  Compile-only; Ark has no local token-cost scanner in M1.
- Finding 2 (S13): `UsageStore`'s provider debug-log switch now lists `.ark` in
  the existing unimplemented-debug group, with a matching
  `unimplementedDebugLogMessages[.ark]` entry. No real probe, no credential
  output.
- Finding 3: added `Tests/CodexBarTests/ArkUsageFetcherTests.swift`, an
  in-memory `ProviderHTTPTransportHandler`-driven suite exercising
  `ArkUsageFetcher.fetchUsage`: 200 success (four windows), missing-credentials
  short-circuit (transport never touched), 401/403 redacted API error,
  timeout/network + generic transport error, no-windows → emptyOrUnsupported,
  malformed body → parseFailed, and cancellation propagation. Redaction
  re-asserted at the fetcher layer (secret/RequestId never surface). To enable
  value-based `#expect(throws:)`, `ArkUsageError` gained `Equatable` — matching
  the `BedrockUsageError`/`OpenCodeGoLocalUsageError` blueprints; behavior-
  neutral since all associated values are already Equatable. Ark-owned file,
  not a shared touchpoint.
- Finding 4: added `Sources/CodexBar/Resources/ProviderIcon-ark.svg`, an
  ORIGINAL monochrome template glyph (a generic stylized "A"), explicitly NOT
  derived from any Volcengine trademark; provenance recorded in the file
  header. Extended `ProviderIconResourcesTests` to include the `ark` slug; the
  existing all-providers icon test now also covers it.

### Files Changed

- `Sources/CodexBarCore/Vendored/CostUsage/CostUsageScanner.swift` (S12, +2/−1)
- `Sources/CodexBar/UsageStore.swift` (S13, +3/−1)
- `Sources/CodexBarCore/Providers/Ark/ArkUsageFetcher.swift` (+Equatable, +1/−1)
- `Sources/CodexBar/Resources/ProviderIcon-ark.svg` (new)
- `Tests/CodexBarTests/ArkUsageFetcherTests.swift` (new)
- `Tests/CodexBarTests/ProviderIconResourcesTests.swift` (+1)

### Evidence

- `git diff --check` clean; source diffstat +7/−3 across four tracked files,
  two new files added.
- CLI provider switches at `CLIDiagnoseCommand.swift` lines 240/274/292 all
  have `default:` — confirmed no `.ark` arm required there.
- `ProviderIcon-ark.svg` validated as well-formed XML; `Sources/CodexBar/
  Resources` is bundled through `.process("Resources")` in `Package.swift`.
- `swift build` / `swift test` / `make check` NOT run — no Swift 6 toolchain in
  the workspace. Execution deferred to Codex.

### Issues / Risks

- Correctness remains UNVERIFIED until Codex compiles and runs the suite; a
  missed exhaustive switch or a Swift Testing signature issue would only surface
  at build time.
- The Ark icon is a placeholder mark; a designer-provided asset can replace it
  later without affecting M1 scope.

### Decision

All four Entry 025 findings are addressed additively within the approved
S12/S13 boundary. No amend/reset/rebase/push of `53544438` or this correction.

### Next Action

Codex re-audits the additive correction: `swift build`, the focused Ark suites,
`make test`, and `make check` where available; records PASS/FAIL.

## Entry 028 — M1 Corrective Commit Re-Audit

Date: 2026-07-03
Actor: Codex
Type: Review
Status: FAIL

### Active Goal

M1 — Ark Provider Menu Bar MVP

### LOOP Result

Re-audited additive corrective commit
`c6c60cfcf0b12a227e25b9d46e8322c52e3eee9a` against Entry 025, approved
S12/S13 scope, M1 Definition of Done, and upstream build/test/check rules.
Required evidence was a clean Git state, exact committed-tree provenance,
full app compilation, all Ark suites, and `make check`. Codex changed no
product or test source in the repository.

### Summary

The S12/S13 compiler closures work: the complete app now builds successfully.
The new fetcher tests, however, do not compile under Swift 6 because they
mutate a captured local variable inside a `Sendable` closure. An earlier Ark
credential test also fails to unwrap the optional result of
`CodexBarConfigStore.load()`. Finally, S12 changes a vendored cost-scanner
source covered by the repository's generated parser hash, so `make check`
requires the generated hash companion to be refreshed.

Claude again committed through a temporary index, leaving the real index and
two zero-byte lock files stale. Codex verified every changed working-tree blob
against `c6c60cfc`, removed only the orphan locks, and synchronized only the
real index to HEAD with `git read-tree --reset HEAD`. No working-tree file or
developer commit was changed.

### Evidence

- Reviewed commit: `c6c60cfcf0b12a227e25b9d46e8322c52e3eee9a`.
- Parent: governance commit
  `4a112ca6ea25543058be16aecba444b97eb580ac`.
- Every one of the eight changed files matched its committed blob exactly.
- `git diff --check 4a112ca6..c6c60cfc`: PASS.
- Native `swift build`: PASS (`Build complete!`, 30.10 seconds).
- Native `swift test --filter Ark`: FAIL during test-target compilation:
  - `ArkUsageFetcherTests.swift:72`: mutation of captured variable `touched`
    in concurrently executing `Sendable` closure.
  - `ArkCredentialProjectionTests.swift:76`: optional
    `CodexBarConfig?` must be unwrapped before calling `providerConfig`.
- `make check`: FAIL because
  `Sources/CodexBarCore/Generated/CodexParserHash.generated.swift` is stale;
  expected hash `cc33c89a2253a9a3`, committed hash
  `2e350d981415198e`.
- `make test` was not run after the same test target had already failed to
  compile.
- In a `/private/tmp` archive of exact commit `c6c60cfc`, Codex changed only
  the two failing test expressions and regenerated the parser hash. The
  diagnostic `swift test --filter Ark` then passed all 40 tests in six suites.
  These diagnostic edits were not applied to the repository.
- Static review found the corrective production changes limited to approved
  S12/S13 arms, Ark-owned error conformance/icon, and tests. No credentials,
  real network calls, functional Widget work, or unrelated-provider behavior
  were added.

### Findings

1. **[P1] Make the missing-credentials transport spy Swift 6 safe.**
   `ArkUsageFetcherTests` must not mutate a captured local `Bool` from the
   `ProviderHTTPTransportHandler`'s `Sendable` closure. Use an existing
   concurrency-safe test helper or record a test issue directly if the
   transport is unexpectedly invoked.

2. **[P1] Unwrap the config-store load result before provider lookup.**
   `CodexBarConfigStore.load()` returns `CodexBarConfig?`. Store the throwing
   result first, require the optional value, then call
   `providerConfig(for: .ark)`.

3. **[P1] Refresh the generated Codex parser hash required by S12.**
   Run `Scripts/regenerate-codex-parser-hash.sh` and commit the generated
   one-line hash update. Because this is an additional shared upstream-owned
   file, it is proposed as **S14**: a mechanical generated-integrity companion
   to S12, with no runtime behavior. Bee must approve S14 before implementation.

### Decision

FAIL. Do not push or open the M1 PR for `c6c60cfc`. The app compilation
blockers from Entry 025 are closed, but the required Ark tests and repository
checks do not compile/pass in the submitted tree.

S14 is not yet authorized. It is the smallest shared-file consequence of S12:
regenerate only `CodexParserHash.generated.swift`; no vendored parser logic or
unrelated generated file may be changed.

### Next Action

Bee approves or rejects proposed S14. If approved, Codex registers S14 in the
integration boundary and M1 scope. Claude then creates one additive local
commit fixing findings 1–3, runs `swift build`, `swift test --filter Ark`,
`make test`, and `make check`, updates the implementation record, and does not
push. Codex re-audits the result.

## Entry 029 — Bee Approves M1 S14 Generated Hash Touchpoint

Date: 2026-07-03
Actor: Bee + Codex
Type: Decision / Documentation
Status: APPROVED

### Active Goal

M1 — Ark Provider Menu Bar MVP

### LOOP Result

The smallest corrective loop is to authorize the one generated integrity file
required by the already-approved S12 scanner change. S14 carries no product
behavior and must be produced only by the repository's regeneration script.

### Summary

Bee explicitly approved S14. Codex registered the generated parser-hash file
in the integration boundary and added it to the M1 corrective scope.

### Files Changed

- `docs/TASKS.md`
- `docs/M0_INTEGRATION_BOUNDARY.md`
- `docs/PROJECT_LOG.md`

### Evidence

- `make check` at commit `c6c60cfc` reported the committed parser hash
  `2e350d981415198e` was stale and expected `cc33c89a2253a9a3`.
- Running `Scripts/regenerate-codex-parser-hash.sh` in Codex's temporary exact
  commit copy produced that expected value.
- Bee approved the proposed S14 touchpoint on 2026-07-03.

### Decision

S14 authorizes only the generated one-line hash update produced by
`Scripts/regenerate-codex-parser-hash.sh` after S12. It does not authorize
manual generated-file edits, additional cost-scanner logic, unrelated
generated files, or product behavior.

### Next Action

Claude fixes the two Entry 028 test compilation findings, runs the approved
hash regeneration script, then creates one additive local commit. Claude runs
`swift build`, `swift test --filter Ark`, `make test`, and `make check`, records
the evidence, and does not push. Codex re-audits the result.

## Entry 030 — M1 Corrective Commit 2 (Test Compile Fixes + S14 Hash)

Date: 2026-07-03
Actor: Claude Developer
Type: Development
Status: IMPLEMENTED / UNVERIFIED

### Active Goal

M1 — Ark Provider Menu Bar MVP

### LOOP Result

Applied LOOP strictly (production-impacting correction after a second audit
FAIL). Gather: read Entry 028's three findings and Entry 029's S14
authorization. Reason: findings 1–2 are test-only Swift 6 compile fixes;
finding 3 is a mechanical regenerated-hash refresh whose expected value Codex
already computed (`cc33c89a2253a9a3`). Act: fixed both tests and ran the
approved regeneration script. Verify: `git diff --check` clean; the regen
script's `check` mode now passes; diff limited to three files with no product-
behavior change. Record: this entry. Stop: `swift build` / `swift test` /
`make test` / `make check` still owned by Codex — no Swift toolchain here.

### Summary

- Finding 1 (test): `ArkUsageFetcherTests.missing credentials throws before any
  network call` no longer mutates a captured `Bool` inside the
  `ProviderHTTPTransportHandler` `Sendable` closure. The spy now calls
  `Issue.record(...)` directly if it is ever invoked, which is concurrency-safe
  and preserves the test's intent (transport must not run when credentials are
  missing). Removed the now-redundant `#expect(touched == false)`.
- Finding 2 (test): `ArkCredentialProjectionTests` round-trip now unwraps the
  optional `CodexBarConfigStore.load()` result via
  `try #require(try store.load())` before calling `providerConfig(for: .ark)`.
- Finding 3 / S14 (generated): ran `Scripts/regenerate-codex-parser-hash.sh` to
  refresh `Sources/CodexBarCore/Generated/CodexParserHash.generated.swift` from
  the stale `2e350d981415198e` to `cc33c89a2253a9a3` — exactly the value Codex
  reported as expected. This is the mechanical integrity companion to S12; no
  vendored parser logic or other generated file was touched.

### Files Changed

- `Tests/CodexBarTests/ArkUsageFetcherTests.swift` (Finding 1, +3/−2)
- `Tests/CodexBarTests/ArkCredentialProjectionTests.swift` (Finding 2, +2/−1)
- `Sources/CodexBarCore/Generated/CodexParserHash.generated.swift` (S14, +1/−1)

### Evidence

- `git diff --check` clean; diff limited to the three files above.
- `Scripts/regenerate-codex-parser-hash.sh write` → "Updated ... to
  cc33c89a2253a9a3"; `... check` → "Codex parser hash is current
  (cc33c89a2253a9a3)".
- Regenerated value matches Entry 028's expected `cc33c89a2253a9a3`.
- `swift build` / `swift test --filter Ark` / `make test` / `make check` NOT run
  — no Swift 6 toolchain in the workspace (`swift: command not found`).
  Execution deferred to Codex, which previously confirmed all 40 Ark tests pass
  in six suites after exactly these two test edits plus this hash regeneration.

### Issues / Risks

- Correctness remains UNVERIFIED here until Codex compiles and runs the suite,
  though Codex's Entry 028 diagnostic run already validated identical edits in a
  temporary copy.

### Decision

All three Entry 028 findings are addressed additively within the approved
S12/S13/S14 boundary. No amend/reset/rebase/push.

### Next Action

Codex re-audits the additive correction: `swift build`, `swift test --filter
Ark`, `make test`, `make check`; records PASS/FAIL.

## Entry 031 — PROJECT_LOG Archive Split (Entry 001–018 → Archive)

Date: 2026-07-03
Actor: Claude (preparation) + Bee (approval) + Codex (verification / repository operation)
Type: Documentation / Governance
Status: COMPLETED / APPROVED

### Active Goal

M1 — Ark Provider Menu Bar MVP

### LOOP Result

Applied LOOP as a documentation-governance loop. Done Contract: move closed-
milestone entries verbatim to an archive file, keep active entries in place,
touch no code and no TASKS.md status, no git history rewrite. Verification =
line/byte accounting and segment-by-segment diffs proving zero content loss.
Recorded here as this entry.

### Summary

`docs/PROJECT_LOG.md` had grown to 34 headings / 2397 lines / 96,848 bytes
(~24K tokens per full read) and was growing monotonically. Bee flagged the
token cost. Split at the natural milestone boundary: **Entry 001–018** cover
the M0 Ark probe phase, explicitly closed at Entry 018 ("M0 Documentation
Drift Corrected and Final Audit Closed"); **Entry 019 onward** are the active
M1 phase.

Entry 001–018 were moved verbatim into a new file
`docs/PROJECT_LOG_archive.md`. The main log keeps Entry 019–030 plus the Entry
Template, and its header now carries a pointer to the archive. No entry text
was rewritten — only relocated. Entry 031 records this governance operation
without creating a competing Active Goal.

### Files Changed

- `docs/PROJECT_LOG.md` — trimmed to Entry 019+; header pointer added; this
  Entry 031 appended. 2397 lines / 96,848 bytes → roughly 45 KB including this
  entry.
- `docs/PROJECT_LOG_archive.md` — NEW; header + Entry 001–018 (1399 body lines).
- `docs/PROJECT_LOG.md.bak` — temporary untracked pre-split backup removed
  after Bee confirmed the archive should be retained and committed.

### Evidence

- Original accounting: header 4 + archived Entry body 1399 + inter-entry
  separator 1 + retained body 993 = 2397 lines (exact). The separator was
  omitted at the archive EOF because it belongs between Entry 018 and 019, not
  to either Entry.
- Segment-by-segment `diff` against commit `132cad87` confirms the archived
  Entry 001–018 body, retained Entry 019–030 body, and Entry Template are
  byte-for-byte unchanged.
- Archive size is 1403 lines / 55,610 bytes. Main-file full-read cost drops
  from roughly 24K to roughly 10.5K tokens (~57%).
- Entry numbering continuous: archive 001–018, main 019–030 then 031.
- The temporary backup blob exactly matched the committed pre-split log
  (`5b814d12685f63f15d922c1507a64cdb355b4b0c`); Git remains the rollback
  source after the redundant backup is removed.

### Issues / Risks

- Purely mechanical line-range split; low risk.
- Future archives must preserve the same milestone-boundary and verbatim-diff
  checks.

### Decision

Archive closed M0 entries; keep active M1 entries in the working log. Adopt the
convention: when a milestone closes, its entries may be moved to the archive
file, leaving the active log lean.

### Next Action

Resume the pending M1 corrective-commit re-audit. Future milestone closures
follow the same archive pattern.

## Entry 032 — M1 Corrective Commit 2 Re-Audit

Date: 2026-07-03
Actor: Codex
Type: Review
Status: FAIL

### Active Goal

M1 — Ark Provider Menu Bar MVP

### LOOP Result

Re-audited developer commit
`132cad877ef6afb6909a3aa92cc60cd247ca62fd` against Entry 028's three
findings, the approved S14 boundary, the M1 Definition of Done, the complete
M1 diff from merge baseline `2ec7378b`, and the upstream build/test/check
rules. The loop required exact additive ancestry, clean repository state,
full-target compilation, all Ark tests, full test/check gates, credential and
error redaction, no real network tests, and no M2 or functional Widget scope.
Codex modified no product or test source.

### Summary

All three Entry 028 findings are correctly closed: both Swift 6 test compile
errors are fixed, and S14 is the exact generated one-line parser-hash update.
The app and all targeted Ark tests now compile and pass. Acceptance still
fails because the repository's pinned SwiftFormat check reports nine Ark
source/test files requiring formatting.

The full `make test` gate also encountered a reproducible but intermittent
Xcode toolchain failure while compiling the external `KeyboardShortcuts`
package's `#Preview` declarations: `PreviewsMacros.SwiftUIView` could not be
loaded. A direct `swift test list` succeeded once without any source change,
then the original `make test` failed again at the same external macro. No M1
commit changes `Package.swift`, `Package.resolved`, the test harness, or that
dependency, so this is recorded as an environment/toolchain blocker rather
than an Ark source finding.

### Files Reviewed

- Corrective commit scope:
  - `Sources/CodexBarCore/Generated/CodexParserHash.generated.swift`
  - `Tests/CodexBarTests/ArkCredentialProjectionTests.swift`
  - `Tests/CodexBarTests/ArkUsageFetcherTests.swift`
  - `docs/TASKS.md`
  - `docs/PROJECT_LOG.md`
- Complete M1 diff from `2ec7378b` through `132cad87`, including Ark-owned
  files and approved S1–S4/S8–S14 shared integration points.

### Evidence

- Ancestry: `132cad87` has direct parent `8912c2af`; no amend, reset, rebase,
  or developer-history rewrite was found.
- `git diff --check 8912c2af..132cad87`: PASS.
- Corrective diff contains exactly the five expected files above.
- S14 changes only `CodexParserHash.generated.swift` from
  `2e350d981415198e` to `cc33c89a2253a9a3`.
- Native `swift build`: PASS (`Build complete!`, 10.65 seconds), including
  App, CLI, Core, and Widget products.
- Native `swift test --filter Ark`: PASS, 40 tests in 6 suites.
- `make test`: FAIL twice during `swift test list` because the external
  `KeyboardShortcuts/Sources/KeyboardShortcuts/Recorder.swift` could not load
  Xcode's `PreviewsMacros` plugin. A direct `swift test list` passed once
  between those failures without a source change, reproducing toolchain
  instability.
- `make check`: FAIL. All preceding script checks passed, including
  documentation links, shell tests, test-sharding tests, and
  `Codex parser hash is current (cc33c89a2253a9a3)`. SwiftFormat then reported
  `9/1226 files require formatting`.
- The nine failing files are:
  - `Sources/CodexBarCore/Providers/Ark/ArkAPIConfig.swift`
  - `Sources/CodexBarCore/Providers/Ark/ArkErrorResponse.swift`
  - `Sources/CodexBarCore/Providers/Ark/GetAFPUsageResponse.swift`
  - `Sources/CodexBarCore/Providers/Ark/VolcengineArkSigner.swift`
  - `Tests/CodexBarTests/ArkCredentialProjectionTests.swift`
  - `Tests/CodexBarTests/ArkMenuBarMetricWindowResolverTests.swift`
  - `Tests/CodexBarTests/ArkRedactionTests.swift`
  - `Tests/CodexBarTests/ArkUsageFetcherTests.swift`
  - `Tests/CodexBarTests/ArkVolcengineSignerTests.swift`
- Security scan and static review found only explicitly fake/reference
  credentials in tests. Production logging emits HTTP status, validated error
  code, numeric `URLError`, or fixed categories only; it does not emit AK/SK,
  Authorization, signatures, RequestId, raw bodies, or account identifiers.
- Ark fetcher tests use only in-memory `ProviderHTTPTransportHandler` stubs;
  no real network test was added.
- Widget edits remain exactly S10/S11 compiler closures. Ark still maps to
  `nil` in `ProviderChoice`, so no picker, snapshot, intent, or visible Widget
  capability was introduced.
- Worktree and real index were clean before the audit record was written.

### Finding

1. **[P1] Make all nine Ark files pass the repository-pinned SwiftFormat
   check.** Apply formatting only to the files listed above. Do not change
   runtime semantics, test expectations, shared S1–S14 integration files,
   generated files, dependencies, Widget behavior, or unrelated providers.
   Do not run a repository-wide formatter that creates unrelated churn.

### Issues / Risks

- Full-suite execution evidence remains unavailable because the Xcode
  `PreviewsMacros` plugin failure prevents `make test` from reaching its test
  groups. Codex must rerun the exact command on the next correction; if the
  same external failure persists, it remains an explicitly reproduced
  environment blocker under the M1 Definition of Done.

### Decision

FAIL. Do not push or open the M1 PR. Commit `132cad87` closes Entry 028 but
does not satisfy the mandatory `make check` gate.

No new shared touchpoint approval is required. Claude may submit one additive,
formatting-only corrective commit limited to the nine Ark-owned files plus
`docs/TASKS.md` and `docs/PROJECT_LOG.md`. No amend, reset, rebase, push, or PR
is authorized.

### Next Action

Claude applies only the pinned formatter changes, runs `git diff --check`,
`swift build`, `swift test --filter Ark`, `make test`, and `make check`,
records exact outcomes, and creates one additive local commit. Codex then
re-audits.

## Entry 033 — M1 Corrective Commit 3 (Formatting-Only)

Date: 2026-07-03
Actor: Claude Developer
Type: Development
Status: IMPLEMENTED / UNVERIFIED

### Active Goal

M1 — Ark Provider Menu Bar MVP

### LOOP Result

Applied LOOP strictly (production-impacting correction after Entry 032 audit
FAIL). Gather: read Entry 032's single finding and the 9-file list;
investigated the repo's pinned formatter — Nicklockwood SwiftFormat 0.59.1
(`Scripts/install_lint_tools.sh` → `.build/lint-tools/bin/`, gitignored),
invoked by `make check`/`make format` via `Scripts/lint.sh` as
`swiftformat Sources Tests [--lint]`. Reason: `make format` runs over all
`Sources Tests` and would create unrelated churn, so the 9 files must be
formatted individually with the same pinned binary and `.swiftformat` config.
Act: installed the pinned swiftformat binary, ran it on exactly the 9 files.
Verify: full-repo `swiftformat Sources Tests --lint` = `0/1226 files require
formatting`; targeted re-lint = `0/9`; `git diff --check` clean; diffstat
+53/−54 across exactly the 9 approved files; per-file review confirmed only
`redundantSelf`/`redundantStaticSelf` (Self ↔ self), `conditionalAssignment`
(if-else assignment → if-expression, semantically equivalent), `docComments`
(`//` → `///`), and comment-alignment whitespace — no runtime semantics, test
expectation, or control-flow change. Record: this entry. Stop: `swift build` /
`swift test --filter Ark` / `make test` / `make check` still owned by Codex —
no Swift toolchain in the workspace.

### Summary

- Finding 1 (Entry 032): applied pinned SwiftFormat 0.59.1 (config
  `.swiftformat`) to the 9 Ark-owned files only. No other file touched.
- Rules applied: `redundantSelf`/`redundantStaticSelf` (Self ↔ self in
  static/instance member access), `conditionalAssignment` (if-else assignment
  → Swift if-expression in `GetAFPUsageResponse.swift`, semantically
  equivalent), `docComments` (`//` → `///` above a declaration), and
  comment-alignment whitespace.
- All test assertion values (signature hashes, canonical request, credential
  scope, usedPercent, redaction) are unchanged. No runtime semantics, shared
  S1–S14 file, generated file, dependency, Widget behavior, or unrelated
  provider changed.

### Files Changed

- `Sources/CodexBarCore/Providers/Ark/ArkAPIConfig.swift`
- `Sources/CodexBarCore/Providers/Ark/ArkErrorResponse.swift`
- `Sources/CodexBarCore/Providers/Ark/GetAFPUsageResponse.swift`
- `Sources/CodexBarCore/Providers/Ark/VolcengineArkSigner.swift`
- `Tests/CodexBarTests/ArkCredentialProjectionTests.swift`
- `Tests/CodexBarTests/ArkMenuBarMetricWindowResolverTests.swift`
- `Tests/CodexBarTests/ArkRedactionTests.swift`
- `Tests/CodexBarTests/ArkUsageFetcherTests.swift`
- `Tests/CodexBarTests/ArkVolcengineSignerTests.swift`
- `docs/PROJECT_LOG.md` (this entry)
- `docs/TASKS.md` (status update)

Diffstat for the 9 Swift files: +53/−54.

### Evidence

- Pinned SwiftFormat version: `0.59.1` (matches
  `Scripts/install_lint_tools.sh` `SWIFTFORMAT_VERSION="0.59.1"`).
- `.build` is gitignored; the installed binary does not appear in `git status`.
- Full-repo `swiftformat Sources Tests --lint` (same invocation as
  `make check`): `0/1226 files require formatting` (PASS, 38.18s).
- Targeted re-lint of the 9 files: `0/9 files require formatting`.
- `git diff --stat HEAD`: exactly 9 Swift files, +53/−54.
- `git diff --check`: clean.
- Per-file diff review: only formatting-class changes; no semantic change.
- `swift build` / `swift test --filter Ark` / `make test` / `make check` NOT
  run — no Swift 6 toolchain in the workspace (`swift: command not found`). The
  SwiftFormat portion of `make check` was reproduced locally with the pinned
  binary; the remaining gates are deferred to Codex. `conditionalAssignment`
  produced a Swift if-expression (requires Swift 5.9+); Codex's Swift 6
  toolchain supports it.

### Issues / Risks

- Correctness remains UNVERIFIED here until Codex runs `swift build`,
  `swift test --filter Ark`, `make test`, and `make check` on the new commit.
- `conditionalAssignment` changed `GetAFPUsageResponse.swift`'s container
  initialization from an if-else statement to an if-expression; this is a
  syntax-level transformation with identical runtime behavior, but only
  Codex's build can confirm it compiles cleanly.
- The `make test` environment blocker (external `KeyboardShortcuts` package
  `PreviewsMacros` plugin, Entry 032) may persist and is not addressed by this
  formatting-only commit.

### Decision

Entry 032's single finding is addressed additively within the authorized 9-file
scope. No amend/reset/rebase/push.

### Next Action

Codex re-audits the additive correction: `swift build`, `swift test --filter
Ark`, `make test`, `make check`; records PASS/FAIL.

## Entry 034 — M1 Formatting Correction Final Re-Audit

Date: 2026-07-03
Actor: Codex
Type: Review
Status: PASS / AWAITING BEE

### Active Goal

M1 — Ark Provider Menu Bar MVP

### LOOP Result

Re-audited additive formatting commit
`7221ab7bd0ff97881670f49cb3ce4c9a2dcc8c5c` against Entry 032's finding,
the exact nine-file corrective scope, the M1 Definition of Done, the complete
M1 diff from merge baseline `2ec7378b`, and upstream build/test/check rules.
Required evidence was exact ancestry, a clean real index and worktree,
formatting-only semantics, full-target compilation, all Ark tests, repository
checks, security/redaction, no real network tests, and no M2 or functional
Widget scope. Codex modified no product or test source.

### Summary

The Entry 032 formatting finding is closed. Commit `7221ab7b` changes exactly
the nine authorized Ark-owned source/test files plus `docs/TASKS.md` and this
log. The Swift changes are limited to pinned SwiftFormat transformations:
explicit `self`, static `Self`/`self` normalization, comment alignment,
one documentation-comment conversion, and the semantically equivalent Swift
if-expression in `GetAFPUsageResponse`.

The complete app builds, all 40 Ark tests pass, and the full repository
`make check` passes. `make test` remains blocked before test discovery by the
same external Xcode `PreviewsMacros` loading failure recorded in Entry 032.
That failure occurs in the unchanged `KeyboardShortcuts` dependency, is
reproduced by Codex, and is accepted as an honestly documented
environment-only blocker under the M1 Definition of Done.

### Files Reviewed

- Corrective commit: the nine Ark files listed in Entry 033 plus
  `docs/TASKS.md` and `docs/PROJECT_LOG.md`.
- Complete M1 diff from `2ec7378b` through `7221ab7b`, including Ark-owned
  files, tests, governance records, and approved S1–S4/S8–S14 shared
  integration points.

### Evidence

- Branch: `feature/m1-ark-provider-menu-bar`.
- Reviewed commit: `7221ab7bd0ff97881670f49cb3ce4c9a2dcc8c5c`.
- Direct parent:
  `57b0967629f708ef09c21a5320cdf33b805a722b`.
- All 11 working-tree blobs matched the reviewed commit exactly. The real
  index was stale at the parent because Claude used a temporary index; Codex
  verified three zero-byte orphan locks, removed them, and synchronized only
  the real index with `git read-tree --reset HEAD`.
- `git diff --check 57b09676..7221ab7b`: PASS.
- Corrective diff scope: exactly 9 authorized Ark files plus
  `docs/TASKS.md` and `docs/PROJECT_LOG.md`; no shared S1–S14, generated,
  dependency, Widget, M2, or unrelated-provider file changed.
- Line-level review found no changed test expectations, credential material,
  host/action/version values, signature vectors, error behavior, or runtime
  policy. The parser if-expression preserves the prior nested-`Result`
  selection and root fallback.
- Native `swift build`: PASS (`Build complete!`, 13.49 seconds), including
  App, CLI, Core, and Widget products.
- Native `swift test --filter Ark`: PASS, 40 tests in 6 suites.
- `make check`: PASS:
  - Codex parser hash current: `cc33c89a2253a9a3`.
  - SwiftFormat: `0/1226 files require formatting`.
  - SwiftLint: `0 violations, 0 serious in 1225 files`.
  - Shell, documentation-link, package, signing, localization, test-sharding,
    and CI path-gate checks passed; locale missing-key output remained warning
    only.
- `make test`: environment-blocked during `swift test list` before any test
  group ran. The unchanged external
  `KeyboardShortcuts/Sources/KeyboardShortcuts/Recorder.swift` could not load
  `PreviewsMacros.SwiftUIView`. Entry 032 reproduced the same failure twice
  with one intervening direct `swift test list` success and no source change,
  establishing Xcode toolchain instability rather than an Ark regression.
- Security/static scan found no real AK/SK, committed config, Authorization,
  signature, RequestId, raw response, or account-identifier leakage. Existing
  test credentials remain explicitly fake/reference values.
- Ark fetcher tests continue to use only in-memory
  `ProviderHTTPTransportHandler` stubs; no real network test exists.
- Complete baseline review confirms Widget edits remain only S10/S11 compiler
  closures. Ark still returns `nil` from `ProviderChoice`, so M1 adds no Widget
  picker, snapshot, intent, or visible Widget capability.
- Menu-bar behavior is verified through the stable resolver/model seams
  preferred by upstream rules: highest-risk selection, 5h/Daily fallbacks,
  four-window normalization, unavailable/error states, and provider
  registration all compile and their targeted tests pass.

### Issues / Risks

- The sharded full test suite did not execute because the external Xcode
  Preview macro failed during test discovery. This remains a documented
  environment risk; it must be retried after a toolchain/dependency environment
  change but does not require an M1 source or dependency modification.
- M1 acceptance does not authorize M2 popover work, functional Widget work,
  push, PR creation, or merge.

### Decision

PASS acceptance recommendation for M1 commit `7221ab7b`. Entry 032's finding
is closed, security and scope boundaries are satisfied, and the only failed
gate is the reproduced environment-only `make test` blocker allowed by the M1
Definition of Done.

Do not push, open/update a PR, merge, or enter M2 without Bee's explicit
approval. Push/PR approval and merge approval remain separate decisions.

### Next Action

Bee decides whether Codex may push `feature/m1-ark-provider-menu-bar` and open
or update its draft PR. If approved, Codex records the pushed commit and PR
URL; merge remains blocked pending a separate Bee decision.

## Entry 035 — M1 Branch Pushed and Draft PR #2 Opened

Date: 2026-07-03
Actor: Bee (approval) + Codex (repository operation)
Type: Repository Operation / Pull Request
Status: PUSHED / DRAFT PR OPEN

### Active Goal

M1 — Ark Provider Menu Bar MVP

### LOOP Result

Bee approved the exact next action recorded in Entry 034 and `docs/TASKS.md`:
push the reviewed M1 branch to the user's fork and create a draft PR. The loop
was limited to remote/repository verification, one origin push, draft PR
creation, PR-state verification, and this durable record. Merge, upstream
push, M2 work, and additional product changes remained forbidden.

### Summary

- Confirmed the local branch and worktree were clean at audit commit
  `7dba2509dca5014684811c773af8fac321404f28`.
- Confirmed `origin` is
  `zeronxpbee-droid/codexbar-ark-usage-fork` and `upstream` push remains
  disabled.
- Confirmed the fork default/base branch is `main` and no existing M1 PR
  existed.
- Pushed `feature/m1-ark-provider-menu-bar` to `origin` with tracking.
- Opened draft PR #2:
  `https://github.com/zeronxpbee-droid/codexbar-ark-usage-fork/pull/2`.
- The PR body records the Active Goal, Ark-owned files, S1–S14 shared
  integration points, security model, verification evidence, known
  `make test` environment blocker, M2/Widget exclusions, and rollback path.
- No merge, upstream PR, release, or M2 transition was performed.

### Repository / PR Evidence

- Repository:
  `https://github.com/zeronxpbee-droid/codexbar-ark-usage-fork`.
- Base: `main` at
  `2ec7378bb981b393532d9506c2b8303a0889f63e`.
- Head branch: `feature/m1-ark-provider-menu-bar`.
- Head at PR creation:
  `7dba2509dca5014684811c773af8fac321404f28`.
- Reviewed implementation commit:
  `7221ab7bd0ff97881670f49cb3ce4c9a2dcc8c5c`.
- PR #2 is `OPEN`, `DRAFT`, `MERGEABLE`, with merge state `CLEAN`.
- GitHub reported 14 commits and 34 changed files at PR creation.
- No GitHub status checks were present in `statusCheckRollup`; local audit
  evidence remains authoritative and is recorded in Entry 034.
- This post-PR governance record changes only `docs/TASKS.md` and
  `docs/PROJECT_LOG.md`; pushing it advances the same draft PR without changing
  product scope.

### Issues / Risks

- `make test` remains environment-blocked by the external Xcode
  `PreviewsMacros` issue documented in Entries 032 and 034.
- A clean/mergeable draft PR is not merge authorization and does not complete
  the Bee approval gate in the M1 Definition of Done.

### Decision

The approved push and draft-PR operation is complete. Draft PR #2 is the
review surface for M1. No further product change is authorized unless Bee
records a new corrective scope.

Do not merge PR #2 or enter M2 without a separate explicit Bee decision.

### Next Action

Bee reviews draft PR #2 and decides whether it may merge. If Bee requests
changes, update `docs/TASKS.md` with the exact corrective scope before any
developer edit.

## Entry 036 — M1 Merged and M2 Gate Opened

Date: 2026-07-03
Actor: Bee (approval) + Codex (repository operation)
Type: Milestone Transition / Branch Setup
Status: M1 MERGED / M2 APPROVED

### Active Goal

M2 — Ark Popover Details

### LOOP Result

Bee explicitly approved opening M2. The smallest governance loop was to verify
the M1 merge, fast-forward local `main`, create the M2 branch from the exact
merge commit, inspect the existing popover model seam, and advance the durable
task state. Product code, push, PR creation, functional Widget work, and any
unapproved shared menu-card edit remained outside this loop.

### Summary

- Verified `origin/main` is M1 merge commit `239e4272` with parents
  `2ec7378b` and `347e15d1`.
- Fast-forwarded local `main` from the M0 merge to `239e4272`.
- Created local branch `feature/m2-ark-popover-details` at that exact merge
  commit.
- Advanced `docs/TASKS.md` from the completed M1 review/merge gate to the M2
  popover-details preflight and Definition of Done.
- Read the existing menu-card path. M1 already maps 5h to `primary`, Daily to
  `secondary`, Weekly to `tertiary`, and Monthly to a named extra window.
  The generic card currently hides `tertiary` unless provider metadata enables
  the third lane, and treats `resetDescription` as reset text. Claude / GLM
  must therefore prove whether Ark-owned presentation metadata is sufficient;
  any shared menu-card edit must be proposed as S15+ and approved before use.
- No source, test, generated, dependency, remote, or product configuration file
  was changed.

### Files Changed

- `docs/TASKS.md`
- `docs/PROJECT_LOG.md`

### Evidence

- M1 PR:
  `https://github.com/zeronxpbee-droid/codexbar-ark-usage-fork/pull/2`.
- M1 merge commit:
  `239e42721d4b4e4a623b10efc8b52f70d4420287`.
- Merge parents:
  `2ec7378bb981b393532d9506c2b8303a0889f63e` and
  `347e15d16626d00c0a9d887d6a57d0c665d8ce6f`.
- M2 branch: `feature/m2-ark-popover-details`.
- M2 branch base before this governance commit: `239e4272`.
- Source inspection:
  `ArkUsageSnapshot.toUsageSnapshot`,
  `UsageMenuCardView.Model.rateWindowLabels`,
  `UsageMenuCardView.Model.metrics`, and
  `extraRateWindowMetrics`.
- The pre-transition real index and worktree were clean; no orphan
  `HEAD.lock` or `index.lock` was present.

### Issues / Risks

- A likely shared integration need exists for the Weekly third lane and
  used/quota/remaining detail presentation. This entry does not approve or
  implement that edit; the developer must report the exact S15+ boundary first.
- `make test` had an M1 environment-only Xcode `PreviewsMacros` blocker. M2
  must retry it and record the actual result rather than assuming the blocker
  persists.
- Opening M2 does not authorize push, PR creation, merge, M3, or M4.

### Decision

M1 is merged and Bee has opened M2. Claude / GLM may begin the M2 preflight on
the local M2 branch and may implement only within the approved scope. Any
shared upstream-owned popover touch remains gated by an explicit S15+ proposal.

### Next Action

Claude / GLM performs the M2 preflight in `docs/TASKS.md`. If a shared
menu-card touch is required, stop after documenting the proposed S15+ point and
return it to Codex/Bee for approval. Do not push or create a PR.

## Entry 037 — M2 Preflight Revised: S15 Proposed (supportsOpus Path Rejected)

Date: 2026-07-03
Actor: Claude (Developer)
Type: Decision / Documentation
Status: SUPERSEDED — S15 data-flow revised in Entry 038

### Active Goal

M2 — Ark Popover Details

### LOOP Result

LOOP applied as Project Governance Loop. Planner=Codex (audit rejection) +
Bee (direction), Generator=Claude (revised preflight + S15 proposal),
Evaluator=Codex/Bee (approval gate). Done Contract: verify Codex's three
rejections, retain supportsOpus=false, propose S15, record, stop.

### Summary

Codex audit rejected the initial M2 preflight conclusion ("no S15+ needed"). Three
blockers were verified against source:

1. **Quota misrouted through resetDescription**: Ark's `rateWindow(from:)`
   packs `"used/quota"` into `RateWindow.resetDescription`.
   `UsageFormatter.resetLine` (lines 130-162) treats it as reset text — when
   `resetsAt` is present, `resetDescription` is ignored (quota lost); when
   `resetsAt` is absent, it renders as `"Resets 100/500"` (semantically wrong).
   FR4 cannot be satisfied through the standard path.
2. **supportsOpus is a global switch touching M3**: Setting
   `supportsOpus=true` writes a tertiary row into the Widget snapshot
   (`UsageStore+WidgetSnapshot.swift:162`), which is explicitly deferred to
   M3 (S5/S10/S11 keep Ark out of the Widget). It also changes CLI, native
   menu bar, and Preferences tertiary paths — all outside M2's popover scope.
3. **AGENTS.md uncommitted 51-line change**: A "Section 6.1 Secret Storage
   Rule" (cross-project file-hygiene rule from a prior session, recorded in
   memory `feedback_secret_storage`) was present as unstaged modification.
   The initial preflight's "worktree clean" claim was wrong (caused by a
   temporary-index check that masked the dirty file). Codex subsequently
   committed this change as governance commit `d93c22b1` on branch
   `codex/governance-secret-storage-rule` and removed the duplicate from the
   M2 branch; AGENTS.md is no longer dirty.

### Files Changed

- `docs/M0_INTEGRATION_BOUNDARY.md` — S15 row added to table; full S15
  proposal section added (PROPOSED, awaiting Bee approval).
- `docs/PROJECT_LOG.md` — this entry.

### Evidence

- `UsageFormatter.swift:130-162` — `resetLine` prefers `resetsAt` (line 135),
  falls back to `resetDescription` (line 150) with `"Resets %@"` prefix
  (line 159).
- `ArkUsageFetcher.swift:72-84` — `rateWindow(from:)` sets
  `resetDescription = "used/quota"`.
- `UsageStore+WidgetSnapshot.swift:162-167` — `supportsOpus == true` writes
  Widget snapshot tertiary row.
- `MenuCardView.swift:1093-1097` — `metrics(input:)` provider router
  (S15 insertion point, between `.antigravity` and `.minimax` branches).
- `MenuCardView.swift:27-40` — `Metric` struct has
  `detailText`/`detailLeftText`/`detailRightText` fields that can carry
  quota separately from `resetText`.
- `git diff -- AGENTS.md` — 51 insertions (Section 6.1 Secret Storage Rule).
- `git status --short` — `M AGENTS.md` (only dirty file).

### S15 Proposal (recorded in M0_INTEGRATION_BOUNDARY.md)

- **Touch**: `Sources/CodexBar/MenuCardView.swift`
  `UsageMenuCardView.Model.metrics(input:)` — add one Ark router branch
  `if input.provider == .ark { return ArkPopoverMetrics.metrics(input:snapshot:) }`.
- **Ark-owned companion**: `Sources/CodexBar/Providers/Ark/ArkPopoverMetrics.swift`
  (new) — four-window Metric construction; quota via `Metric.detailText`
  (reading `resetDescription` as opaque text per Option A, not parsing);
  `resetText` only from `resetsAt`. Data-flow gap identified by Codex
  audit — revised in Entry 038.
- **Conflict risk**: Low–Med (additive branch). **Rollback**: remove branch.
- **Out of scope**: no `supportsOpus` change, no Widget/CLI/menu/Preferences
  changes, no `toUsageSnapshot()` mapping change.

### Issues / Risks

- S15 is PROPOSED only. Codex/Bee must approve before any implementation.
- AGENTS.md's 51-line Secret Storage Rule change was committed by Codex as
  governance commit `d93c22b1` (`codex/governance-secret-storage-rule` branch,
  not pushed). The M2 branch no longer has this file dirty.
- Local environment has no Swift toolchain; `swift build`/`make test`/
  `make check` will defer to Codex after implementation.

### Decision

`supportsOpus` path abandoned. S15 proposed as the minimal shared touchpoint
(one router branch) with all Ark rendering logic in a new Ark-owned file. No
code written. Stopped per Bee's instruction. Data-flow gap (RateWindow has no
typed quota fields; "no resetDescription" + "no mapping change" contradiction)
identified by Codex audit — see Entry 038 for revised Option A design.

### Next Action

SUPERSEDED — S15 data-flow revised in Entry 038 to close the
used/quota/remaining/reset gap (Option A compatibility trade-off). See
Entry 038 for current status and next action.

## Entry 038 — M2 S15 Data-Flow Revised (Option A Compatibility Trade-off)

Date: 2026-07-03
Actor: Claude (Developer)
Type: Decision / Documentation
Status: BLOCKED — S15 data-flow revised, awaiting Codex/Bee approval

### Active Goal

M2 — Ark Popover Details

### LOOP Result

LOOP applied. Planner=Codex (data-flow gap identified) + Bee (Option A
direction), Generator=Claude (revised S15 data flow), Evaluator=Codex/Bee.
Done Contract: close the used/quota/remaining/reset data-flow gap; document
the resetDescription compatibility trade-off; record Option B (S16) as
future alternative; stop.

### Summary

Codex audit identified that Entry 037's S15 proposal had a data-flow
contradiction: it claimed "no `resetDescription` use" AND "no snapshot mapping
change" simultaneously, but `RateWindow` has no typed used/quota/remaining
fields (only `usedPercent`, `resetsAt`, `resetDescription`, `windowMinutes`,
`nextRegenPercent`). Without a mapping change, quota can only travel through
`resetDescription`; refusing to use it loses quota entirely.

Revised per Codex/Bee Option A direction (third revision — complete display
string):

- **Ark mapper modified**: `rateWindow(from:)` changes `resetDescription`
  content from M1's `"used/quota"` to a complete display string
  `"used / quota AFP · remaining remaining"` (remaining = quota − used).
  This ensures `detailText` carries all three numeric values (used, quota,
  remaining) regardless of `usageBarsShowUsed` setting, satisfying FR4's
  four-value requirement (`Metric.percent` shows used% or remaining% per
  setting; `detailText` supplements with the full numeric trio).
- **ArkPopoverMetrics reads `resetDescription` into `Metric.detailText`** as
  opaque display text — **never parsed back into numeric values**.
- **`resetText` generated ONLY from `resetsAt`**: `UsageFormatter.resetLine`
  invoked only when `resetsAt != nil`; when nil, `resetText = nil` (no
  fallback to `resetDescription`).
- This is a **documented compatibility trade-off**: `resetDescription` is
  semantically a reset field (upstream comment: "Optional textual reset
  description, used by Claude CLI UI scrape"), but Ark reuses it as a
  quota-detail carrier because `RateWindow` has no dedicated quota slot.
  The borrow is isolated to Ark's presentation layer.

Option B (typed `ArkQuotaDetail` payload + new shared `RateWindow`/`UsageSnapshot`
field) was recorded as a future alternative requiring S16, deferred to a later
milestone if the trade-off proves insufficient.

### Files Changed

- `docs/M0_INTEGRATION_BOUNDARY.md` — S15 "Ark-owned companion file" section
  revised (Option A data flow); "Out of scope" updated; "Future alternative —
  Option B (S16)" section added.
- `docs/PROJECT_LOG.md` — Entry 037 corrected (Actor=Codex, AGENTS.md status);
  this entry added.

### Evidence

- `UsageFetcher.swift:3-18` — `RateWindow` struct: `usedPercent`,
  `windowMinutes`, `resetsAt`, `resetDescription`, `nextRegenPercent` (no
  typed used/quota/remaining fields).
- `UsageFormatter.swift:130-162` — `resetLine`: prefers `resetsAt` (line 135),
  falls back to `resetDescription` (line 150). ArkPopoverMetrics avoids the
  fallback by guarding on `resetsAt != nil`.
- `ArkUsageFetcher.swift:72-84` — `rateWindow(from:)` currently sets
  `resetDescription = "used/quota"` (M1). S15 modifies this to a complete
  display string `"used / quota AFP · remaining remaining"`.
- `MenuCardView.swift:27-40` — `Metric.detailText` field receives the
  `resetDescription` text as opaque display content.
- `git status --short` — only `docs/M0_INTEGRATION_BOUNDARY.md` and
  `docs/PROJECT_LOG.md` dirty (AGENTS.md cleaned by governance commit
  `d93c22b1`).

### Issues / Risks

- S15 is PROPOSED with revised data flow. Codex/Bee must approve before
  implementation.
- The `resetDescription` compatibility borrow is a semantic stretch — it
  works for M2 but Option B (S16 typed payload) is the clean long-term fix.
- `ArkPopoverMetrics` must NOT call `UsageFormatter.resetLine` unconditionally;
  it must guard on `resetsAt != nil` to avoid the `resetDescription` fallback.
  This invariant must be enforced in tests.
- **Test coverage required**: all four windows complete;
  `usageBarsShowUsed = true` and `= false` (detailText shows full trio in both);
  `resetsAt` present and absent; missing/partial windows; Monthly
  `usageKnown = false`; error/stale states.
- Local environment has no Swift toolchain; build/test/check defer to Codex.

### Decision

Option A proposed for S15 (not yet approved): `resetDescription` carries a
complete display string (`"used / quota AFP · remaining remaining"`) →
`Metric.detailText`; `resetText` from `resetsAt` only. Option B (S16 typed
payload) deferred. No code written. Stopped per Codex/Bee instruction.

### Next Action

Await Codex/Bee approval of revised S15 (Option A data flow). If approved,
implement S15 router branch + `ArkPopoverMetrics.swift` (with `resetsAt`
guard) + M2 tests → `git diff --check` → additive commit → hand to Codex
for `swift build`/`swift test --filter Ark`/`make test`/`make check`.

## Entry 039 — Bee Approves M2 S15 Option A Boundary

Date: 2026-07-03
Actor: Bee (approval) + Codex (boundary registration)
Type: Decision / Documentation
Status: APPROVED / IMPLEMENTATION AUTHORIZED

### Active Goal

M2 — Ark Popover Details

### LOOP Result

Bee explicitly approved S15 after three preflight revisions closed the
Weekly-row, Widget-scope, reset/quota-routing, and complete
used/quota/remaining/reset data-flow gaps. The smallest governance loop is to
register the exact one-branch shared touch, authorize its Ark-owned companion
work and tests, advance `docs/TASKS.md`, commit only governance documents, and
stop before product implementation.

### Summary

- S15 is approved for M2:
  `Sources/CodexBar/MenuCardView.swift`
  `UsageMenuCardView.Model.metrics(input:)` may receive one additive `.ark`
  router branch.
- All Ark metric construction must remain in new Ark-owned
  `Sources/CodexBar/Providers/Ark/ArkPopoverMetrics.swift`.
- Ark-owned `ArkUsageFetcher.rateWindow(from:)` may change only its
  `resetDescription` presentation payload from M1's `"used/quota"` form to a
  complete opaque string containing used, quota, and remaining.
- `ArkPopoverMetrics` must route that opaque value to `Metric.detailText`
  without parsing it. `resetText` may be generated only when `resetsAt` exists,
  preventing the quota payload from falling through as `"Resets …"`.
- `supportsOpus` remains `false`. S15 does not authorize Widget snapshot,
  Widget UI, CLI, native-menu, Preferences, shared snapshot-schema, S16, or
  unrelated-provider changes.
- No product or test source was changed in this approval loop.

### Files Changed

- `docs/TASKS.md`
- `docs/M0_INTEGRATION_BOUNDARY.md`
- `docs/PROJECT_LOG.md`

### Evidence

- Bee explicitly replied `批准S15`.
- Entry 038 and the boundary map record the final Option A data flow,
  compatibility trade-off, required test matrix, conflict risk, and rollback.
- `RateWindow` has no typed raw used/quota/remaining fields; S16 remains
  unapproved and deferred.
- S15 changes one shared provider router only. Removing that branch restores
  M1 popover behavior without affecting other providers.

### Issues / Risks

- `resetDescription` remains a semantically imperfect carrier for Ark quota
  detail. The trade-off is accepted for M2 to avoid a broader shared schema
  change.
- Full build/test/check evidence remains required after implementation.
- Approval does not authorize push, PR creation, merge, M3, or M4.

### Decision

Approve S15 Option A exactly as registered. Claude / GLM may implement the
authorized M2 slice after re-reading the committed governance state and stating
its Done Contract. Any shared touch beyond S15 requires a new stop-and-report
decision.

### Next Action

Codex commits this governance record locally. Claude / GLM then implements the
exact S15 Option A scope and creates one additive local commit without push.
Codex performs the acceptance audit afterward.

## Entry 040 — M2 S15 Option A Implemented

Date: 2026-07-03
Actor: Claude (implementation)
Type: Development
Status: CREATED — awaiting Codex build/test/check audit

### Active Goal

M2 — Ark Popover Details (S15 Option A)

### LOOP Result

Development Loop applied: Planner=Bee (Entry 039 approval), Generator=Claude,
Evaluator=Codex (pending build/test/check), Recorder=Claude. Done Contract:
implement the three S15 code changes, write tests covering the required matrix,
update governance docs, create one additive local commit, stop. No S16,
Widget, CLI, native menu, Preferences, or `supportsOpus` changes.

### Summary

Three code changes implementing the approved S15 Option A boundary:

1. `ArkUsageFetcher.rateWindow(from:)` — `resetDescription` changed from
   M1's `"used/quota"` to the complete display string
   `"used / quota AFP · remaining remaining"` (remaining = quota − used).
   This packs all three numeric values (used/quota/remaining) into the
   existing `RateWindow.resetDescription` field so `ArkPopoverMetrics` can
   display them without a typed quota slot.

2. `Sources/CodexBar/Providers/Ark/ArkPopoverMetrics.swift` (new, Ark-owned) —
   builds the four `[Metric]` rows (5h / Daily / Weekly / Monthly) directly
   from `UsageSnapshot`. Weekly (tertiary) renders unconditionally because
   the Ark router bypasses the `supportsOpus` gate. `detailText` reads
   `window.resetDescription` as opaque display text (never parsed).
   `resetText` is generated ONLY when `resetsAt != nil` via
   `UsageFormatter.resetLine`, guarded so it never falls back to
   `resetDescription` (which would render quota as `"Resets …"`).

3. `Sources/CodexBar/MenuCardView.swift` `metrics(input:)` — one additive
   router branch: `if input.provider == .ark { return Self.arkMetrics(...) }`,
   placed before the `.antigravity` branch. All Ark rendering logic stays
   in `ArkPopoverMetrics.swift`.

### Files Changed

- `Sources/CodexBarCore/Providers/Ark/ArkUsageFetcher.swift` (modified —
  `rateWindow(from:)` mapper format)
- `Sources/CodexBar/Providers/Ark/ArkPopoverMetrics.swift` (new — Ark-owned
  presentation file)
- `Sources/CodexBar/MenuCardView.swift` (modified — S15 router branch, 3 lines)
- `Tests/CodexBarTests/ArkPopoverMetricsTests.swift` (new — 9 test cases)
- `docs/PROJECT_LOG.md` (this entry)
- `docs/TASKS.md` (M2 status update)

### Evidence

- `git diff --check` passes (no whitespace errors).
- Diff confirms only the three approved changes plus two new Ark-owned files.
- `ArkPopoverMetricsTests.swift` covers the required test matrix:
  (1) four windows complete — detailText carries the full display string,
      resetText from resetsAt;
  (2) `usageBarsShowUsed = false` — percent shows remaining%, detailText
      still shows the complete trio;
  (3) `resetsAt = nil` — resetText is nil (no fallback to resetDescription),
      detailText still present;
  (4) missing/partial windows — omitted, not rendered as 0%;
  (5) Monthly `usageKnown = false` — statusText = "Unavailable",
      detailText nil;
  (6) no snapshot — empty metrics;
  (7) `resetDescription = nil` but `resetsAt` present — resetText generated,
      detailText nil;
  (8) absolute reset style — resetText shows date, detailText unaffected.
- No local Swift toolchain; build/test/check deferred to Codex.

### Issues / Risks

- Build/test/check not yet run (no local Swift toolchain). Codex must
  verify compilation and test passage before merging.
- `resetDescription` borrow remains a compatibility trade-off (S16 is the
  future typed alternative).
- `arkMetrics` is `static func` (internal), accessible via `@testable import`.

### Decision

Implementation complete within the authorized S15 scope. No shared touch
beyond the one approved router branch. `supportsOpus` stays `false`. No
Widget/CLI/native-menu/Preferences changes.

### Next Action

Codex performs build/test/check audit. If green, M2 implementation is
accepted. If red, Claude creates an additive correction commit (no
amend/reset).

## Entry 041 — M2 S15 Option A First Audit

Date: 2026-07-03
Actor: Codex
Type: Review
Status: FAIL

### Active Goal

M2 — Ark Popover Details

### LOOP Result

Audited additive developer commit
`02539d875529cb786572be574f69126e06ab6fcc` against the approved S15
Option A boundary, M2 Definition of Done, complete M2 diff from merge baseline
`239e4272`, complete fork diff from upstream baseline `6ab1cbb7`, and upstream
build/test/check rules. Required evidence was exact ancestry, clean real
index/worktree, full compilation, Ark and popover-model tests, full repository
gates, complete error/stale coverage, no S16 or functional Widget expansion,
and credential/error redaction. Codex changed no product or test source.

### Summary

The submitted scope is structurally narrow and follows S15: one shared router
branch, Ark-owned presentation/mapping code, focused tests, and governance
records. It nevertheless fails M2 acceptance because the production mapper
does not compile. The new test file also fails the pinned SwiftFormat check and
does not implement the explicitly approved refresh-error/stale-snapshot test
coverage.

Claude's commit operation left five zero-byte lock artifacts:
`index.lock`, `HEAD.lock`, `objects/maintenance.lock`, `index.lock.bak`, and
`index.lock.stale`. Codex verified there was no repository-writing Git process,
confirmed all six changed working-tree and real-index blobs exactly matched
commit `02539d87`, removed only those orphan zero-byte locks, and synchronized
only the real index with `git read-tree --reset HEAD`.

### Files Reviewed

- `Sources/CodexBar/MenuCardView.swift` — approved S15 shared router.
- `Sources/CodexBar/Providers/Ark/ArkPopoverMetrics.swift` — new Ark-owned
  presentation.
- `Sources/CodexBarCore/Providers/Ark/ArkUsageFetcher.swift` — Option A
  complete quota-detail string.
- `Tests/CodexBarTests/ArkPopoverMetricsTests.swift` — nine submitted tests.
- `docs/TASKS.md`
- `docs/PROJECT_LOG.md`

### Evidence

- Branch: `feature/m2-ark-popover-details`.
- Reviewed commit: `02539d875529cb786572be574f69126e06ab6fcc`.
- Direct parent and approved governance baseline:
  `b0c59749e63c906be75afb097886844e12c0136d`.
- `git diff --check b0c59749..02539d87`: PASS.
- Diff scope: exactly six files; shared upstream change is only the approved
  three-line S15 `.ark` router branch. No Widget, CLI, native-menu,
  Preferences, shared snapshot schema, S16, dependency, generated, or
  unrelated-provider file changed.
- Native `swift build`: FAIL in
  `ArkUsageFetcher.swift:84`. The Swift if-expression branch declares local
  `remaining` before the string expression, so the compiler reports
  `non-expression branch of 'if' expression may only end with a 'throw'`; the
  string literal is consequently unused.
- `swift test --filter Ark`: FAIL during the same production-source
  compilation error; no Ark test executed.
- `make test`: environment-blocked during `swift test list` by the unchanged
  external `KeyboardShortcuts` `PreviewsMacros.SwiftUIView` plugin-loading
  failure previously recorded in M1. This command did not reach test
  discovery; the independent native build/test failures above remain source
  failures.
- `make check`: FAIL. All portable checks passed, including parser hash,
  documentation links, shell, package/signing, locale, sharding, and CI path
  gates. Pinned SwiftFormat then reported
  `1/1228 files require formatting` for
  `ArkPopoverMetricsTests.swift`: one `redundantSelf` finding and nine
  `redundantThrows` findings.
- The test file defines nine `@Test` cases, but every constructed input has
  `isRefreshing: false` and `lastError: nil`; there is no assertion for a
  refresh error or stale snapshot despite both being required by
  `docs/TASKS.md` and the approved S15 test matrix.
- Static security review found no added real AK/SK, Authorization, signature,
  RequestId, raw response, account identifier, committed config, or real
  network test. Existing credential/error comments and fake test data remain
  non-sensitive.
- `supportsOpus` remains `false`; no functional Widget capability is added.

### Findings

1. **[P1] Make the Option A mapper compile under Swift 6.**
   Replace the invalid multi-statement if-expression in
   `ArkUsageFetcher.rateWindow(from:)` with ordinary assignment or a small
   Ark-owned helper. Preserve the exact approved display content and data flow.

2. **[P1] Make the new test file pass pinned SwiftFormat.**
   Format only `ArkPopoverMetricsTests.swift`; remove the reported redundant
   `throws` declarations and apply the required explicit-`self` rule without
   changing test expectations.

3. **[P1] Add the approved refresh-error and stale-snapshot model tests.**
   Exercise non-nil safe `lastError` presentation and an old snapshot/update
   state through the stable menu-card model seam. No live AppKit menu, network,
   credential, Widget, or new product behavior is authorized.

### Issues / Risks

- Additional compiler/test findings may appear only after finding 1 allows the
  App and test targets to compile.
- `make test` retains the known external Xcode Preview macro environment risk
  and must be retried on the corrective commit.

### Decision

FAIL. Do not push, open a PR, merge, or enter M3 for commit `02539d87`.

Claude / GLM may create one additive corrective commit limited to the two
Ark-owned files and two governance files listed in `docs/TASKS.md`. No amend,
reset, rebase, temporary-index workaround, or product-scope expansion is
authorized.

### Next Action

Claude / GLM fixes findings 1–3, runs all required commands where available,
records exact outcomes, and creates one additive local commit. Codex then
re-audits the correction.

## Entry 042 — M2 S15 Corrective Commit

Date: 2026-07-03
Actor: Claude (implementation)
Type: Bugfix
Status: CREATED — awaiting Codex re-audit

### Active Goal

M2 — Ark Popover Details (S15 Option A corrective)

### LOOP Result

Debugging Loop applied after Codex Entry 041 audit FAIL. Three findings
fixed by inspecting the trace: (1) if-expression body contained a `let`
statement (Swift requires single expression); (2) test functions declared
unnecessary `throws` and one `Self.` access that SwiftFormat flagged; (3)
approved test matrix omitted refresh-error and stale-snapshot coverage.
Generator=Claude, Evaluator=Codex (pending re-audit).

### Summary

Finding 1 (P1 — compile): `ArkUsageFetcher.rateWindow(from:)` if-expression
body declared `let remaining = max(0, quota - used)` before the string
literal, causing `non-expression branch of 'if' expression`. Fixed by
inlining the expression: `\(Self.format(max(0, quota - used)))`.

Finding 2 (P1 — SwiftFormat): `ArkPopoverMetricsTests.swift` had 9
`redundantThrows` findings (every `@Test func` declared `throws` but none
used `try`) and 1 `redundantSelf` finding. Fixed by removing all `throws`,
introducing a `makeSnapshot` helper that wraps `UsageSnapshot` construction
so `Self.now`/`Self.resetDate` no longer appear in instance-method call
sites, and extending `makeModel` with `resetTimeDisplayStyle` and
`lastError` parameters so the absolute-style test reuses the helper.

Finding 3 (P1 — missing tests): Added two approved test cases:
`refreshErrorShowsErrorStyleButMetricsRender` — verifies a non-nil
`lastError` surfaces `subtitleStyle == .error` while cached metrics still
render; `staleSnapshotStillRendersMetrics` — verifies a 2-hour-old
snapshot still renders its cached rows.

### Files Changed

- `Sources/CodexBarCore/Providers/Ark/ArkUsageFetcher.swift` (1 line —
  inline remaining expression)
- `Tests/CodexBarTests/ArkPopoverMetricsTests.swift` (rewritten — 11 test
  cases, helpers consolidated, `throws` removed, `makeSnapshot` added)
- `docs/PROJECT_LOG.md` (this entry)
- `docs/TASKS.md` (status update)

### Evidence

- `git diff --check`: PASS.
- Diff scope: 2 product/test files + 2 governance files. No shared-file
  change beyond the already-approved S15 router branch (unchanged from
  `02539d87`). No S16/Widget/CLI/native-menu/Preferences change.
- `ArkUsageFetcher.swift` if-expression body is now a single string
  literal expression.
- Test file has 11 `@Test` functions, none with `throws`; no `Self.`
  access in instance-method bodies (only in a doc comment).
- No local Swift toolchain; build/test/check deferred to Codex.

### Issues / Risks

- Build/test/check not yet run (no local Swift toolchain). Codex must
  verify compilation and test passage.
- `make test` retains the known external `PreviewsMacros` environment
  risk; Codex should retry on this commit.

### Decision

Corrective commit limited to the two Ark-owned files and two governance
files as authorized by Entry 041. No amend/reset/rebase/push.

### Next Action

Codex re-audits the correction. If green, M2 implementation is accepted.

## Entry Template

```text
## Entry XXX — <Title>

Date: YYYY-MM-DD
Actor: GLM / Codex / Bee / ChatGPT
Type: Development / Review / Decision / Documentation / Bugfix
Status: PASS / FAIL / BLOCKED / CREATED / MERGED

### Active Goal

<Goal from docs/TASKS.md>

### LOOP Result

<Brief summary of how LOOP was applied>

### Summary

<What happened>

### Files Changed

<Files changed or reviewed>

### Evidence

<Build/test/probe/review evidence>

### Issues / Risks

<What is still uncertain>

### Decision

<What was decided>

### Next Action

<Next allowed action>
```
