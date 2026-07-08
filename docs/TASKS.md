# TASKS.md — Current Task State

> This file owns the current active goal. No other file may maintain a competing active goal.

## Active Goal

```text
M5B — Local-Use Isolation Implementation Contract
```

## Goal Status

```text
Status: M5B PREFLIGHT COMPLETE — awaiting Bee approval to start implementation branch
Current branch: main
Active local workspace: /Users/poon/workspace/projects/codexbar-fork-ark
Legacy backup checkout: /Users/poon/Library/CloudStorage/GoogleDrive-zeronxpbee@gmail.com/我的云端硬盘/Codex/projects/codexbar-fork-ark

M5A is merged. PR #6 implemented the approved installation identity isolation
contract and is now part of main.

M5A PR: https://github.com/zeronxpbee-droid/codexbar-ark-usage-fork/pull/6
M5A merge commit: 86f4cec5967bc45340dae90479ef6d4e82d34fc1
Post-merge record commit: e7f4374712a9d1a1f84e83aaca50e71e274b121c

Current durable evidence index:
- Entry 095: latest package/signing/Widget evidence in the non-synced workspace.
- Entry 102: Codex Final Audit PASS for exact candidate a8a9a7a.
- Entry 103: Draft PR #6 opened.
- Entry 104: PR #6 merged.
- Entry 105: M5A->M5B documentation compaction / handoff cleanup.
- Entry 106: post-merge local package/static-use verification.
- Entry 107: M5B local-use isolation preflight matrix / implementation contract.

Next allowed work requires a Bee decision:
1. create/start the M5B implementation branch from `main`;
2. pause with M5A merged.
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
M5A merged PR: https://github.com/zeronxpbee-droid/codexbar-ark-usage-fork/pull/6
M5A merge commit: 86f4cec5967bc45340dae90479ef6d4e82d34fc1
```

## Mandatory Pre-Execution Rule

Before development, review, audit, documentation update, or debugging:

1. Invoke or explicitly compare the task against LOOP.
2. Verify `pwd` is `/Users/poon/workspace/projects/codexbar-fork-ark`.
3. Verify branch, HEAD, worktree/index, and remotes.
4. Read `AGENTS.md`, this file, and the current `docs/PROJECT_LOG.md` handoff
   entries listed below.
5. Inspect upstream baseline rules with:

```bash
git show 6ab1cbb7daee73b8ad531fbdd420e9aa6eb6d26b:AGENTS.md
```

Do not use the old Google Drive / CloudStorage checkout for development,
builds, package, signing, Widget verification, or audit evidence.

## Token-Efficient Reading Rule

For the next M5B or post-merge local-use loop, agents should normally read:

- `AGENTS.md`
- `docs/TASKS.md`
- `docs/CLAUDE_REVIEW_WORKFLOW.md`
- `docs/PROJECT_LOG.md` Entries 102, 103, 104, and 105
- Entry 095 only when package/signing/Widget evidence is needed
- `docs/PRD.md` only when product intent or non-goals are being re-evaluated

Do not reload M1-M4 history, Entry 099-101 failure detail, archives,
`docs/refactor/`, or `docs/superpowers/` by default. Read them only if the
current task depends on them or documents conflict.

## Review Pipeline

Bee approved the four-stage review workflow in PROJECT_LOG Entry 068:

1. Claude / GLM Developer implements the active task.
2. The same thread performs Developer Self-Check and fixes until
   `SELF-CHECK PASS`.
3. A new independent Claude / GLM thread performs read-only Pre-Audit.
4. Codex performs Final Audit and repository operations.

Any source or test change invalidates prior Self-Check and Pre-Audit results.
Reusable prompts and compact handoff contracts live in
`docs/CLAUDE_REVIEW_WORKFLOW.md`.

## M5A Compact Outcome

M5A's purpose was to make the Ark fork safe for local side-by-side
installation with official CodexBar and to prevent official updates from
overwriting or invalidating the fork.

Implemented M5A surfaces:

