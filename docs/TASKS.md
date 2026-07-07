# TASKS.md — Current Task State

> This file owns the current active goal. No other file may maintain a competing active goal.

## Active Goal

```text
M5A — Ark Fork Installation Identity Implementation
```

## Goal Status

```text
Status: M5A FINAL AUDIT FAIL — package signing fix required
Audit State: Entry 085 fixed the SettingsStore syntax issue; Codex Entry 086
confirmed make check, swift build, and focused tests pass, but
`Scripts/package_app.sh debug` fails while signing Sparkle
`Downloader.xpc` because resource fork/Finder detritus is still present before
Sparkle nested signing.
Next: Claude creates an additive package-script corrective commit, repeats
Self-Check, then independent Pre-Auditor re-checks the exact corrected SHA
before Codex reruns the two-stage audit.
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
recommendations. Bee subsequently approved the final contract below.

Approved decisions:

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
installation identity. The approved contract below preserves that boundary.

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

The feasibility result is implemented only through the approved contract below.

## Approved M5A Implementation Contract

The Claude preflight is not adopted wholesale. The following revised
touchpoints are the complete approved M5A implementation boundary:

| ID | Exact surface | Allowed result |
|---|---|---|
| S20 | `Scripts/package_app.sh`, `Scripts/compile_and_run.sh`, `Scripts/launch.sh`, `Makefile`, `WidgetExtension/project.yml`, `WidgetExtension/Info.plist`, generated Widget `.pbxproj` | Package `CodexBar Ark.app`; release/debug app IDs use `com.zeronxpbee.codexbar-ark[.debug]`; Widget ID derives with `.widget`; visible app/Widget name is `CodexBar Ark`; internal Swift package/module/target/executable names stay unchanged |
| S21 | `Sources/CodexBarCore/AppGroupSupport.swift`, packaging entitlements/team plumbing in S20 files, `Tests/CodexBarTests/AppGroupSupportTests.swift` | Fixed release/debug groups `group.com.zeronxpbee.codexbar-ark[.debug]`; remove official Team-ID dependence; fork legacy candidates must never point at official groups; fallback directory becomes `CodexBarArk` but is not the Widget sharing contract |
| S22 | `Sources/CodexBarCore/Config/CodexBarConfigStore.swift`, `Tests/CodexBarTests/ConfigValidationTests.swift` | Default/XDG directory is `codexbar-ark`; `CODEXBAR_CONFIG` override remains; remove automatic fallback to official `~/.codexbar` or `~/.config/codexbar`; preserve atomic writes and mode `0600` |
| S23 | `Sources/CodexBarCore/KeychainCacheStore.swift`; `Sources/CodexBar/{CookieHeaderStore,CopilotTokenStore,KeychainMigration,KimiK2TokenStore,KimiTokenStore,MiniMaxAPITokenStore,MiniMaxCookieStore,SyntheticTokenStore,ZaiTokenStore}.swift`; `Scripts/compile_and_run.sh`; `Tests/CodexBarTests/KeychainMigrationTests.swift` | CodexBar-owned services become `com.zeronxpbee.codexbar-ark.cache` and `com.zeronxpbee.codexbar-ark`; migration/clear paths operate only on fork services; no real Keychain tests, official-service reads, deletes, or copies |
| S25 | Sparkle plist generation in `Scripts/package_app.sh` plus fork identity script tests | Every fork build has no official feed, no official Sparkle public key, and automatic checks disabled; retain the existing framework and upstream ad-hoc `DisabledUpdaterController` behavior |
| S26 | signing branches in `Scripts/package_app.sh` / `Scripts/compile_and_run.sh`; `Scripts/sign-and-notarize.sh`; `Scripts/release.sh`; `.mac-release.env`; `Scripts/test_package_signing.sh` | Default local path is ad-hoc; identity signing requires explicit future fork credentials; remove/disable official identity, key path, feed, repo, notarization, and release defaults; signed/notarized release remains unavailable in M5A |
| S27 | `Sources/CodexBarCLI/CLIHelpers.swift`, `bin/install-codexbar-cli.sh` and focused tests/docs | CLI reads fork release/debug defaults domains; installer targets `CodexBar Ark.app` and command `codexbar-ark`, so it cannot replace the official `codexbar` symlink |
| S29 | current user/developer/provider docs that contain the changed app path, config path, Widget ID, or CodexBar-owned Keychain services | Mechanically synchronize fork values; update `README.md`, Widget/CLI/configuration/development/keychain docs and affected provider guides; do not rewrite archives, historical reports, old design specs, or unrelated upstream documentation |

Rejected from M5A:

- S24 broad Application Support/history/account/cost-cache/log isolation moves
  to M5B.
- S28 osLog, DispatchQueue, Notification, and RunLoop labels move to M5B.
- No `Package.swift` product/module/target rename.
- No Ark provider, API, menu, popover, snapshot schema, or Widget UI change.
- No official config/App Group/Keychain migration or secret-bearing fixture.

Implementation must treat the identity set atomically. Partial rollback is not
safe; rollback reverts every M5A implementation commit in reverse order.

Required evidence before Developer handoff:

1. `git diff --check`, project-pinned format/lint, `swift build`.
2. Script identity/signing tests, AppGroupSupport, ConfigValidation,
   KeychainMigration, ArkCredentialProjection, and relevant Widget tests.
3. Final-candidate `make check` and `make test`.
4. Package exact `CodexBar Ark.app`; inspect app/Widget IDs, matching
   entitlements, ad-hoc signature, absent official feed/key, and disabled
   automatic checks.
5. Keep official `CodexBar.app` installed while registering/launching only the
   fork; verify the fork Widget reads the fork snapshot.
6. No simultaneous-run test, real Keychain read, automatic credential copy,
   official release command, notarization, or secret output.

## Allowed Implementation Scope

Codex may:

- Maintain the M5A branch and governance records.
- Audit the implementation and operate Git/PR state after the required gates.
- Commit governance/audit records only; do not implement product fixes.

Claude / GLM may:

- Implement only S20/S21/S22/S23/S25/S26/S27/S29 and required focused tests.
- Modify the exact existing files/surfaces listed in the approved contract.
- Add a fork-identity shell test when needed for deterministic script checks.
- Update current operational documentation under S29 only.
- Create additive local commits and complete Developer Self-Check.

## Forbidden Scope

- No source, packaging, identity, persistence, Keychain, signing, release,
  test, or documentation edit outside the approved contract.
- No new dependency, release credential, Sparkle key, certificate, profile,
  secret, real config, or credential migration.
- No change to Ark API, provider, menu bar, popover, snapshot, or Widget UI.
- No assumption that changing only the `.app` filename provides isolation.
- No use of the official CodexBar signing identity or Sparkle private key.
- No push, PR, merge, release, destructive operation, or history rewrite
  without Bee approval.

## Next Task — Claude Corrective Commit + Self-Check

1. Claude invokes LOOP and verifies the exact branch/HEAD/worktree.
2. Fix Entry 086 only: make `Scripts/package_app.sh debug` package
   `CodexBar Ark.app` successfully by clearing copied Sparkle/app detritus
   before Sparkle nested signing; do not broaden beyond M5A packaging.
3. Add/update deterministic tests for those fixes without real Keychain access,
   release credentials, notarization, official-data migration, S24, or S28.
4. Create additive local commit(s), then perform same-thread Self-Check against
   the complete corrected M5A diff.
5. Handoff only a clean exact candidate with `SELF-CHECK PASS`.
6. A new independent Claude thread performs read-only Pre-Audit. Codex Final
   Audit starts only after `PRE-AUDIT PASS` for the same SHA.

## Definition of Done — M5A Implementation

- S20/S21/S22/S23/S25/S26/S27/S29 are implemented exactly; S24/S28 remain
  untouched.
- Official and fork App, Widget, App Group, config, Keychain, updater, and CLI
  identities do not collide within the approved M5A boundary.
- Internal Swift package/module/target/executable names remain unchanged.
- No official credential/config/App Group data is read, copied, deleted, or
  migrated by fork-owned storage paths.
- Required script, focused Swift, build, format/lint, final test, packaging,
  entitlement, and Widget snapshot evidence passes.
- Developer Self-Check and independent Pre-Audit pass for the exact candidate.
- Codex Final Audit is recorded and Bee approves push/PR/merge separately.

## Planned Milestones

- M5A — Installation identity isolation and local release candidate.
- M5B — Optional full simultaneous-run and fork-owned update isolation.
- M6 — Optional upstream contribution review.
