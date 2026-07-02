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

## Entry 007 — M0 Ark GetAFPUsage Probe Implemented (Isolated Package)

Date: 2026-07-02
Actor: Claude (Developer)
Type: Development
Status: IMPLEMENTED / UNVERIFIED

### Active Goal

M0 — Fork Bootstrap + Ark Agent Plan API Probe Preparation

### LOOP Result

Development Loop. Ran a LOOP self-check before starting (pre-dev confirmation
report → READY) and before delivery. Smallest useful loop: an isolated,
offline-testable local probe for `GetAFPUsage` signing + response shape, with
no app integration. Evidence = independent-reference signature vectors + static
checks now, `swift build`/`swift test` deferred to macOS. Scope kept to a
standalone package; no provider/widget/registry edits. Rollback = delete
`Scripts/ark-probe/` or revert this commit.

### Summary

Implemented the M0 probe as a fully standalone Swift Package at
`Scripts/ark-probe/`, per Bee's decision. It is not referenced by the root
`Package.swift` or `Sources/CodexBar*` and imports no CodexBar module; it reuses
only `swift-crypto`. Contents: `VolcengineArkSigner` (HMAC-SHA256, structurally
derived from `BedrockAWSSigner` but implementing the Volcengine signing spec),
`GetAFPUsage` response models + tolerant parser (top-level or nested `Result`),
a redacting report renderer, a dry-run-by-default CLI (env-var credentials only),
and offline unit tests. Also added `docs/M0_INTEGRATION_BOUNDARY.md` mapping the
Ark-owned files vs shared upstream integration points (S1–S7) for M1–M4 with
conflict risk, rollback, and the upstream-sync procedure.

### Files Changed

```text
Scripts/ark-probe/Package.swift
Scripts/ark-probe/README.md
Scripts/ark-probe/.gitignore
Scripts/ark-probe/Sources/ArkProbeKit/VolcengineArkSigner.swift
Scripts/ark-probe/Sources/ArkProbeKit/ArkAPIConfig.swift
Scripts/ark-probe/Sources/ArkProbeKit/GetAFPUsageResponse.swift
Scripts/ark-probe/Sources/ArkProbeKit/SanitizedUsageReport.swift
Scripts/ark-probe/Sources/ArkProbe/main.swift
Scripts/ark-probe/Tests/ArkProbeKitTests/VolcengineArkSignerTests.swift
Scripts/ark-probe/Tests/ArkProbeKitTests/GetAFPUsageParserTests.swift
Scripts/ark-probe/reference/volc_sign_reference.py
docs/M0_INTEGRATION_BOUNDARY.md
docs/PROJECT_LOG.md
```

### Evidence

- Signature test vectors were computed by an INDEPENDENT Python reference
  (`reference/volc_sign_reference.py`), not by the Swift implementation, then
  hardcoded into the Swift tests. Fixed inputs: date 2026-07-02T00:00:00Z,
  non-real AK/SK, region `cn-beijing`, service `ark`, host
  `ark.cn-beijing.volces.com`, query `Action=GetAFPUsage&Version=2024-01-01`,
  body `{}`. Reference outputs (stable across runs):
  - body_hash `44136fa355b3678a1146ad16f7e8649e94fb4fc21fe77e8310c060f61caaff8a`
  - signed_headers `content-type;host;x-content-sha256;x-date`
  - credential_scope `20260702/cn-beijing/ark/request`
  - signature `0b9d4a47c69fbb15135625cad9f6309b7e478bca238e816897505b9373186e96`
- `git diff --check` / `git diff --cached --check`: clean (no whitespace/conflict markers).
- Secret scan of new files: no real credentials; only env-var names, test names,
  and deliberately-fake fixture identifiers (which a test asserts are stripped).
- **NOT YET VERIFIED**: `swift build` and `swift test` were NOT run — this Linux
  workspace has no Swift toolchain and no root access. Compilation/test evidence
  must be produced on macOS/Codex.

### Commands for Codex to run (M0 evidence)

```bash
cd Scripts/ark-probe
swift build
swift test
```

### Issues / Risks

- Status is IMPLEMENTED / UNVERIFIED, NOT PASS. If macOS `swift build`/`swift test`
  fails, M0 does not pass; Claude fixes and re-commits.
