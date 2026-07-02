# AGENTS.md — CodexBar Ark Usage Fork

> Project rulebook for all agents. This file owns invariant workflow, architecture boundaries, role responsibilities, and forbidden scope.

## 0. Project Identity

- Project name: `codexbar-ark-usage-fork`.
- Upstream basis: CodexBar fork.
- Product goal: add Volcengine Ark Agent Plan AFP usage monitoring to CodexBar, including macOS menu bar and desktop Widget display.
- Primary user: Bee.
- Current collaboration model:
  - Bee: product owner and final decision maker.
  - ChatGPT: architecture / decision co-pilot.
  - Claude / GLM: developer agents and local commit authors.
  - Codex: repository operator, auditor, and acceptance reviewer.

## 1. Mandatory LOOP Skill Rule

Before any development, audit, refactor, documentation update, or debugging task, every agent must first invoke or explicitly compare the task against the already-installed `LOOP` Skill.

Before development or review, agents must also inspect the upstream rules at the
recorded baseline with:

```bash
git show <upstream-baseline-commit>:AGENTS.md
```

Those upstream rules remain applicable to upstream-owned code unless they
conflict with this fork-specific `AGENTS.md`, in which case this file takes
priority and the conflict must be reported.

The agent must use `LOOP` to check:

- What is the current goal?
- What is the smallest useful next loop?
- What evidence is needed before coding?
- What is allowed scope?
- What must not be changed?
- What is the rollback path?
- What needs to be logged after the loop?

The agent must state the LOOP result briefly before executing the task. If the LOOP result conflicts with `TASKS.md`, `PROJECT_LOG.md`, or this `AGENTS.md`, the agent must stop and report documentation drift instead of coding.

## 2. Single Progress Source Rule

- `docs/TASKS.md` owns current task structure:
  - Active Goal.
  - Allowed scope.
  - Next task.
  - Definition of Done.

- `docs/PROJECT_LOG.md` owns historical truth:
  - What happened.
  - What changed.
  - What passed / failed.
  - Review result.
  - Decision changes.

- `AGENTS.md` owns invariant rules:
  - Agent workflow.
  - Architecture boundaries.
  - Forbidden scope.
  - Safety rules.

- `README.md` owns user-facing usage:
  - Project purpose.
  - Setup.
  - Run commands.
  - Current released capability.

- `docs/PRD.md` owns product intent:
  - MVP goal.
  - User value.
  - Functional requirements.
  - Non-goals.

No other file may maintain a competing Current Active Goal. If any document conflicts with `docs/TASKS.md` + `docs/PROJECT_LOG.md`, Developer or Auditor must stop and report documentation drift before coding.

## 3. Role Responsibilities

### 3.1 Bee — Product Owner

Bee decides:

- Whether to fork upstream.
- Whether to enter the next milestone.
- Whether a reviewed PR may merge.
- Which usage windows matter most for daily use.
- Whether the fork remains private or later contributes upstream.

### 3.2 ChatGPT — Architecture / Decision Co-pilot

ChatGPT helps with:

- Stage planning.
- Scope control.
- Risk evaluation.
- Review criteria.
- Documentation governance.

ChatGPT does not directly modify the repository unless Bee explicitly asks for artifact preparation or text generation.

### 3.3 Claude / GLM — Developer Agents

Claude / GLM may:

- Implement the active task in `docs/TASKS.md`.
- Work only in the branch / worktree assigned by Codex.
- Create local commits for the active task.
- Add tests and documentation required by the active task.
- Produce implementation notes for Codex review.

Claude / GLM must not:

- Change scope without Bee approval.
- Refactor unrelated CodexBar architecture.
- Modify other providers unless the active task explicitly allows it.
- Commit secrets, tokens, AK/SK, cookies, screenshots containing credentials, or local config.
- Create, delete, rename, or push branches or worktrees.
- Add, remove, or modify Git remotes.
- Open, update, close, or merge Pull Requests.
- Merge its own PR.

### 3.4 Codex — Repository Operator and Auditor

Codex must:

- Create and maintain the GitHub fork and local repository bootstrap.
- Configure and verify `origin` and `upstream`.
- Create and manage task branches and worktrees requested by Bee.
- Inspect scope before pushing Claude / GLM commits.
- Push approved task branches and create or update draft PRs.
- Record branch names, commit SHAs, PR links, and upstream baselines.
- Re-read `AGENTS.md`, `docs/PRD.md`, `docs/TASKS.md`, and `docs/PROJECT_LOG.md` before reviewing.
- Invoke or explicitly compare the review task against `LOOP` before auditing.
- Review only the active goal scope.
- Check security, credential handling, Widget behavior, provider behavior, and test evidence.
- Check the complete diff against the recorded upstream baseline.
- Produce an evidence-backed PASS / FAIL acceptance recommendation.
- Write the review record to `docs/PROJECT_LOG.md` before any merge recommendation.

Codex must not:

- Implement product code, create the API probe, or fix developer findings.
- Amend, squash, rebase, or otherwise rewrite developer commits without Bee's
  explicit approval.
- Commit product implementation to the developer's feature branch.
- Modify files other than repository bootstrap material, audit records, or
  explicitly requested governance documentation.
- Merge without Bee approval.
- Convert review into unapproved development.
- Broaden the project into a general provider dashboard.

## 4. Architecture Boundary

