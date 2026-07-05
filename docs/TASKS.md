# TASKS.md — Current Task State

> This file owns the current active goal. No other file may maintain a competing active goal.

## Active Goal

```text
M3 — Ark Widget Snapshot Integration
```

## Goal Status

```text
Status: M3 INDEPENDENT PREFLIGHT — proposed S17/S18 awaiting Bee architecture decision
Implementation State: No M3 product code; existing snapshot path audited from M2 merge baseline 27ec5fa0
Next: Bee approves/rejects proposed S17 and chooses whether S18 schema detail is required in M3
Implementation Owner: Claude / GLM Developer (after approval)
Repository Operator / Auditor: Codex
Architecture / Decision: Bee + ChatGPT
```

## Repository Baseline

```text
Fork: https://github.com/zeronxpbee-droid/codexbar-ark-usage-fork
origin: https://github.com/zeronxpbee-droid/codexbar-ark-usage-fork.git
upstream: https://github.com/steipete/CodexBar.git
Upstream push: Disabled
Default branch: main
Upstream baseline: 6ab1cbb7daee73b8ad531fbdd420e9aa6eb6d26b
M1 merge commit: 239e42721d4b4e4a623b10efc8b52f70d4420287
M2 merged PR: https://github.com/zeronxpbee-droid/codexbar-ark-usage-fork/pull/3
M2 merge commit: 27ec5fa07548b4fd5774b842134344d16fe83205
M3 branch: feature/m3-ark-widget-snapshot
```

## Mandatory Pre-Execution Rule

Before development or review, invoke or explicitly compare the task against
LOOP and inspect the upstream baseline `AGENTS.md`. If project documents
conflict, stop and report drift.

## M3 Objective

Make Ark's confirmed 5h, Daily, Weekly, and Monthly AFP windows available in
CodexBar's existing Widget-readable snapshot. The Widget extension must read
the persisted app snapshot and must not call Ark directly.

M3 owns snapshot production and snapshot tests only. Widget provider picker,
intent registration, and visible small/medium Widget UI remain M4.

## Preflight Findings

1. `UsageStore.makeWidgetEntry(for:)` already creates a generic Ark provider
   entry whenever an Ark `UsageSnapshot` exists.
2. The default `widgetUsageRows` path emits primary and secondary rows only;
   tertiary is gated by `metadata.supportsOpus`, which remains false for Ark.
3. Monthly exists only in `UsageSnapshot.extraRateWindows`; the current
   `WidgetSnapshot.ProviderEntry` has no extra-window field.
4. `WidgetUsageRowSnapshot` currently carries only `id`, `title`, and
   `percentLeft`. It cannot preserve reset timestamps or M2's opaque complete
   used/quota/remaining detail.
5. M1's `ProviderChoice(provider: .ark) -> nil` compile stub remains correct:
   Ark must stay unselectable until M4.

## Proposed Shared Touchpoints — Awaiting Bee

### S17 — Ark snapshot-row routing

- File: `Sources/CodexBar/UsageStore+WidgetSnapshot.swift`
- Proposed edit: one additive `.ark` branch in `widgetUsageRows`, delegating
  four-window row construction to Ark-owned code.
- Purpose: ensure 5h, Daily, Weekly, and Monthly rows are persisted even while
  `supportsOpus` stays false.
- Rollback: remove the branch and Ark-owned helper.
- Risk: Low–Med, line-local shared snapshot producer.

### S18 — Optional generic row detail fields

- File: `Sources/CodexBarCore/WidgetSnapshot.swift`
- Proposed edit: add backward-compatible optional row fields sufficient to
  preserve reset time and display detail (exact field design requires Bee
  decision/preflight validation).
- Purpose: avoid losing Monthly reset and used/quota/remaining information
  before M4 rendering.
- Rollback: remove optional fields and their Ark mapping.
- Risk: Medium, shared persisted snapshot schema.

S17 and S18 are proposals only. No implementation is authorized until Bee
decides whether M3 stores percentages only or the full M4-ready detail.

## Allowed Scope Before Approval

Codex may:

- Inspect snapshot producer/schema/tests and document evidence.
- Maintain the M3 branch and governance records.
- Propose shared touchpoints and rollback paths.

Claude / GLM may not write M3 product or test code before approval.

## Forbidden Scope

- No Widget API call to Ark.
- No `ProviderChoice.ark`, picker, intent, display representation, preview, or
  visible Widget UI (M4).
- No change to Ark signing, networking, credentials, menu bar, or popover.
- No `supportsOpus=true` workaround.
- No S16 typed popover payload.
- No unrelated provider, dependency, generated-file, or global Widget
  architecture change.
- No push, PR, merge, release, destructive operation, or history rewrite
  without Bee approval.

## Next Task — Bee M3 Architecture Gate

1. Approve or reject S17.
2. Choose one M3 snapshot contract:
   - percentages-only four rows (S17 only); or
   - M4-ready rows preserving reset/detail (S17 + backward-compatible S18).
3. After approval, Codex records the exact field/row contract and Claude / GLM
   creates one additive implementation commit with focused snapshot tests.

## Definition of Done — M3

M3 is Done only when:

- LOOP and baseline rules were followed.
- Ark snapshot contains all four available windows in stable order.
- Unknown/missing windows are not invented as zero.
- The approved reset/detail contract is preserved.
- Snapshot persistence remains app-owned; Widget performs no Ark network call.
- Ark remains unselectable and visually unsupported until M4.
- Focused snapshot encode/decode and `UsageStore` persistence tests pass.
- `swift build`, Ark/snapshot tests, `make test`, and `make check` pass, or an
  environment-only blocker is reproduced and recorded.
- Codex audits the complete M3 diff and records PASS/FAIL.
- Bee approves merge or moving to M4.

## Planned Milestones After M3

- M4 — Widget Provider Picker + Small/Medium UI.
- M5 — Stabilization and local release candidate.
- M6 — Optional upstream contribution review.
