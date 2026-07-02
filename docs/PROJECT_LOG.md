# PROJECT_LOG.md — Historical Truth

> This file records what happened, what changed, what passed or failed, and what decisions were made. It does not own the current active goal; `docs/TASKS.md` does.

## Entry 001 — Project Documentation Bootstrap

Date: 2026-07-02
Actor: Bee + ChatGPT
Type: Planning / Documentation
Status: Created

### Summary

Created the initial project documentation package for a CodexBar fork that adds Volcengine Ark Agent Plan AFP usage monitoring and macOS desktop Widget support.

### Documents Created

```text
AGENTS.md
docs/PRD.md
docs/TASKS.md
docs/PROJECT_LOG.md
README.md
```

### Key Decisions

1. Project will be a CodexBar fork, not a new macOS app from scratch.
2. GLM will act as Developer.
3. Codex will act as Auditor.
4. Bee and ChatGPT will jointly handle architecture and decision-making.
5. Every development and audit task must first invoke or explicitly compare against the already-installed `LOOP` Skill.
6. Active Goal starts at M0 only: Fork Bootstrap + Ark Agent Plan API Probe Preparation.
7. App integration and Widget integration are not allowed during M0.
8. Secrets must never be committed, logged, screenshotted, or written into markdown.

### Product Scope

MVP target:

```text
Ark Agent Plan AFP usage API
        ↓
CodexBar Ark provider
        ↓
Menu bar status
        ↓
Popover quota details
        ↓
Widget snapshot
        ↓
macOS desktop Widget picker and UI
```

### Explicit Non-Goals

- No backend service.
- No full Volcengine billing dashboard.
- No unrelated provider changes.
- No global CodexBar architecture rewrite.
- No analytics or telemetry.
- No upstream PR unless Bee approves later.

### Evidence / Rationale

Planning was based on the current requirement that CodexBar should monitor Volcengine Ark Agent Plan usage and show it in macOS desktop Widgets, while preserving prior project governance style:

- `TASKS.md` owns current active work.
- `PROJECT_LOG.md` owns historical truth.
- `AGENTS.md` owns invariant workflow and safety rules.
- `README.md` owns user-facing usage.
- `PRD.md` owns product intent.

### Next Action

GLM should start M0 only after reading all project docs and applying the `LOOP` Skill.

## Entry 002 — README Governance Correction and API Documentation Reconnaissance

Date: 2026-07-02
Actor: Codex
Type: Documentation / Research
Status: PASS

### Active Goal

M0 — Fork Bootstrap + Ark Agent Plan API Probe Preparation

### LOOP Result

Kept the loop read-only except for the requested documentation correction. The
research was limited to official API feasibility, authentication, request shape,
and response shape. No repository bootstrap, credential use, API probe, provider
integration, or Widget integration was attempted.

### Summary

Removed temporary progress and Current Active Goal information from `README.md`.
Confirmed that Volcengine documents an official `GetAFPUsage` OpenAPI for Agent
Plan personal subscriptions.

### Files Changed

```text
README.md
docs/TASKS.md
docs/PROJECT_LOG.md
```

### Evidence

- Official action: `GetAFPUsage`.
- API version: `2024-01-01`.
- Service and region: `ark` / `cn-beijing`.
- Request method and body: `POST` with `{}`.
- Authentication: HMAC-SHA256 using an Access Key ID and Secret Access Key.
- Response windows: `AFPFiveHour`, `AFPDaily`, `AFPWeekly`, and `AFPMonthly`.
- Each window contains `Quota`, `Used`, `SubscribeTime`, and `ResetTime`.
- Times are epoch millisecond timestamps.
- No credentials were read, written, logged, or used.
- No live API request was made.

Official references:

- https://www.volcengine.com/docs/82379/2479847
- https://www.volcengine.com/docs/82379/1298459
- https://www.volcengine.com/docs/6257/64983

### Issues / Risks

