# TASKS.md — Current Task State

> This file owns the current active goal. No other file may maintain a competing active goal.

## Active Goal

```text
M1 — Ark Provider Menu Bar MVP
```

## Goal Status

```text
Status: M1 CORRECTION 3 SUBMITTED — Awaiting Codex Re-Audit (see PROJECT_LOG Entry 033)
Implementation State: Pinned SwiftFormat 0.59.1 applied to the 9 Ark files; full-repo lint now 0/1226; build/test/check deferred to Codex
Next: Codex re-audits (swift build, swift test --filter Ark, make test, make check)
Implementation Owner: Claude / GLM Developer
Repository Operator: Codex
Auditor: Codex
Architecture / Decision: Bee + ChatGPT
```

## Repository Baseline

```text
Fork: https://github.com/zeronxpbee-droid/codexbar-ark-usage-fork
Visibility: Public GitHub Fork
origin: https://github.com/zeronxpbee-droid/codexbar-ark-usage-fork.git
upstream: https://github.com/steipete/CodexBar.git
Upstream push: Disabled
Default branch: main
Upstream baseline: 6ab1cbb7daee73b8ad531fbdd420e9aa6eb6d26b
M0 branch: feature/m0-bootstrap-ark-probe
M0 merged PR: https://github.com/zeronxpbee-droid/codexbar-ark-usage-fork/pull/1
M0 merge commit: 2ec7378bb981b393532d9506c2b8303a0889f63e
M1 branch: feature/m1-ark-provider-menu-bar
```

## Mandatory Pre-Execution Rule

Before starting this task, the Claude / GLM Developer must invoke or explicitly
compare the work against the already-installed `LOOP` Skill.

Before reviewing this task, Codex must invoke or explicitly compare the review against the already-installed `LOOP` Skill.

If LOOP, `AGENTS.md`, `docs/PRD.md`, `docs/TASKS.md`, or `docs/PROJECT_LOG.md` conflict, stop and report documentation drift.

## M1 Objective

Integrate Volcengine Ark Agent Plan AFP usage as a native CodexBar provider and
show a compact, decision-useful status in the macOS menu bar.

M1 is limited to provider core, secure credential resolution, minimal provider
registration, menu-bar status, basic error states, and tests. Four-window
custom popover details remain M2; Widget snapshot, picker, and UI remain M3–M4.

## Allowed Scope

Codex may:

- Maintain the M1 branch and task-state documentation.
- Inspect Claude / GLM commits and the complete M1 diff.
- Run build, test, formatting, lint, security, and provider-behavior checks.
- Commit audit records and explicitly requested governance corrections.
- Push an accepted M1 branch and create/update its draft PR.

Claude / GLM may:

- Add Ark-owned provider, fetcher/parser, signer, settings/credential resolver,
  implementation, and targeted test files.
- Adapt the reviewed M0 probe logic into the existing CodexBar provider
  architecture without importing the standalone probe package into the app.
- Touch only the minimum M1 shared integration points from
  `docs/M0_INTEGRATION_BOUNDARY.md`:
  - S1 — `UsageProvider` Ark case.
  - S2 — `IconStyle` Ark case, only if required by the descriptor pattern.
  - S3 — provider descriptor registration.
  - S4 — provider implementation registration.
  - S8 — `ProviderConfigEnvironment` Ark credential projection.
  - S9 — `MenuBarMetricWindowResolver` Ark automatic highest-risk selection.
  - S10 — `CodexBarWidgetProvider` exhaustive-switch compile stub:
    `case .ark: return nil`.
  - S11 — `CodexBarWidgetViews` exhaustive-switch compile stubs for the Ark
    short label and static color.
  - S12 — `CostUsageScanner.loadDailyReportCancellable` exhaustive-switch
    compile stub: add `.ark` to the existing unsupported-provider group that
    returns `emptyReport`.
  - S13 — `UsageStore` provider debug-log exhaustive-switch compile stub: add
    `.ark` to the existing unimplemented-debug group without adding a probe or
    exposing credentials.
  - S14 — `CodexParserHash.generated.swift` mechanical integrity update
    produced by `Scripts/regenerate-codex-parser-hash.sh` after S12; no manual
    generated-file edits or runtime behavior changes.
