# TASKS.md — Current Task State

> This file owns the current active goal. No other file may maintain a competing active goal.

## Active Goal

```text
M2 — Ark Popover Details
```

## Goal Status

```text
Status: M2 AUDIT PASS — awaiting Bee repository/milestone decision (see PROJECT_LOG Entry 050)
Implementation State: Full build, 51 Ark tests, 11 popover tests, and make check pass; make test remains environment-blocked by the unchanged external Preview macro issue
Next: Bee decides whether Codex may push/open the M2 draft PR, and separately whether M2 may merge or M3 may open
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
M1 merged PR: https://github.com/zeronxpbee-droid/codexbar-ark-usage-fork/pull/2
M1 merge commit: 239e42721d4b4e4a623b10efc8b52f70d4420287
M2 branch: feature/m2-ark-popover-details
```

## Mandatory Pre-Execution Rule

Before starting this task, the Claude / GLM Developer must invoke or explicitly
compare the work against the already-installed `LOOP` Skill.

Before reviewing this task, Codex must invoke or explicitly compare the review against the already-installed `LOOP` Skill.

If LOOP, `AGENTS.md`, `docs/PRD.md`, `docs/TASKS.md`, or `docs/PROJECT_LOG.md` conflict, stop and report documentation drift.

## M2 Objective

Show Ark's 5h, Daily, Weekly, and Monthly AFP windows as clear rows in the
existing CodexBar menu popover, using the M1 provider snapshot and established
menu-card architecture.

Each available row must communicate used, quota, remaining, and reset
information when the API provides it. Missing fields, stale data, refresh
errors, and unavailable windows must degrade safely without inventing values.
Widget snapshot, picker, intent, and visible Widget support remain M3–M4.

## Allowed Scope

Codex may:

- Maintain the M2 branch and task-state documentation.
- Inspect Claude / GLM commits and the complete M2 diff.
- Run build, test, formatting, lint, security, and provider-behavior checks.
- Commit audit records and explicitly requested governance corrections.
- Push an accepted M2 branch and create/update its draft PR only after Bee
  separately approves that repository operation.

Claude / GLM may:

- Add Ark-scoped popover presentation/model helpers and targeted menu-card
  tests where the existing architecture permits.
- Extend Ark-owned snapshot presentation metadata only as needed to preserve
  the four confirmed AFP windows and expose used/quota/remaining/reset values.
- Reuse the existing `UsageMenuCardView.Model`, `Metric`, `RateWindow`, and
  `NamedRateWindow` paths rather than creating a parallel popover architecture.
- Implement approved S15 only: add one Ark routing branch in
  `UsageMenuCardView.Model.metrics(input:)` and keep all Ark-specific metric
  construction in new Ark-owned
  `Sources/CodexBar/Providers/Ark/ArkPopoverMetrics.swift`.
- In Ark-owned `ArkUsageFetcher.rateWindow(from:)`, change only the
  `resetDescription` presentation payload from M1's `"used/quota"` form to a
  complete opaque `used / quota AFP · remaining remaining` display string.
- Route that opaque string to `Metric.detailText` without parsing it; generate
  `resetText` only when `resetsAt` is non-nil so quota detail can never fall
  through `UsageFormatter.resetLine` as fake reset text.
- Add M2 tests and update M2 task/history documentation.

## Forbidden Scope

Codex must not:

- Implement or repair M2 product code.
- Rewrite Claude / GLM commits without Bee's explicit approval.
- Merge a PR without Bee's explicit approval.

Claude / GLM must not:

- Create, delete, rename, or push branches or worktrees.
- Add, remove, or modify Git remotes.
- Open, update, close, or merge Pull Requests.
- Replace upstream history with a detached copy or squashed import.
- Mix an upstream synchronization with Ark feature implementation.
- Touch Widget snapshot, picker, intent, or UI feature code (S5–S7).
- Add `ProviderChoice.ark`, an Ark `DisplayRepresentation`, Widget picker
  availability, snapshot behavior, layout wiring, or any visible Ark Widget
  capability. Existing M1 S10/S11 compiler-closure arms must remain
  non-functional.
- Change Ark signing, networking, endpoint, credential persistence, or menu-bar
  selection behavior unless a separately approved correctness defect requires
  it.
- Modify any shared menu-card integration point beyond the exact approved S15
  one-branch router edit.
- Add a typed Ark payload to shared `RateWindow` or `UsageSnapshot` (proposed
  future S16); Option B is not approved for M2.
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

## Next Task — Bee M2 Gate Decision

1. Review the PASS evidence in `docs/PROJECT_LOG.md` Entry 050.
2. Decide whether Codex may push `feature/m2-ark-popover-details` and open its
   draft PR. This does not authorize merge.
3. Decide separately, after PR review, whether M2 may merge and whether M3 may
   open.
4. Until Bee decides, do not push, open/update a PR, merge, enter M3, or change
   product source.

## Definition of Done — M2

M2 is Done only when:

- LOOP was used or explicitly referenced before execution.
- The popover presents available 5h, Daily, Weekly, and Monthly AFP rows in
  that order using the existing menu-card architecture.
- Every row communicates used, quota, remaining, and reset information when
  those values are known; unknown values are omitted or marked unavailable
  without being rendered as zero.
- Partial-window snapshots, stale snapshots, refresh failures, and unavailable
  usage produce safe, understandable UI states.
- M1 signing, networking, credential, four-window normalization, and automatic
  menu-bar selection behavior remain unchanged.
- Ark popover/model behavior has focused tests, including four complete
  windows, partial/missing values, and reset/error behavior.
- `swift build`, `make test`, and `make check` pass, or any environment-only
  blocker is documented honestly and reproduced by Codex.
- Any shared S15+ touch is pre-approved, minimal, tested, listed in
  `docs/M0_INTEGRATION_BOUNDARY.md`, and has an explicit rollback.
- No functional Widget, unrelated-provider, upstream-sync, credential,
  networking, or broad-refactor change is included.
- `docs/PROJECT_LOG.md` has M2 implementation and Codex audit records.
- Codex review is complete.
- Bee approves merge or moving to M3.

## Planned Milestones After M2

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

These must be resolved by the M2 preflight before the corresponding edit:

1. What is the least-privilege IAM action/policy required for `GetAFPUsage`?
2. Can all four Ark rows and quota details be expressed through Ark-owned
   snapshot metadata, or is one minimal shared menu-card S15 touch required?
3. What exact presentation avoids treating quota detail as reset text while
   still showing used, quota, remaining, and the real reset time?

## Current Decision

Default MVP display strategy:

```text
Menu bar: highest-risk window, otherwise 5-hour window.
Popover: 5h / Daily / Weekly / Monthly rows in order, with known
used / quota / remaining / reset detail.
Small Widget: Ark AFP percentage + reset.
Medium Widget: 5h / daily / weekly / monthly summary.
```

Widget lines are planning intent only and remain forbidden until M3/M4.
