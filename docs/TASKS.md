# TASKS.md — Current Task State

> This file owns the current active goal. No other file may maintain a competing active goal.

## Active Goal

```text
M5A — Ark Fork Installation Identity Preflight
```

## Goal Status

```text
Status: ACTIVE — PREFLIGHT PHASE 2 COMPLETE; implementation not authorized
Audit State: M4 merged as b40762d8. Bee approved opening M5 independent-
identity preflight. Closed M1/M2 logs are archived through Entry 051.
Claude reports 23 collision surfaces, 9 S20+ proposals, and 8 decision
questions. Codex completed the bounded Stage 1 decision screen and Phase 2
App Group/signing/storage feasibility proof. Bee accepted the Stage 1/2
recommendations. Next: Codex estimates and, only after any required approval,
performs the final S20+ contract review before any source, packaging,
identifier, config, Keychain, or updater change.
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
9 S20+ proposals. The detailed decision package received a bounded Stage 1
screen and Phase 2 feasibility proof. Bee accepted the resulting identity,
signing, update, migration, App Group, documentation, and M5B-deferral
recommendations. No S20+ touchpoint is approved.

The approved recommendations do not authorize implementation:

| Question | Codex recommendation |
|---|---|
| Q1 Bundle ID | `com.zeronxpbee.codexbar-ark`; debug adds `.debug`; Widget derives `.widget` |
| Q2 visible name | `CodexBar Ark` / `CodexBar Ark.app`; keep Swift package, module, target, process, and executable names unchanged |
| Q3 signing | M5A uses the upstream-supported ad-hoc path only |
| Q4 Sparkle | no official feed or automatic checks in any fork build; keep the existing framework unless Phase 2 proves more is required |
| Q5 migration | fresh isolated state; no automatic config, Keychain, snapshot, defaults, or support-directory copying; Bee re-enters Ark credentials |
| Q6 App Group | use fixed `group.com.zeronxpbee.codexbar-ark` (`.debug` for debug); do not use the official Team ID or Application Support fallback as the sharing contract |
| Q7 documentation | update `docs/widgets.md` together with the eventual implementation |
| Q8 diagnostics | defer osLog, queue labels, notification names, and run-loop labels to M5B |

Stage 1 also found that the physical `.app` filename is part of Q2 and that
renaming `Package.swift` products/modules would add conflict without helping
installation identity. No S20+ touchpoint is approved.

### Phase 2 Feasibility Result

Codex ran a disposable, ad-hoc-signed App Group probe on macOS 26.4.1. Both an
ordinary App-equivalent process and an App-Sandbox-enabled Widget-equivalent
process read the same seeded marker through
`FileManager.containerURL(forSecurityApplicationGroupIdentifier:)`. The
recommended fixed `group.com.zeronxpbee.codexbar-ark` form worked without a
Team Identifier in the ad-hoc signature. All uniquely named probe containers
and crash reports were removed afterward; the repository remained clean.

This proves the local M5A path, not future distribution. A future Developer ID
or App Store build must register/authorize the group for that signing team.
The Application Support fallback remains only a failure fallback; it is not a
valid cross-sandbox sharing contract.

Minimum M5A fresh-state storage boundary:

- use a new config path with no fallback read from official CodexBar;
- use the fixed fork App Group for Widget snapshot/shared defaults, with no
  migration read from official or legacy groups;
- rely on the new Bundle ID to isolate standard `UserDefaults`;
- give CodexBar-owned Keychain services fork-specific names and prevent the
  fork's migration pass from reading official CodexBar services;
- leave external provider-owned credentials, such as Claude CLI credentials,
  under their provider-owned identities;
- defer unrelated Application Support history/account caches, cost caches,
  logs, and diagnostic labels to M5B, with the explicit limitation that M5A is
  not full simultaneous-run/storage isolation.

No S20+ touchpoint is approved by this feasibility result.

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

## Next Task — M5A Final Contract Decision Gate

1. Codex estimates the cost of final S20–S28 contract review and waits for Bee
   if it is high.
2. After approval, Codex narrows, reclassifies, or rejects the proposed
   touchpoints against the
   confirmed decisions; the Claude package is not adopted wholesale.
3. Record the approved implementation contract in governance documents.
4. Only then may Bee authorize implementation. Claude must not implement from
   the unapproved preflight package.

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