- Store the IAM Access Key ID in `ProviderConfig.apiKey` and Secret Access Key
  in `ProviderConfig.secretKey`, persisted by the upstream
  `CodexBarConfigStore` with mode `0600`, following the existing Bedrock
  pattern. Do not introduce an Ark-specific credential store.
- Normalize AFP windows into existing `UsageSnapshot` / rate-window models.
- Add basic menu-bar status and safe provider error states.
- Add M1 tests and update M1 task/history documentation.

## Forbidden Scope

Codex must not:

- Implement or repair M1 product code.
- Rewrite Claude / GLM commits without Bee's explicit approval.
- Merge a PR without Bee's explicit approval.

Claude / GLM must not:

- Create, delete, rename, or push branches or worktrees.
- Add, remove, or modify Git remotes.
- Open, update, close, or merge Pull Requests.
- Replace upstream history with a detached copy or squashed import.
- Mix an upstream synchronization with Ark feature implementation.
- Touch Widget snapshot, picker, intent, or UI feature code (S5–S7). The only
  M1 exception is the exact compile-only S10/S11 exhaustive-switch arms.
- Add `ProviderChoice.ark`, an Ark `DisplayRepresentation`, Widget picker
  availability, snapshot behavior, layout wiring, or any visible Ark Widget
  capability under the S10/S11 exception.
- Add custom four-window popover UI; that belongs to M2.
- Modify unrelated providers.
- Refactor CodexBar architecture.
- Commit AK/SK, API keys, cookies, screenshots with secrets, or any generated
  `config.json`.
- Introduce a custom plaintext credential file outside the upstream CodexBar
  config mechanism.
- Use environment variables as the production App credential mechanism; they
  remain permitted only for the isolated M0 probe.
- Store the AK/SK pair by concatenating it into a normal single-token field.
- Print Authorization, signatures, raw error bodies, RequestId, account IDs, or
  other credential/account-sensitive values.
- Add wildcard IAM grants or claim a least-privilege policy without evidence.
- Add a backend service.
- Add browser-cookie scraping.
- Publish or package a release.
- Submit an upstream PR.

## Next Task for Claude / GLM

0. Work only in the assigned `feature/m1-ark-provider-menu-bar` checkout and create
   local commits without pushing.

1. Re-read these files and explicitly apply LOOP:

```text
AGENTS.md
README.md
docs/PRD.md
docs/TASKS.md
docs/PROJECT_LOG.md
docs/M0_INTEGRATION_BOUNDARY.md
```

2. Confirm before editing:

```text
- Branch is feature/m1-ark-provider-menu-bar.
- Active Goal is M1 — Ark Provider Menu Bar MVP.
- HEAD descends from developer commit 132cad87 and the latest Codex
  audit/governance commits.
- Worktree contains no unrelated user/Codex changes.
```

3. Make only the repository-pinned SwiftFormat changes reported in Entry 032
   for these nine Ark-owned source/test files:

```text
Sources/CodexBarCore/Providers/Ark/ArkAPIConfig.swift
Sources/CodexBarCore/Providers/Ark/ArkErrorResponse.swift
Sources/CodexBarCore/Providers/Ark/GetAFPUsageResponse.swift
Sources/CodexBarCore/Providers/Ark/VolcengineArkSigner.swift
Tests/CodexBarTests/ArkCredentialProjectionTests.swift
Tests/CodexBarTests/ArkMenuBarMetricWindowResolverTests.swift
Tests/CodexBarTests/ArkRedactionTests.swift
Tests/CodexBarTests/ArkUsageFetcherTests.swift
Tests/CodexBarTests/ArkVolcengineSignerTests.swift
```

4. This correction is formatting-only:

```text
- Do not change runtime behavior, fixtures, expected values, or test coverage.
- Do not run a repository-wide formatter or include unrelated formatting churn.
- Do not touch shared S1–S14 files, generated files, dependencies, Widget
  behavior, M2 scope, or unrelated providers.
```

5. Run:

```text
git diff --check
swift build
swift test --filter Ark
make test
make check
```

If `make test` again fails only because Xcode cannot load the external
`KeyboardShortcuts` `PreviewsMacros` plugin, record the exact environment
failure; do not modify the dependency or test harness.

