# TASKS.md — Current Task State

> This file owns the current active goal. No other file may maintain a competing active goal.

## Active Goal

```text
M4 — Ark Widget Provider Picker + Small/Medium UI
```

## Goal Status

```text
Status: M4 AUDIT FAIL — Medium Ark Widget vertically overflows
Audit State: a711f4b7 passes all code/mechanical gates and Small visual QA, but
the exact 338x158 Medium Usage view clips the provider/updated header and the
Monthly supplemental line. See PROJECT_LOG Entry 067.
Next: Claude makes one bounded S7 corrective commit so Medium Usage/Switcher
retain their header/switcher plus all four title/percent/bar rows; lower-priority
detail/reset may be omitted under vertical pressure per Entry 058.
Implementation Owner: Claude / GLM Developer
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
M3 merged PR: https://github.com/zeronxpbee-droid/codexbar-ark-usage-fork/pull/4
M3 merge commit: 9a24cf7356b6cace5fdbaeac5424609093245887
M4 branch: feature/m4-ark-widget-picker-ui
```

## Mandatory Pre-Execution Rule

Before development or review, invoke or explicitly compare the task against
LOOP and inspect the upstream baseline `AGENTS.md`. If project documents
conflict, stop and report drift.

## M4 Objective

Make Ark selectable in the appropriate Widget configuration/switcher surface
and render useful small and medium Widget states from the M3 persisted
5h/Daily/Weekly/Monthly rows.

M4 owns picker/intent wiring and visible small/medium presentation only. It
must consume the app-owned snapshot and must not call Ark directly.

## Preflight Findings

1. M3 already persists stable Ark rows with `percentLeft`, `resetsAt`, and
   opaque `detailText`; M4 needs no schema or network change.
2. `ProviderChoice` currently drives all of:
   - `CodexBar Usage`;
   - `CodexBar History`;
   - `CodexBar Metric` through `CompactMetricSelectionIntent`;
   - the static switcher's supported-provider filter and buttons.
   Adding one `.ark` case therefore exposes Ark beyond the requested Usage
   small/medium surface. History has no Ark daily history, and Metric offers
   credits/cost values Ark does not provide.
3. The current `WidgetUsageRow` projection copies only id/title/percent and
   drops M3's `resetsAt` and `detailText`. `UsageBarRow` renders only title,
   percentage, and bar. S7 is required to make the M3 payload visible.
4. Small and medium row limits are Ark-unaware. Small would currently render
   all four Ark rows, risking crowding; medium also renders all four but has no
   space policy for complete quota detail plus reset text.
5. Existing large Usage and Switcher families share the same row views.
   Enabling Ark selection may also make large rendering reachable even though
   FR7 requires only small and medium behavior.

## Approved Shared Touchpoints

### S6 — Ark Widget provider choice (APPROVED)

- File: `Sources/CodexBarWidget/CodexBarWidgetProvider.swift`
- Approved edit: add `.ark`, display representation `"Ark"`,
  `.ark -> .ark`, and change `init?(provider: .ark)` from `nil` to `.ark`.
- Ark may appear in `CodexBar Usage` and the static Switcher only.
- Add intent-specific `DynamicOptionsProvider` filtering in the same file so
  History and Metric exclude `.ark` without splitting/renaming the persisted
  `ProviderChoice` enum or invalidating existing configurations.
- Risk: Medium. The enum is shared, but picker filtering contains the new
  exposure while preserving existing raw values.
- Rollback: restore `.ark -> nil`, remove the enum/display/provider arms and
  intent-specific filters.

### S7 — Ark small/medium row presentation (APPROVED)

- File: `Sources/CodexBarWidget/CodexBarWidgetViews.swift`
- Approved edit: preserve `resetsAt`/`detailText` in `WidgetUsageRow`, define
  the Ark-specific selection/presentation below, and route only Ark through
  that presentation.
- Small Usage/Switcher:
  - choose the known row with the lowest `percentLeft` (highest risk);
  - preserve stable source order on ties;
  - if no row has known usage, show the first stable Ark row as unavailable;
  - render title, percent/bar, opaque detail, and relative reset using a
    compact fallback that omits lower-priority text rather than crowding.
- Medium Usage/Switcher:
  - retain all available Ark rows in stable 5h/Daily/Weekly/Monthly order;
  - render compact title + percent/bar for every row;
  - use a horizontal-fit fallback for opaque detail and relative reset so
    provider/updated state is not displaced.
