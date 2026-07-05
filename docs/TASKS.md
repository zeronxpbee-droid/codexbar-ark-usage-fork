# TASKS.md — Current Task State

> This file owns the current active goal. No other file may maintain a competing active goal.

## Active Goal

```text
M3 — Ark Widget Snapshot Integration
```

## Goal Status

```text
Status: M3 S17+S18 IMPLEMENTED — additive commit created (see PROJECT_LOG Entry 053)
Implementation State: S17 Ark four-window row mapper + S18 optional resetAt/detailText schema fields + focused encode/decode and snapshot tests; product source frozen for audit
Next: Codex audits the complete M3 diff and records PASS/FAIL
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

## Approved Shared Touchpoints

### S17 — Ark snapshot-row routing (APPROVED)

- File: `Sources/CodexBar/UsageStore+WidgetSnapshot.swift`
- Proposed edit: one additive `.ark` branch in `widgetUsageRows`, delegating
  four-window row construction to Ark-owned code.
- Purpose: ensure 5h, Daily, Weekly, and Monthly rows are persisted even while
  `supportsOpus` stays false.
- Rollback: remove the branch and Ark-owned helper.
- Risk: Low–Med, line-local shared snapshot producer.

### S18 — Generic row reset/detail fields (APPROVED)

- File: `Sources/CodexBarCore/WidgetSnapshot.swift`
- Approved edit: add `resetAt: Date?` and `detailText: String?` to
  `WidgetUsageRowSnapshot`, both defaulting to `nil` in the initializer and
  decoding as optional for backward compatibility.
- Purpose: avoid losing Monthly reset and used/quota/remaining information
  before M4 rendering.
- Rollback: remove optional fields and their Ark mapping.
- Risk: Medium, shared persisted snapshot schema.

Ark's mapper must write four stable rows in the order 5h, Daily, Weekly,
Monthly. Each known row carries `percentLeft`, `resetAt`, and the existing M2
opaque `resetDescription` value as `detailText`; no string parsing is allowed.
Unknown/missing windows must remain unavailable/omitted rather than invented
as zero.

## Allowed Implementation Scope

Codex may:

- Inspect snapshot producer/schema/tests and document evidence.
- Maintain the M3 branch and governance records.
- Propose shared touchpoints and rollback paths.

Claude / GLM may:

- Add Ark-owned
  `Sources/CodexBar/Providers/Ark/ArkWidgetSnapshotRows.swift`.
- Add the exact S17 Ark branch in `UsageStore+WidgetSnapshot.widgetUsageRows`.
- Add the exact S18 optional fields and backward-compatible coding behavior.
- Add focused encode/decode and `UsageStore` snapshot tests.
- Update `docs/TASKS.md` and `docs/PROJECT_LOG.md`.

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

## Next Task — Codex M3 S17+S18 Audit

1. Re-read project governance, TASKS, PROJECT_LOG, boundary map, LOOP, and the
   upstream baseline rules.
2. Verify branch `feature/m3-ark-widget-snapshot` descends from governance
   approval commit `9f86ce4d` and the additive implementation commit below.
3. Run `git diff --check`, `swift build`, focused Ark/snapshot tests,
   `make test`, and `make check`; record exact outcomes.
4. Verify the corrective diff is exactly:
   - `Sources/CodexBarCore/WidgetSnapshot.swift` (S18 schema);
   - `Sources/CodexBar/UsageStore+WidgetSnapshot.swift` (S17 routing branch);
   - `Sources/CodexBar/Providers/Ark/ArkWidgetSnapshotRows.swift` (S17 mapper);
   - `Tests/CodexBarTests/WidgetSnapshotS18Tests.swift` (S18 tests);
   - `Tests/CodexBarTests/ArkWidgetSnapshotRowsTests.swift` (S17 tests);
   - `docs/TASKS.md`;
   - `docs/PROJECT_LOG.md`.
5. Confirm stable 5h/Daily/Weekly/Monthly ordering, missing/unknown window
   handling, S18 backward compatibility (old JSON decodes, round-trip, nil
   fields omit keys), and no M4 picker/UI/scope expansion.

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