- Signing spec assumptions (algorithm label `HMAC-SHA256`, scope terminator
  `request`, signing-key seed without `AWS4` prefix, `X-Date`/`X-Content-Sha256`)
  are documented inline but must be confirmed against the official Volcengine
  signing reference before M1. Open questions: production host (volces.com vs
  volcengineapi.com) and least-privilege IAM policy remain unresolved.

### Decision

M0 implementation is delivered as a local commit (no push, no PR). Real network
probe remains gated on Bee's explicit authorization.

### Next Action

Codex runs `swift build` / `swift test` on macOS, audits scope/security/upstream
boundary, and records a PASS/FAIL in this log. Bee authorizes the live probe if
desired.

## Entry 008 — M0 Ark Probe Audit

Date: 2026-07-02
Actor: Codex
Type: Review
Status: FAIL

### Active Goal

M0 — Fork Bootstrap + Ark Agent Plan API Probe Preparation

### LOOP Result

Reviewed only commit `40cd9f7871d8aa79c18e544a3c6035ae8ae1c648`
against the M0 boundary and upstream baseline. Required evidence was scope
isolation, secret safety, official signing-spec agreement, macOS build, runnable
offline tests, and redacted dry-run behavior. Rollback remains reverting the
single developer commit. No product code was modified by Codex.

### Summary

Scope isolation, macOS compilation, official signing-chain agreement, secret
safety, the independent Python vector, and the redacted no-network dry-run
passed. M0 acceptance fails because the submitted tests cannot run in the
available macOS Command Line Tools environment, and the optional session-token
path produces a header that is not included in the canonical signed headers.

### Files Reviewed

```text
Scripts/ark-probe/**
docs/M0_INTEGRATION_BOUNDARY.md
docs/PROJECT_LOG.md
```

### Evidence

- Reviewed commit:
  `40cd9f7871d8aa79c18e544a3c6035ae8ae1c648`.
- Diff scope: 13 files, all under `Scripts/ark-probe/` or M0 documentation; no
  root `Package.swift`, app Provider, Widget, or unrelated Provider changes.
- `git diff --check 877226f0..40cd9f78`: PASS.
- `swift build`: PASS on Apple Swift 6.3.1; resolved `swift-crypto` 3.15.1.
- Fake-credential default dry-run: PASS; no network request and no signature,
  credential, or identifier output.
- `python3 reference/volc_sign_reference.py`: PASS; outputs matched the committed
  body hash, signed headers, credential scope, canonical request, and signature.
- Official `volcengine/volc-openapi-demos` Python reference confirms the
  `HMAC-SHA256` label, raw-secret key chain, `/request` scope, `X-Date`,
  `X-Content-Sha256`, and core signed headers used by the probe.
- Secret scan found only environment-variable names and deliberately fake test
  credentials.
- `swift test`: FAIL before test execution with `no such module 'XCTest'`.
  The selected developer directory is Command Line Tools and no full Xcode /
  `xctest` is installed.

### Findings

1. **P1 — No runnable offline test evidence.** The submitted test target imports
   `XCTest`, which is unavailable in the reviewer environment. Provide a
   Command-Line-Tools-runnable deterministic self-test target or another
   dependency-free verification path; keep the XCTest suite if useful.
2. **P1 — Session token is not signed.** `Credentials` accepts a
   `sessionToken`, and the signer emits `X-Security-Token`, but the header is not
   included in canonical headers or `SignedHeaders`. The official reference
   requires it to be signed. Remove unsupported session-token handling for M0,
   or implement and test it correctly.
3. **P2 — Dependency resolution is not reproducible in the commit.**
   `swift build` generated an untracked `Scripts/ark-probe/Package.resolved`.
   Commit the resolved file or otherwise make the declared 3.15.1 dependency
   policy accurate and reproducible.

### Decision

FAIL. Do not push developer commit `40cd9f78`. The existing draft PR remains at
the last reviewed remote head until Claude / GLM submits a corrective local
commit and Codex re-runs the evidence.

### Next Action

Claude / GLM fixes the three findings in a new local commit without rewriting
history or pushing. Codex then re-runs build, deterministic self-tests, dry-run,
scope/security review, and records a new PASS/FAIL entry.

## Entry 009 — M0 Ark Probe Audit Fixes (Findings 1–3)

Date: 2026-07-02
Actor: Claude (Developer)
Type: Bugfix / Development
Status: IMPLEMENTED / UNVERIFIED

### Active Goal