- The `GetAFPUsage` request example uses `ark.cn-beijing.volces.com`, while the
  general control-plane Base URL documentation lists
  `ark.cn-beijing.volcengineapi.com`. The correct production host must be
  confirmed through API Explorer or a controlled probe.
- The least-privilege IAM action/policy required for `GetAFPUsage` is not yet
  confirmed.
- Official Swift SDK support was not found. A future implementation may need a
  small Swift signer based on the official HMAC-SHA256 signing specification.

### Decision

The documented API is sufficient to continue M0 planning. Repository bootstrap
and a credentialed probe remain deferred until Bee explicitly starts M0.

### Next Action

When Bee starts M0, bootstrap this directory as the actual CodexBar fork while
preserving upstream history, record the upstream baseline commit, inspect the
upstream provider and Widget architecture, and prepare a controlled API probe.

## Entry 003 — Agent Plan Subscription Type Confirmed

Date: 2026-07-02
Actor: Bee + Codex
Type: Decision / Documentation
Status: PASS

### Active Goal

M0 — Fork Bootstrap + Ark Agent Plan API Probe Preparation

### LOOP Result

Recorded the product-owner clarification only. No repository bootstrap, API
probe, or implementation work was performed.

### Summary

Bee confirmed that the monitored subscription is an Agent Plan personal
subscription.

### Files Changed

```text
docs/TASKS.md
docs/PROJECT_LOG.md
```

### Evidence

Bee's direct confirmation on 2026-07-02.

### Decision

`GetAFPUsage` is the intended action. Enterprise/team seat actions are outside
the current scope unless the subscription type changes.

### Next Action

Resolve the documented host discrepancy and least-privilege IAM policy during
M0 before running the credentialed probe.

## Entry 004 — Upstream Compatibility Boundary Established

Date: 2026-07-02
Actor: Bee + Codex
Type: Decision / Documentation
Status: PASS

### Active Goal

M0 — Fork Bootstrap + Ark Agent Plan API Probe Preparation

### LOOP Result

Limited this loop to defining invariant compatibility rules, product acceptance
requirements, and M0 evidence. No repository bootstrap, upstream synchronization,
API probe, or implementation was performed.

### Summary

Bee required the fork to remain maintainable as official CodexBar evolves. The
project now treats minimal upstream diff, isolated Ark implementation, explicit
shared-file touchpoints, preserved Git history, and separately reviewed upstream
updates as mandatory boundaries.

### Files Changed

```text
AGENTS.md
docs/PRD.md
docs/TASKS.md
docs/PROJECT_LOG.md
```

### Evidence

- `AGENTS.md` now owns the invariant upstream-compatibility rules.
- `docs/PRD.md` now includes maintainability requirements and acceptance criteria.
- `docs/TASKS.md` now requires remotes, baseline commit, change classification,
  synchronization procedure, conflict review, and rollback evidence during M0.

### Issues / Risks

Future upstream updates cannot be guaranteed conflict-free. Provider registration,
Widget provider selection, snapshot schemas, generated intents, or shared UI
wiring may require changes to upstream-owned files. Those touchpoints must remain
small and explicitly documented.

### Decision

Ark-specific code should live in new files where upstream extension points allow.
Necessary shared-file edits are permitted only as minimal registration or wiring.
Upstream synchronization must use a dedicated maintenance branch / PR and must
never be auto-merged.

### Next Action

When M0 starts, preserve upstream history, configure `origin` and `upstream`,
record the baseline commit, and produce the initial Ark/shared-file boundary map
before feature implementation.

## Entry 005 — Developer Handoff and Auditor Boundary Confirmed

Date: 2026-07-02
Actor: Bee + Codex
Type: Decision / Documentation
Status: PASS

### Active Goal

M0 — Fork Bootstrap + Ark Agent Plan API Probe Preparation

### LOOP Result

Limited this loop to role ownership, handoff readiness, and audit boundaries. No
repository bootstrap, API probe, implementation, or feature-branch work was
performed.

### Summary

Bee assigned M0 and later development to Claude / GLM. Codex is restricted to
audit and acceptance review after the developer submits implementation notes and
evidence.