- Large behavior is not an M4 deliverable. It may continue using generic rows
  but must not receive new Ark-only layout logic.
- Do not parse `detailText`; reset display derives only from `resetsAt`.
- All generic behavior for existing providers must remain unchanged.
- Risk: Medium. This file owns shared Usage and Switcher layouts across small,
  medium, and large families.
- Rollback: remove Ark-specific projection/selection/presentation and restore
  percentage-only rows.

### S19 — History Widget registration isolation (APPROVED)

- File: `Sources/CodexBarWidget/CodexBarWidgetBundle.swift`
- Approved edit: change only the History Widget intent/timeline registration
  required to give History a filtered provider-options source while Usage
  retains its existing registration.
- The History intent parameter must remain the existing `ProviderChoice` type.
- Risk accepted by Bee: changing the History intent type may reset an existing
  History Widget configuration.
- Metric must keep its existing intent and `ProviderChoice` parameter type;
  its Ark exclusion uses filtered options and must not introduce a Metric
  configuration-type reset.
- Rollback: restore the original History `ProviderSelectionIntent` /
  `CodexBarTimelineProvider` registration.

## Allowed Implementation Scope

Codex may:

- Inspect the M4 diff and record audit evidence.
- Maintain governance records and the M4 branch.
- Register a Bee-approved S19 boundary, then authorize a bounded corrective
  loop.

Claude / GLM may:

- Modify only `Sources/CodexBarWidget/CodexBarWidgetViews.swift`,
  `Tests/CodexBarTests/CodexBarWidgetProviderTests.swift`,
  `docs/TASKS.md`, and `docs/PROJECT_LOG.md` for the Entry 067 Medium-layout
  correction.
- Preserve the passing Small Ark layout, non-Ark behavior, and large-family
  behavior.

## Forbidden Scope

- No Widget API call to Ark.
- No Ark exposure in History, Metric, burn-down, or any new Widget kind.
- No change to Ark signing, networking, credentials, menu bar, or popover.
- No `supportsOpus=true` workaround.
- No S16 typed popover payload.
- No new snapshot schema, unrelated provider, dependency, generated-file, or
  global Widget
  architecture change.
- No push, PR, merge, release, destructive operation, or history rewrite
  without Bee approval.

## Next Task — M4 Medium Vertical-Fit Correction

1. Start additively from the Codex Entry 067 audit-document commit; no
   amend/reset/rebase.
2. In both Medium Usage and Medium Switcher, keep the provider header/switcher
   and all four 5h/Daily/Weekly/Monthly title + percent + bar rows visible at
   338x158.
3. Apply the approved Entry 058 priority: omit lower-priority detail/reset
   lines when vertical space is insufficient; do not crowd or clip the header
   or required rows. Keep Small behavior unchanged.
4. Add focused regression coverage without introducing a new shared
   touchpoint, snapshot schema, or Widget architecture.
5. Run `git diff --check`, targeted SwiftFormat/SwiftLint, `swift build`,
   `swift test --filter CodexBarWidgetProviderTests`, and
   `swift test --filter Ark`; create one additive local commit and stop.
6. Codex repeats Small/Medium visual QA and final `make check`. No push, PR,
   merge, M5, or release before final M4 PASS and Bee approval.

## Definition of Done — M4

M4 is Done only when:

- LOOP and baseline rules were followed.
- Bee approves the exact picker and layout policy.
- Ark is selectable only in the approved Widget surfaces.
- Small Widget shows a useful Ark usage/reset state under the approved policy.
- Medium Widget shows the four available Ark windows in stable order.
- Unknown/missing windows remain unavailable/omitted rather than zero.
- M3 `resetsAt`/`detailText` data is consumed without parsing opaque detail.
- Widget performs no Ark network call.
- Existing provider Widget behavior remains unchanged.
- Focused picker, row projection/selection, and small/medium model tests pass.
- `swift build`, relevant Widget/Ark tests, `make test`, and `make check` pass,
  or an
  environment-only blocker is reproduced and recorded.
- Codex audits the complete M4 diff and records PASS/FAIL.
- Bee approves merge or moving to M5.

## Planned Milestones After M4

- After M4 merge: archive closed M1/M2 PROJECT_LOG segments, then start M5 in
  a fresh thread.
- M5 — Stabilization and local release candidate.
- M6 — Optional upstream contribution review.