M0 — Fork Bootstrap + Ark Agent Plan API Probe Preparation

### LOOP Result

Development Loop. Ran LOOP self-check before and after. Smallest useful loop:
address the three Codex findings from Entry 008 in a NEW local commit on top of
`e26932cd` (no amend/rebase/push). Evidence path was reworked so the reviewer's
Command-Line-Tools environment can verify without a test runner. Rollback =
revert this single commit (Ark logic stays isolated in `Scripts/ark-probe/`).

### Summary

Corrected the three Entry 008 findings:

1. **P1 — No runnable offline test evidence (fixed).** Added a dependency-free
   `ark-probe-selftest` executable target
   (`Sources/ArkProbeSelfTest/main.swift`) that reproduces the signer, parser,
   and sanitizer assertions using only the public API + Foundation, prints one
   line per check, and exits non-zero on any failure. It runs under plain
   Command Line Tools via `swift run ark-probe-selftest` — no XCTest/xctest
   required. The XCTest suite is retained for environments that have a runner.
2. **P1 — Session token not signed (fixed by removal).** Removed `sessionToken`
   from `Credentials` and stopped emitting the unsigned `X-Security-Token`
   header. M0 now accepts long-lived IAM AK/SK only; STS support is deferred
   until it can be folded into the canonical signed headers with its own vector.
   Documented inline and in the README.
3. **P2 — Non-reproducible dependency (fixed).** Pinned `swift-crypto` to
   `exact: "3.15.1"` in `Package.swift` and committed
   `Scripts/ark-probe/Package.resolved` (swift-crypto 3.15.1, swift-asn1 1.7.1).

### Files Changed

```text
Scripts/ark-probe/Package.swift
Scripts/ark-probe/Package.resolved            (new — committed)
Scripts/ark-probe/Sources/ArkProbeKit/VolcengineArkSigner.swift
Scripts/ark-probe/Sources/ArkProbeSelfTest/main.swift   (new)
Scripts/ark-probe/README.md
docs/PROJECT_LOG.md
```

### Evidence

- `python3 reference/volc_sign_reference.py` re-run: outputs unchanged and match
  the values asserted by both the self-test and the XCTest suite (body hash
  `44136fa3…`, signed headers `content-type;host;x-content-sha256;x-date`,
  scope `20260702/cn-beijing/ark/request`, signature `0b9d4a47…`).
- `git diff --cached --check`: clean.
- Isolation re-verified: staged files are only under `Scripts/ark-probe/` +
  `docs/PROJECT_LOG.md`; root `Package.swift` and `Sources/` untouched.
- Secret scan: only fake fixture AK (`AKTESTEXAMPLE…`) and env-var names.
- **NOT YET VERIFIED**: `swift build` / `swift run ark-probe-selftest` were NOT
  run here — this Linux workspace has no Swift toolchain. Compilation/self-test
  evidence must be produced on macOS/Codex.

### Commands for Codex to run (M0 evidence)

```bash
cd Scripts/ark-probe
swift build
swift run ark-probe-selftest   # exits non-zero on failure; no XCTest needed
# optional, if a full Xcode/xctest runner is present:
swift test
```

### Issues / Risks

- Status is IMPLEMENTED / UNVERIFIED, NOT PASS. If macOS `swift build` /
  `swift run ark-probe-selftest` fails, M0 does not pass; Claude fixes and
  re-commits.
- Signing spec assumptions and the two open questions (production host
  `volces.com` vs `volcengineapi.com`; least-privilege IAM policy) remain
  documented and unresolved, to be confirmed against the official Volcengine
  reference before M1.

### Decision

Corrective work delivered as a new local commit on top of `e26932cd` — no
amend, no rebase, no push, no PR. Real network probe remains gated on Bee.

### Next Action

Codex re-runs `swift build` + `swift run ark-probe-selftest` (and optionally
`swift test`) on macOS, re-audits scope/security/upstream boundary, and records
a new PASS/FAIL entry.

## Entry 010 — M0 Ark Probe Fix Re-Audit

Date: 2026-07-02
Actor: Codex
Type: Review
Status: PASS

### Active Goal

M0 — Fork Bootstrap + Ark Agent Plan API Probe Preparation

### LOOP Result