### Files Changed

```text
AGENTS.md
docs/PRD.md
docs/TASKS.md
docs/PROJECT_LOG.md
```

### Evidence

- `docs/TASKS.md` status is `Ready for Developer Start`.
- Claude / GLM owns implementation.
- Codex owns scope, security, upstream-diff, test-evidence, and acceptance review.
- Codex may update audit records but must not implement fixes or commit to the
  developer feature branch.

### Decision

The documentation pre-work is ready for developer handoff. M0 remains the only
allowed implementation goal. Claude / GLM must complete M0 and submit evidence
before Codex performs acceptance review.

### Next Action

Bee may hand the repository to Claude / GLM to start M0 from `docs/TASKS.md`.
Codex waits for the M0 implementation and evidence package before auditing.

## Entry 006 — Repository Operation Responsibility Assigned to Codex

Date: 2026-07-02
Actor: Bee + Codex
Type: Decision / Documentation
Status: PASS

### Active Goal

M0 — Fork Bootstrap + Ark Agent Plan API Probe Preparation

### LOOP Result

Separated repository administration from product implementation. Codex may
perform Git/GitHub operations and governance commits but may not implement the
Ark feature. Claude / GLM may implement and create local commits but may not
manage remotes, branches, worktrees, pushes, or PRs.

### Summary

Bee assigned GitHub Fork creation, local repository bootstrap, remotes,
worktrees, branches, pushes, and PR operations to Codex because Claude does not
have complete Git permissions. The public Fork, local checkout, remotes, M0
branch, governance commit, push, and draft PR were created successfully.

### Files Changed

```text
AGENTS.md
README.md
docs/TASKS.md
docs/PROJECT_LOG.md
```

### Evidence

- GitHub account identified as `zeronxpbee-droid`.
- Official upstream confirmed as `steipete/CodexBar`, default branch `main`.
- GitHub CLI device reauthorization completed successfully.
- Fork: `https://github.com/zeronxpbee-droid/codexbar-ark-usage-fork`.
- Fork visibility: public.
- `origin`: `https://github.com/zeronxpbee-droid/codexbar-ark-usage-fork.git`.
- `upstream`: `https://github.com/steipete/CodexBar.git`.
- Upstream push URL is disabled to prevent accidental pushes.
- Fork `main` and upstream `main` matched at
  `6ab1cbb7daee73b8ad531fbdd420e9aa6eb6d26b`.
- M0 branch: `feature/m0-bootstrap-ark-probe`.
- Governance commit: `4821e59a0f9bd7cb7d4d821750c735f72fbd8d92`.
- Draft PR: `https://github.com/zeronxpbee-droid/codexbar-ark-usage-fork/pull/1`.
- `git diff --cached --check` passed before the governance commit.

### Issues / Risks

GitHub requires a Fork of the public upstream repository to remain public.
Future upstream changes can still conflict with the documented shared
integration points and must be synchronized through dedicated maintenance PRs.

### Decision

Codex is the repository operator and independent auditor. Claude / GLM remains
the implementation owner and local commit author. The fork's `main` remains at
the upstream baseline; M0 work is isolated in its draft PR branch.

### Next Action

Claude / GLM may start M0 in the assigned checkout, create scoped local commits,
run the required checks, and hand the evidence back to Codex. Codex will inspect
and push those commits before auditing the completed M0 scope.

## Entry Template

Copy this template for future entries.

```text
## Entry XXX — <Title>

Date: YYYY-MM-DD
Actor: GLM / Codex / Bee / ChatGPT
Type: Development / Review / Decision / Documentation / Bugfix
Status: PASS / FAIL / BLOCKED / CREATED / MERGED

### Active Goal

<Goal from docs/TASKS.md>

### LOOP Result

<Brief summary of how LOOP was applied>

### Summary

<What happened>

### Files Changed

<Files changed or reviewed>

### Evidence

<Build/test/probe/review evidence>

### Issues / Risks

<What is still uncertain>

### Decision

<What was decided>

### Next Action

<Next allowed action>
```