6. Append a corrective implementation entry to `docs/PROJECT_LOG.md`, update
   this task status, perform a final LOOP self-check, and create one additive
   local commit. Do not amend, reset, rebase, push, or open a PR.

## Definition of Done — M1

M1 is Done only when:

- LOOP was used or explicitly referenced before execution.
- Ark is registered through only the necessary S1–S4 and S8–S14 shared
  integration points.
- Provider-specific networking, signing, parsing, credential resolution, and
  tests are isolated in Ark-owned files where the architecture permits.
- The provider calls the confirmed `volcengineapi.com` control-plane host.
- Production credentials use the approved upstream CodexBar
  `ProviderConfig`/`CodexBarConfigStore` mechanism with mode `0600`; no
  environment-only, custom plaintext-file, concatenated-token, or committed
  credential path is introduced.
- The menu bar can display compact Ark AFP usage using real or safely mocked
  data.
- Ark preserves stable 5h/Daily/Weekly/Monthly window semantics. Automatic
  menu-bar display uses the S9 provider-specific highest-risk resolver; 5h is
  the first fallback and Daily is used if 5h is absent.
- Unauthorized, timeout/network, empty/unsupported, and unknown failures have
  safe states and do not expose raw responses or identifiers.
- Signer, parser, normalization, credential redaction, error behavior, and
  provider registration have targeted tests.
- `swift build`, `make test`, and `make check` pass, or any environment-only
  blocker is documented honestly and reproduced by Codex.
- No M2 popover, functional Widget, unrelated-provider, upstream-sync, or
  broad-refactor changes are included; Widget changes are limited exactly to
  the S10/S11 compiler-closure arms.
- Actual S1–S4/S8–S14 touches and rollback steps are recorded in the M1 PR/log.
- `docs/PROJECT_LOG.md` has an M1 implementation and Codex audit record.
- Codex review is complete.
- Bee approves merge or moving to M2.

## Planned Milestones After M1

### M2 — Ark Popover Details

Allowed only after Bee updates this file.

Target:

- Show 5h / daily / weekly / monthly AFP usage rows.

### M3 — Widget Snapshot Integration

Allowed only after Bee updates this file.

Target:

- Ensure Ark provider data is written into Widget-readable snapshot.

### M4 — Widget Provider Picker + UI

Allowed only after Bee updates this file.

Target:

- Ark selectable in Widget provider picker.
- Small and medium desktop Widgets display Ark usage.

### M5 — Stabilization and Local Release Candidate

Allowed only after Bee updates this file.

Target:

- Tests.
- Build.
- README update.
- Local installation instructions.

## Current Confirmed API Findings

Official Volcengine documentation confirms:

1. The action is `GetAFPUsage`, API version `2024-01-01`.
2. The request uses HMAC-SHA256 authentication with IAM AK/SK, not an Ark
   inference API Key.
3. The response fields are `AFPFiveHour`, `AFPDaily`, `AFPWeekly`, and
   `AFPMonthly`.
4. Each window contains `Quota`, `Used`, `SubscribeTime`, and `ResetTime`.
5. `SubscribeTime` and `ResetTime` are epoch millisecond timestamps.
6. Bee's subscription is an Agent Plan personal subscription, so
   `GetAFPUsage` is the intended usage action.
7. The signer strategy is a dedicated Volcengine signer using `swift-crypto`
   and the official HMAC-SHA256 signing chain. Test execution and session-token
   handling must pass review before acceptance.
8. Production host is `ark.cn-beijing.volcengineapi.com`, confirmed by the
   credentialed live probe (docs/PROJECT_LOG.md Entry 015): HTTP 200 with all
   four AFP windows parsed, while `ark.cn-beijing.volces.com` returned HTTP 401.
   This is the probe's default host; `--host` can still target either endpoint.

## Current Open Questions

These must be resolved during M0 or before the indicated integration milestone:

1. What is the least-privilege IAM action/policy required for `GetAFPUsage`?
2. Which CodexBar usage model best fits quota windows with multiple reset periods?
3. Should the Widget default to 5-hour usage or highest-risk usage?

## Current Decision

Default MVP display strategy:

```text
Menu bar: highest-risk window, otherwise 5-hour window.
Small Widget: Ark AFP percentage + reset.
Medium Widget: 5h / daily / weekly / monthly summary.
```

This decision may be revised after M0 evidence.