Re-reviewed corrective commit
`ffd977749f6b4514ed23a6c785a5958e0ae82898` against the three Entry 008
findings. Required evidence was a macOS build, dependency-free deterministic
self-test, fixed session-token behavior, reproducible dependency resolution,
scope isolation, secret safety, official-vector agreement, and redacted
no-network dry-run behavior. No product code was modified by Codex.

### Summary

All three Entry 008 findings are closed. The standalone package builds on the
reviewer macOS environment, its dependency-free self-test passes all checks,
session-token support was safely removed from M0, and dependency versions are
reproducibly pinned. The implementation remains isolated from the CodexBar app.

### Files Reviewed

```text
Scripts/ark-probe/Package.swift
Scripts/ark-probe/Package.resolved
Scripts/ark-probe/README.md
Scripts/ark-probe/Sources/ArkProbeKit/VolcengineArkSigner.swift
Scripts/ark-probe/Sources/ArkProbeSelfTest/main.swift
docs/PROJECT_LOG.md
```

### Evidence

- Corrective commit:
  `ffd977749f6b4514ed23a6c785a5958e0ae82898`.
- Commit ancestry is additive:
  `40cd9f78` → `e26932cd` → `ffd97774`; no amend, rebase, or history rewrite.
- `swift build`: PASS on Apple Swift 6.3.1.
- `swift run ark-probe-selftest`: PASS, 35/35 checks.
- `python3 reference/volc_sign_reference.py`: PASS; canonical request, body
  hash, scope, and signature match the Swift self-test vector.
- Fake-credential default dry-run: PASS; no network request and no credential,
  signature, request ID, or account identifier output.
- `swift-crypto` is pinned exactly to 3.15.1; committed `Package.resolved`
  resolves `swift-crypto` 3.15.1 and `swift-asn1` 1.7.1.
- Unsupported session-token input and unsigned `X-Security-Token` emission were
  removed.
- `git diff --check e26932cd..ffd97774`: PASS.
- Corrective diff is restricted to `Scripts/ark-probe/**` and
  `docs/PROJECT_LOG.md`; no root package, app Provider, Widget, or unrelated
  Provider changes.
- Secret review found only documented environment-variable names and
  deliberately fake test credentials.
- Empty stale Git lock files left by the developer environment were verified
  as unowned and removed before repository operations resumed.

### Issues / Risks

- Full `swift test` remains unavailable because this macOS environment has only
  Command Line Tools and no `XCTest` runner. The accepted portable evidence path
  is the dependency-free self-test, which exercises the same public signer,
  parser, and sanitizer behavior.
- No credentialed live network probe was run.
- Production host (`volces.com` vs `volcengineapi.com`) and least-privilege IAM
  policy remain unresolved.

### Decision

PASS for the M0 implementation and safe to push to the existing draft PR.
This does not authorize merge or entry into M1. M0 remains awaiting Bee's
decision on a credentialed live probe and Bee's milestone approval.

### Next Action

Codex pushes the reviewed branch and updates the draft PR evidence. Bee decides
whether to authorize a live probe using environment variables and whether M0
may proceed to milestone approval.

## Entry 011 — M0 Live Probe Result (Both Hosts 401) + Safe Error-Code Diagnostic

Date: 2026-07-02
Actor: Bee (live probe) + Claude (Developer)
Type: Development / Bugfix
Status: IMPLEMENTED / UNVERIFIED

### Active Goal

M0 — Fork Bootstrap + Ark Agent Plan API Probe Preparation

### LOOP Result

Debugging Loop on top of the M0 baseline (HEAD `6692d962`, Entry 010 PASS).
Pre-task GATHER re-read AGENTS.md, PRD.md, TASKS.md, PROJECT_LOG.md and
verified HEAD + Entry 010 on disk (an earlier in-context PROJECT_LOG copy was
stale; no real documentation drift exists). Smallest useful loop: given real
401/401 evidence from both official hosts, add a *safe error-code diagnostic* so
a future authorized probe surfaces a machine-readable cause without leaking
identifiers. Evidence = offline fictional-fixture tests + static checks now;
`swift build` / `swift run ark-probe-selftest` deferred to macOS. Rollback =
revert this commit; the signer, request params, and default host are untouched.

### Summary

Bee ran a real, Bee-authorized live probe. Both officially-documented hosts
returned HTTP 401, so the Base-URL question is NOT resolved by this evidence:

- `ark.cn-beijing.volces.com` → HTTP 401, response body 210 bytes.
- `ark.cn-beijing.volcengineapi.com` → HTTP 401, response body 302 bytes.