This project is a narrow CodexBar fork. The desired chain is:

```text
Volcengine Ark Agent Plan API
        ↓
Ark provider fetcher / parser
        ↓
CodexBar provider usage model
        ↓
Menu bar status + popover details
        ↓
Widget snapshot store
        ↓
Widget provider picker
        ↓
macOS desktop Widget UI
```

All work should preserve CodexBar's existing provider and Widget architecture whenever possible.

### 4.1 Upstream Compatibility Boundary

The fork must remain maintainable against future CodexBar releases. Zero-conflict
upstream updates cannot be guaranteed, but every implementation decision must
minimize and expose the conflict surface.

Required rules:

- Preserve upstream Git history.
- Configure the user's fork as `origin` and official CodexBar as `upstream`.
- Record the exact upstream baseline commit before feature development.
- Prefer new Ark-scoped files and existing extension points.
- Limit edits to upstream-owned shared files to the smallest registration,
  routing, snapshot, intent, or UI wiring changes required for Ark.
- Keep provider-specific parsing, networking, models, tests, and presentation
  logic outside shared provider code whenever the upstream architecture permits.
- Do not rename, move, reformat, or refactor unrelated upstream files.
- Do not copy or fork shared upstream infrastructure into Ark-specific
  replacements merely to avoid understanding the extension point.
- Do not depend on private implementation details when an upstream public or
  internal extension pattern already exists.
- Classify every changed file as either:
  - Ark-owned new file.
  - Required shared upstream integration point.
- Document every required shared integration point and its reason in the PR.
- Review the complete diff against the recorded upstream baseline before each
  milestone is accepted.

Upstream update procedure:

1. Fetch official upstream changes without modifying the active feature branch.
2. Review upstream release notes and diffs affecting provider or Widget
   extension points.
3. Integrate the upstream update in a dedicated maintenance branch / PR.
4. Re-run the relevant build, parser, provider, snapshot, and Widget checks.
5. Report conflicts and behavior changes explicitly.
6. Do not auto-merge the upstream update.

## 5. Hard Forbidden Scope

Unless Bee explicitly changes `docs/TASKS.md`, agents must not:

- Rewrite CodexBar's provider registry architecture.
- Rewrite WidgetKit architecture globally.
- Change unrelated provider behavior.
- Add analytics, telemetry, account tracking, or network calls beyond the active provider.
- Store secrets in source files, markdown logs, test fixtures, screenshots, or unencrypted local files.
- Require browser cookies as the primary credential path.
- Create a new standalone app when the current goal is a CodexBar fork.
- Add a backend service unless explicitly approved.
- Replace upstream Git history with a detached source copy or squashed import.
- Mix upstream synchronization with an Ark feature milestone PR.
- Auto-submit upstream PRs.
- Auto-publish releases.

## 6. Credential and Security Rules

Allowed credential sources, in priority order:

1. Existing CodexBar credential/config mechanism, if appropriate.
2. macOS Keychain.
3. Environment variables for local probe only.

Forbidden:

- Hard-coded AK/SK.
- Plaintext committed config.
- Printing full credentials in logs.
- Persisting API responses that expose account identifiers unless redacted.

The local probe may output only redacted result structure and numeric quota fields required for implementation.

## 7. Milestone Gate Rules

Each milestone requires:

- Updated `docs/TASKS.md` Active Goal.
- Claude / GLM implementation notes.
- Test/build evidence.
- Codex audit record in `docs/PROJECT_LOG.md`.
- Bee approval before merge or next milestone.

No milestone is considered complete merely because the app runs locally.

## 8. Branch and PR Rules

Recommended branch format:

```text
feature/m0-bootstrap-ark-probe
feature/m1-ark-provider-menu-bar
feature/m2-ark-popover-details
feature/m3-ark-widget-snapshot
feature/m4-ark-widget-picker-ui
```

Rules:

- Codex creates and manages repository remotes, branches, worktrees, pushes, and
  PRs.
- Claude / GLM writes product changes and creates local commits only.
- One active goal per branch.
- One branch per PR.
- No mixed provider changes.
- No unrelated formatting churn.
- PR description must include:
  - Active Goal.
  - Files changed.
  - Test commands.
  - Screenshots only if no secrets are visible.
  - Known limitations.
  - Rollback path.

## 9. Review Checklist

Codex must verify:

- LOOP Skill was used or explicitly referenced before execution.
- Work matches `docs/TASKS.md` Active Goal.
- No unrelated providers were modified.
- No secrets were committed.
- API errors are handled safely.
- Network timeout / auth failure / empty quota response have safe UI states.
- Widget displays stale or unavailable data clearly.
- Menu bar and Widget do not disagree on the same snapshot.
- Ark logic is isolated where upstream extension points permit.
- Shared upstream integration edits are minimal, documented, and justified.
- The reviewed diff is compared against the recorded upstream baseline.
- Tests/build commands were run or failures were honestly reported.
- `docs/PROJECT_LOG.md` was updated before PASS / FAIL.

## 10. Definition of Done Policy

A task is Done only when:

- The active scope is implemented.
- Required tests/build checks pass, or failures are documented with cause.
- The user-facing behavior is verified.
- Security rules are satisfied.
- `docs/PROJECT_LOG.md` records what changed and what evidence exists.
- Codex review is complete.
- Bee approves moving forward.