- S20: app/package/widget identity, with visible app name `CodexBar Ark.app`.
- S21: fixed fork App Group `group.com.zeronxpbee.codexbar-ark[.debug]`.
- S22: fork config directory `codexbar-ark`, no fallback to official config.
- S23: fork-owned CodexBar Keychain service names and migration/clear paths.
- S25: no official Sparkle feed/key and automatic update checks disabled.
- S26: ad-hoc local signing path; official signing/release defaults disabled.
- S27: fork CLI command `codexbar-ark`.
- S29: current operational docs synchronized for fork paths and commands.

Preserved M5A constraints:

- Internal Swift package/module/target/executable names stay unchanged.
- No official config/App Group/Keychain migration or credential copy.
- No Ark provider/API/menu/popover/snapshot schema/Widget UI change.
- No public release, notarization, Homebrew, upstream PR, or automatic update
  service was introduced.
- The identity set is atomic; partial rollback is not safe.

Known M5A post-merge verification outcome:

- Entry 106 packaged `CodexBar Ark.app` from `main` after M5A merge and
  verified bundle identity, ad-hoc code signing, App Group entitlements,
  Widget extension identity, disabled official Sparkle feed/key, CLI helper
  availability, fork config source, focused isolation tests, and static source
  isolation checks.
- GUI launch, menu proof, Widget runtime registration/read proof, CLI symlink
  installer mutation, real Ark credential usage, and Gatekeeper `spctl`
  assessment remain NOT RUN / inconclusive as recorded in Entry 106.

## M5B Goal

M5B is not required for the Ark feature itself. Its local-use goal is to make
the fork safer for long-term private use alongside official CodexBar, especially
when official CodexBar is updated or both apps are present on the same Mac.

M5B implementation focus:

- Application Support, history, account, cost-cache, runtime-cache, and log
  isolation that M5A deferred as S24.
- Launch/kill/script behavior that must not accidentally target official
  `CodexBar.app`.
- Side-by-side smoke evidence for official `CodexBar.app` plus
  `CodexBar Ark.app`, if Bee approves runtime verification.
- Minimal diagnostic naming isolation only where it affects local-use clarity or
  real collision risk.

## M5B Preflight Matrix

Entry 107 classified the remaining local-use collision surfaces:

| Surface | Classification | Implementation contract |
|---|---|---|
| `~/Library/Application Support/CodexBar` app-owned files | must isolate | Move app-owned support files to a fork root such as `~/Library/Application Support/CodexBarArk`, through a small shared path helper. Covers token accounts, managed Codex account index/homes, Codex account snapshots, legacy cookie-cache files, provider session caches, and provider probe working directories. |
| `~/Library/Application Support/com.steipete.codexbar` app-owned history/cache | must isolate | Move history/dashboard support data to a fork-owned reverse-DNS root such as `com.zeronxpbee.codexbar-ark`; do not copy official history. |
| `~/Library/Caches/CodexBar` token-cost/model-pricing caches | must isolate | Move app-owned cache roots to `~/Library/Caches/CodexBarArk` or the shared path helper equivalent; stale official caches must not be read as fork cache hits. |
| `~/Library/Logs/CodexBar/CodexBar.log` debug file log | must isolate | Move optional debug file logging to a fork log path such as `~/Library/Logs/CodexBarArk/CodexBarArk.log`. |
| `Scripts/compile_and_run.sh`, `Scripts/launch.sh`, `Makefile` process matching | must isolate | Remove broad `pkill -x CodexBar` / `pgrep -x CodexBar` behavior from fork launch flows. Match the packaged `CodexBar Ark.app` path and this repo's `.build/.../CodexBar` binaries only. |
| Unbundled localization fallback `UserDefaults(suiteName: "CodexBar")` | must isolate | Use a fork-only suite/domain for non-bundled runs; bundled app `UserDefaults.standard` is already bundle-ID isolated. |
| `UserDefaults.standard`, `@AppStorage` in the packaged app | acceptable shared/external state | No M5B change unless a call explicitly targets official domains. The fork bundle ID `com.zeronxpbee.codexbar-ark` already isolates packaged-app defaults. |
| App Group, Widget snapshot, config store, CodexBar-owned Keychain services | do not change | Already isolated by M5A S21-S23; M5B must not reintroduce official fallback or migration. |
| Provider-owned external homes and auth stores such as `~/.codex`, `~/.claude`, browser cookie stores, provider CLIs, and explicit `CODEX_HOME` usage | acceptable shared/external state | Do not fork or migrate provider-owned state by default. Only app-owned managed homes/caches move under the fork support root. |
| Internal Swift package/module/target/executable name `CodexBar` | do not change | M5A intentionally preserved internal names. Do not rename package targets or executable unless Bee explicitly re-approves a larger compatibility tradeoff. |
| osLog subsystem, SwiftLog labels, dispatch queue names, notifications, run-loop names | defer | Leave broad S28 diagnostic naming for later unless a concrete local-use collision or confusing runtime evidence appears during M5B validation. |
| About pane links, broad user-facing branding strings, public release/Homebrew/Sparkle publication paths | defer | Not required for local private side-by-side use. Handle in a later release/distribution or branding cleanup loop if Bee wants it. |

