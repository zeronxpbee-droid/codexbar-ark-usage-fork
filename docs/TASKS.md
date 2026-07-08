# TASKS.md — Current Task State

> This file owns the current active goal. No other file may maintain a competing active goal.

## Active Goal

```text
Post-M5A — M5B Local-Use Isolation Preparation
```

## Goal Status

```text
Status: M5A->M5B DOCUMENTATION COMPACTION COMPLETE — awaiting Bee decision
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

Next allowed work requires a Bee decision:
1. post-merge local package/use verification;
2. M5B local-use isolation preflight;
3. pause with M5A merged.
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

Known M5A post-merge limitation:

- No post-merge package/use verification has been run after merge commit
  `86f4cec5967bc45340dae90479ef6d4e82d34fc1`.

## M5B Candidate Goal

M5B is not required for the Ark feature itself. Its local-use goal is to make
the fork safer for long-term private use alongside official CodexBar, especially
when official CodexBar is updated or both apps are present on the same Mac.

Candidate M5B focus:

- Application Support, history, account, cost-cache, runtime-cache, and log
  isolation that M5A deferred as S24.
- Launch/kill/script behavior that must not accidentally target official
  `CodexBar.app`.
- Side-by-side smoke evidence for official `CodexBar.app` plus
  `CodexBar Ark.app`, if Bee approves runtime verification.
- Minimal diagnostic naming isolation only where it affects local-use clarity
  or collision risk; broad S28 osLog/queue/notification/run-loop renaming can
  remain deferred unless preflight proves it is needed.

M5B should start with a preflight matrix before implementation. The matrix
should classify each remaining collision surface as:

- must isolate for local private use;
- acceptable shared/external provider-owned state;
- defer to later release/distribution work;
- do not change.

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

## Next Task Options

Bee should choose exactly one next loop:

1. **Post-merge local package/use verification**
   - Build/package from `main`.
   - Verify `CodexBar Ark.app`, `codexbar-ark`, fork config path, fork App
     Group, fork Keychain services, disabled official Sparkle feed, and Widget
     snapshot behavior.
   - Do not start M5B implementation.

2. **M5B Local-Use Isolation Preflight**
   - Produce the collision surface matrix and smallest useful implementation
     contract.
   - No source changes except governance docs.
   - No runtime automation unless Bee approves the token cost.

3. **Pause**
   - Keep M5A merged and defer further local-use hardening.

## Planned Milestones

- M5B — Optional local-use simultaneous-run / storage-cache isolation.
- M6 — Optional upstream contribution review, only if Bee later wants it.
