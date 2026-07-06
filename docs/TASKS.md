# TASKS.md — Current Task State

> This file owns the current active goal. No other file may maintain a competing active goal.

## Active Goal

```text
M5A — Ark Fork Installation Identity Preflight
```

## Goal Status

```text
Status: ACTIVE — PREFLIGHT REPORTED COMPLETE; implementation not authorized
Audit State: M4 merged as b40762d8. Bee approved opening M5 independent-
identity preflight. Closed M1/M2 logs are archived through Entry 051.
Claude reports 23 collision surfaces, 9 S20+ proposals, and 8 decision
questions. Codex has received only the completion summary, not the detailed
tables/evidence. Next: transfer the compact preflight report, estimate review
cost, then Bee/Codex decide exact implementation scope before any source,
packaging, identifier, config, Keychain, or updater change.
Preflight Owner: Claude / GLM Developer (fresh thread, read-only)
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
M4 merged PR: https://github.com/zeronxpbee-droid/codexbar-ark-usage-fork/pull/5
M4 merge commit: b40762d8f259b286f82f6280ec3c5a777a379a60
M5A branch: feature/m5a-ark-installation-isolation
```

## Mandatory Pre-Execution Rule

Before development or review, invoke or explicitly compare the task against
LOOP and inspect the upstream baseline `AGENTS.md`. If project documents
conflict, stop and report drift.

## Review Pipeline

Bee approved the four-stage review workflow in PROJECT_LOG Entry 068:

1. Claude Developer implements the active task.
2. The same thread performs Developer Self-Check and fixes until
   `SELF-CHECK PASS`.
3. A new independent Claude thread performs read-only Pre-Audit and returns
   `PRE-AUDIT PASS` or findings.
4. Codex performs Final Audit only after both prior gates pass for the exact
   candidate SHA.

Any source/test change invalidates the prior Self-Check and Pre-Audit.
Reusable prompts and output contracts are in
`docs/CLAUDE_REVIEW_WORKFLOW.md`.

## M5A Objective

Design the smallest upstream-aligned packaging/storage identity profile that
lets official CodexBar and the Ark fork coexist without one replacing or
invalidating the other.

The preflight must cover:

- app display name and app Bundle ID;
- Widget Bundle ID and WidgetKit registration;
- App Group ID and snapshot/defaults migration;
- config path using the existing `CodexBarConfigStore` with mode `0600`;
- Keychain cache service names and other persistent support directories;
- Sparkle feed/public key/automatic-update behavior;
- ad-hoc versus Developer ID signing and local installation;
- side-by-side installation versus simultaneous execution;
- minimal rollback and migration tests.

Preferred phased target for evaluation:

- M5A solves safe side-by-side installation and prevents official updates from
  overwriting the fork;
- the fork uses no official Sparkle feed;
- simultaneous execution and a fork-owned update service may be deferred to
  M5B if isolating every cache is disproportionately broad.

## Preflight Status

Claude reports the read-only survey complete: 23 collision surfaces mapped to
9 S20+ proposals, with 21 surfaces proposed for M5A and 2 low-priority items
deferrable to M5B; 8 decisions remain. The detailed collision map, touchpoint
table, evidence, and decision questions have not yet been transferred to
Codex. No S20+ touchpoint is approved.

## Allowed Implementation Scope

Codex may:

- Maintain the M5A branch and governance records.
- Inspect packaging, identity, persistence, and updater architecture.
- Record proposed S20+ touchpoints after Bee reviews the preflight.

Claude / GLM may:

- Perform read-only investigation in a fresh thread.
- Compare release/debug packaging and official upstream patterns.
- Return a compact touchpoint proposal; make no repository edits or commits.

## Forbidden Scope

- No product, source, test, packaging, entitlement, identifier, config,
  Keychain, updater, signing, or migration implementation during preflight.
- No new dependency, release credential, Sparkle key, certificate, profile,
  secret, real config, or credential migration.
- No change to Ark API, provider, menu bar, popover, snapshot, or Widget UI.
- No assumption that changing only the `.app` filename provides isolation.
- No use of the official CodexBar signing identity or Sparkle private key.
- No push, PR, merge, release, destructive operation, or history rewrite
  without Bee approval.

## Next Task — M5A Preflight Decision Gate

1. Transfer Claude's complete compact collision map, S20+ table, evidence, and
   8 decision questions; do not substitute the completion summary.
2. Codex estimates the review's token cost before starting substantive review
   and warns Bee first if it is likely high.
3. Bee/Codex accept, revise, defer, or reject each proposed touchpoint and
   define the exact M5A/M5B boundary.
4. Record the approved contract in governance documents.
5. Only then may Bee authorize implementation. Claude must not implement from
   the unapproved preflight summary.

## Definition of Done — M5A Preflight

- Official and fork collision mechanisms are evidence-backed.
- App, Widget, App Group, config, Keychain, support storage, signing, and
  updater identities are all accounted for.
- Minimum side-by-side installation scope is separated from optional
  simultaneous-run/full-release scope.
- Every proposed shared edit is a numbered S20+ touchpoint.
- Migration avoids printing, committing, or silently copying secrets.
- Rollback and verification commands are concrete.
- Repository remains clean and no product/packaging code is changed.
- Bee approves or rejects the implementation contract.

## Planned Milestones

- M5A — Installation identity isolation and local release candidate.
- M5B — Optional full simultaneous-run and fork-owned update isolation.
- M6 — Optional upstream contribution review.