## M5B Explicit Non-Goals Unless Bee Re-Approves

- No Developer ID signing, notarization, Homebrew, public release, or Sparkle
  feed/update service.
- No upstream synchronization branch or upstream PR.
- No Ark API/provider/menu/popover/snapshot schema/Widget UI feature change.
- No broad refactor of upstream provider, Widget, or persistence architecture.
- No real credential migration, real Keychain read/delete, or secret-bearing
  fixture.
- No package/module/target/executable rename unless preflight proves it is
  strictly required and Bee explicitly approves.
- No migration, copy, delete, or import of official CodexBar app-owned support,
  cache, log, defaults, or history data. M5B uses a fresh fork state policy.
- No broad S28 diagnostic rename unless implementation evidence shows a real
  local-use collision.

## M5B Implementation Contract

Allowed source scope:

- Add a small fork-local path helper or equivalent constants for app-owned
  support/cache/log roots.
- Replace app-owned hard-coded `CodexBar` and `com.steipete.codexbar`
  filesystem roots in the M5B matrix.
- Update fork launch/dev scripts so they do not kill or validate official
  `CodexBar.app` by generic process name.
- Update focused tests and docs only where required by these changes.

Forbidden source scope:

- Ark provider/API/menu/popover/snapshot schema/Widget UI feature changes.
- Provider-owned external auth/home migration, including `~/.codex`,
  `~/.claude`, browser profiles, or provider CLI state.
- CodexBar-owned Keychain/App Group/config identity changes already completed
  in M5A.
- Public release, notarization, Sparkle feed, Homebrew, upstream sync, or
  upstream PR work.
- Broad package/module/target/executable rename.

Required verification for a Developer candidate:

- `git diff --check`.
- Focused path-isolation tests covering the new helper/default URLs.
- Focused script tests or shell/static checks proving launch/dev scripts no
  longer use generic `pkill -x CodexBar` / `pgrep -x CodexBar` to target both
  official and fork apps.
- Existing focused isolation tests touched by the implementation.
- `swift build` and `make check` if available in the environment; record
  unavailable commands as `NOT RUN`.
- Static search evidence that product code no longer writes fork app-owned
  support/cache/log/history files under official `CodexBar` or
  `com.steipete.codexbar` roots, excluding documentation, tests that assert
  legacy behavior, and provider-owned external state.

Optional Codex final validation, only if Bee approves runtime cost:

- Launch official `CodexBar.app` and packaged `CodexBar Ark.app` side by side.
- Verify the fork creates/uses fork-owned support/cache/log paths.
- Verify Widget snapshot/runtime behavior after M5B package.

## Next Task Options

Bee should choose exactly one next loop:

1. **Start M5B Implementation**
   - Codex creates or confirms the M5B task branch from current `main`.
   - Claude / GLM implements only the M5B Implementation Contract above.
   - Four-stage review workflow remains required.

2. **Pause**
   - Keep M5A merged and defer further local-use hardening.

## Planned Milestones

- M5B — Optional local-use simultaneous-run / storage-cache isolation.
- M6 — Optional upstream contribution review, only if Bee later wants it.
