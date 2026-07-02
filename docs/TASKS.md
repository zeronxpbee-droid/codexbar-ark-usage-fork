# TASKS.md — Current Task State

> This file owns the current active goal. No other file may maintain a competing active goal.

## Active Goal

```text
M0 — Fork Bootstrap + Ark Agent Plan API Probe Preparation
```

## Goal Status

```text
Status: M0 Live Probe PASS on volcengineapi.com — Default Host Fix + Source Comment Cleanup Required
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
M0 draft PR: https://github.com/zeronxpbee-droid/codexbar-ark-usage-fork/pull/1
```

## Mandatory Pre-Execution Rule

Before starting this task, the Claude / GLM Developer must invoke or explicitly
compare the work against the already-installed `LOOP` Skill.

Before reviewing this task, Codex must invoke or explicitly compare the review against the already-installed `LOOP` Skill.

If LOOP, `AGENTS.md`, `docs/PRD.md`, `docs/TASKS.md`, or `docs/PROJECT_LOG.md` conflict, stop and report documentation drift.

## M0 Objective

Prepare the CodexBar fork and validate the safest path for Volcengine Ark Agent Plan usage API integration.

M0 is not an app integration milestone. It exists to reduce uncertainty before modifying CodexBar provider or Widget code.

## Allowed Scope

Codex may:

- Create the GitHub fork and initialize this directory as the working fork while
  preserving official CodexBar history.
- Configure the user's fork as `origin` and official CodexBar as `upstream`.
- Record the upstream default branch and exact baseline commit.
- Create the M0 feature branch / worktree.
- Commit repository bootstrap and governance documentation.
- Push scoped branches and create draft PRs.

Claude / GLM may:

- Inspect upstream CodexBar structure.
- Confirm provider architecture files.
- Confirm Widget architecture files.
- Create or propose a minimal local API probe.
- Use environment variables for local API testing only:
  - `VOLCENGINE_ACCESS_KEY_ID`
  - `VOLCENGINE_SECRET_ACCESS_KEY`
  - Other Volcengine variables only if official docs require them.
- Produce a redacted response-shape report.
- Update documentation directly related to M0.

## Forbidden Scope

Codex must not:

- Implement product code or create the credentialed API probe.
- Rewrite Claude / GLM commits without Bee's explicit approval.
- Merge a PR without Bee's explicit approval.

Claude / GLM must not:

- Create, delete, rename, or push branches or worktrees.
- Add, remove, or modify Git remotes.
- Open, update, close, or merge Pull Requests.
- Replace upstream history with a detached copy or squashed import.
- Mix an upstream synchronization with Ark feature implementation.
- Modify CodexBar provider registry for Ark yet.
- Modify Widget provider picker yet.
- Modify Widget UI yet.
- Modify unrelated providers.
- Refactor CodexBar architecture.
- Commit AK/SK, API keys, cookies, screenshots with secrets, or plaintext config.
- Add a backend service.
- Add browser-cookie scraping.
- Publish or package a release.
- Submit an upstream PR.

## Next Task for Claude / GLM

0. Work only in the assigned `feature/m0-bootstrap-ark-probe` checkout and create
   local commits without pushing.

1. Read these files:

```text
AGENTS.md
README.md
docs/PRD.md
docs/TASKS.md
docs/PROJECT_LOG.md
```

2. Invoke or explicitly compare against the installed `LOOP` Skill.

3. Inspect upstream/fork structure and identify:

```text
- Upstream default branch and baseline commit.
- Provider descriptor location.
- Provider implementation location.
- Fetcher / parser pattern.
- Widget snapshot store location.
- Widget provider picker / intent location.
- Build/test commands.
```

4. Prepare an M0 report before app integration:

```text
- Fork remotes and upstream synchronization procedure.
- Ark-owned new files planned for M1-M4.
- Required shared upstream integration points planned for M1-M4.
- Conflict risk and rollback path for each shared integration point.
- Confirmed files to modify in M1-M4.
- Confirmed API endpoint/action/version/region assumptions.
- Credential strategy.
- Probe strategy.
- Expected sanitized output shape.
- Main blockers.
```

5. If Bee approves, run the local API probe using environment variables only.

## Definition of Done — M0

M0 is Done only when:

- LOOP was used or explicitly referenced before execution.
- The fork preserves official CodexBar Git history.
- `origin` and `upstream` remotes are configured and verified.
- The upstream default branch and exact baseline commit are recorded.
- Upstream provider architecture was inspected.
- Upstream Widget architecture was inspected.
- Planned changes are classified as Ark-owned files or required shared upstream
  integration points.
- The upstream synchronization, conflict review, and rollback procedure is
  documented.
- API probe plan is documented.
- If a probe was run, output is redacted and contains no secrets.
- No app provider integration was attempted.
- No Widget integration was attempted.
- `docs/PROJECT_LOG.md` has an M0 entry.
- Codex review is complete.
- Bee approves moving to M1.

## Planned Milestones After M0

### M1 — Ark Provider Menu Bar MVP

Allowed only after Bee updates this file.

Target:

- Add Ark provider.
- Fetch/parse AFP usage.
- Show compact Ark status in menu bar.

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

## Current Open Questions

These must be resolved during M0 or before the indicated integration milestone:

1. The action example uses `ark.cn-beijing.volces.com`, while the general
   control-plane documentation lists `ark.cn-beijing.volcengineapi.com`. Which
   host should the production client use?
2. What is the least-privilege IAM action/policy required for `GetAFPUsage`?
3. Which CodexBar usage model best fits quota windows with multiple reset periods?
4. Should the Widget default to 5-hour usage or highest-risk usage?

## Current Decision

Default MVP display strategy:

```text
Menu bar: highest-risk window, otherwise 5-hour window.
Small Widget: Ark AFP percentage + reset.
Medium Widget: 5h / daily / weekly / monthly summary.
```

This decision may be revised after M0 evidence.