Because a 401 is returned by both hosts, the failure is an authentication /
authorization problem (signing spec, credential, or IAM policy), not obviously a
wrong Base URL. To diagnose safely without exposing sensitive material, added a
minimal "safe error-code parsing" path to the probe. A non-2xx response now
prints only: HTTP status code, response body byte count, and the machine-
readable Volcengine error `Code` (parsed preferentially from
`ResponseMetadata.Error.Code`, with a tolerated top-level `Error.Code`
fallback). If no code can be parsed, it prints `errorCode: <unavailable>`. The
raw body, error `Message`, `RequestId`, response headers, AK/SK, Authorization,
and any account/resource/tenant identifier are never printed.

The signing algorithm, request parameters, and default host were NOT changed.
The `--host` override is retained.

### Files Changed

```text
Scripts/ark-probe/Sources/ArkProbeKit/ArkErrorResponse.swift        (new)
Scripts/ark-probe/Sources/ArkProbeKit/SanitizedUsageReport.swift    (+renderErrorDiagnostic)
Scripts/ark-probe/Sources/ArkProbe/main.swift                       (non-2xx branch)
Scripts/ark-probe/Sources/ArkProbeSelfTest/main.swift               (+error diagnostic checks)
Scripts/ark-probe/Tests/ArkProbeKitTests/ArkErrorResponseTests.swift (new)
docs/PROJECT_LOG.md
docs/TASKS.md
```

### Evidence

- Live probe (run by Bee, not by this workspace): both hosts returned HTTP 401
  with 210-byte and 302-byte bodies respectively. No response content was
  written to the repo.
- `ArkErrorResponse.extractErrorCode` returns only the error `Code` string;
  offline tests assert it never returns `Message`/`RequestId`/canary strings.
- New tests (XCTest `ArkErrorResponseTests` + self-test block) use entirely
  fictional error envelopes containing deliberate canary strings
  (`FAKE-REQ-ID-DO-NOT-LEAK-0001`, a fake `Message` with `9F3A`) and assert the
  rendered diagnostic contains none of them, only `httpStatus`, `bodyBytes`, and
  `errorCode`.
- Extraction + collision logic cross-checked with an independent Python mimic:
  all 7 fixture cases produced the expected code/nil, and the rendered
  diagnostic collided with zero forbidden substrings.
- `git diff --cached --check`: clean.
- Isolation: staged diff is restricted to `Scripts/ark-probe/**` (+ these two
  docs); root `Package.swift`, `Sources/CodexBar*`, Widget, and other providers
  untouched. `VolcengineArkSigner.swift` and `ArkAPIConfig.swift` untouched.
- Secret scan: only fictional canary/env-var names; no real credentials.
- **NOT YET VERIFIED**: `swift build` / `swift run ark-probe-selftest` were NOT
  run — this Linux workspace has no Swift toolchain. Compilation/self-test
  evidence must be produced on macOS/Codex.

### Commands for Codex to run (M0 evidence)

```bash
cd Scripts/ark-probe
swift build
swift run ark-probe-selftest   # exits non-zero on failure; no XCTest needed
# optional, if a full Xcode/xctest runner is present:
swift test
```

### Issues / Risks

- Status is IMPLEMENTED / UNVERIFIED, NOT PASS. If macOS `swift build` /
  `swift run ark-probe-selftest` fails, this patch does not pass; Claude fixes
  and re-commits.
- The 401/401 result means the production host is still unresolved AND at least
  one of {signing spec assumption, credential validity, least-privilege IAM
  policy} is wrong. The next authorized live probe should capture the parsed
  `errorCode` (e.g. `SignatureDoesNotMatch` vs `AccessDenied` vs
  `InvalidCredential`) to disambiguate — but that requires Bee's authorization
  and is out of scope for this offline patch.
- No credentialed live network request was made from this workspace.

### Decision

Diagnostic enhancement delivered as a new local commit on top of `6692d962` —
no push, no PR, no history rewrite. Signer/params/default host unchanged. Real
network probe remains gated on Bee's explicit authorization.

### Next Action

Codex re-runs `swift build` + `swift run ark-probe-selftest` on macOS, audits
scope/security, and records a PASS/FAIL. If Bee authorizes another live probe,
capture the redacted `errorCode` from both hosts to disambiguate the 401 cause.

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
