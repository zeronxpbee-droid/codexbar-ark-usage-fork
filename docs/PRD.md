# PRD.md — CodexBar Ark Agent Plan Usage Monitor

> Product intent document. This file owns why the project exists, what the MVP must deliver, and what is intentionally out of scope.

## 1. Product Summary

This project forks CodexBar to add Volcengine Ark Agent Plan AFP usage monitoring.

The MVP must let Bee see Ark Agent Plan usage from macOS without manually opening the Volcengine console. The monitor should appear both in the CodexBar menu bar and in macOS desktop Widgets.

## 2. Background

Bee uses multiple AI coding agents and wants a low-friction way to see whether Volcengine Ark Agent Plan still has usable AFP quota before choosing a model/provider for the next task.

CodexBar already provides a macOS menu bar and Widget foundation for monitoring AI coding provider limits. The missing capability is Volcengine Ark Agent Plan support, especially AFP usage display in desktop Widgets.

## 3. Target User

Primary user:

- Bee, a macOS user coordinating several AI coding agents and provider plans.

Secondary future users:

- Other CodexBar users who subscribe to Volcengine Ark Agent Plan and want usage visibility in the menu bar and Widget.

## 4. Core User Problems

1. Bee cannot currently see Ark Agent Plan AFP usage inside CodexBar.
2. Bee wants desktop-level visibility, not only a menu bar popover.
3. Bee needs the monitor to be safe with credentials.
4. Bee needs the project to remain narrow enough for Claude / GLM to develop
   and Codex to audit without scope drift.

## 5. MVP Goal

Create a CodexBar fork that supports:

```text
Volcengine Ark Agent Plan AFP usage
        ↓
CodexBar menu bar display
        ↓
Popover details for quota windows
        ↓
macOS desktop Widget selection and display
```

The MVP is not a full Volcengine dashboard. It only monitors Agent Plan AFP quota relevant to AI coding workflow decisions.

## 6. Functional Requirements

### FR1 — Ark Agent Plan API Probe

The project must first verify that the Ark Agent Plan usage API can be called from local development using safe credentials.

Requirements:

- Read credentials from environment variables or secure local config.
- Never commit credentials.
- Print only redacted result structure.
- Confirm the actual response fields before provider implementation.

Expected fields to validate:

- Usage window name.
- Quota.
- Used amount.
- Remaining amount, if available or derivable.
- Reset time, if available.

### FR2 — Ark Provider in CodexBar

Add a new provider for Volcengine Ark Agent Plan.

The provider should:

- Fetch AFP usage from the validated API endpoint.
- Parse at least four usage windows if returned:
  - 5-hour / short window.
  - Daily.
  - Weekly.
  - Monthly.
- Normalize values into CodexBar's existing provider usage model where possible.
- Expose a concise status suitable for the menu bar.

### FR3 — Menu Bar Status

The menu bar must show a compact Ark status.

Recommended display priority:

1. Highest-risk active window if a window is near exhaustion.
2. Otherwise 5-hour usage window.
3. Fallback to daily usage if 5-hour data is unavailable.

Example display patterns:

```text
Ark 23%
Ark 22.5/100 AFP
Ark reset 02:14
```

Exact formatting should follow CodexBar conventions.

### FR4 — Popover Details

The provider popover should show AFP usage details.

Minimum display:

```text
5h      used / quota / remaining / reset
Daily   used / quota / remaining / reset
Weekly  used / quota / remaining / reset
Monthly used / quota / remaining / reset
```

The popover must handle:

- Unauthorized credentials.
- Network timeout.
- Empty response.
- Unknown reset time.
- Stale cached data.

### FR5 — Widget Snapshot Integration

Ark provider data must be written into the Widget-readable snapshot path used by CodexBar.

Requirements:

- The Widget must not call the Ark API directly unless upstream architecture already requires it.
- The Widget should read the app snapshot / shared container data.
- Widget data must include enough fields for small and medium display.

### FR6 — Widget Provider Picker Support

Ark must be selectable in the Widget configuration UI.

Requirements:

- Add the required provider choice / intent case for Ark.
- Ensure Ark appears with a clear label such as `Ark`, `Volcengine Ark`, or `Ark Agent Plan`.
- Do not remove existing provider choices.

### FR7 — Desktop Widget UI

Minimum Widget support:

- Small Widget:
  - Provider name.
  - Main usage percentage or used/quota.
  - Reset countdown or reset time when available.

- Medium Widget:
  - Provider name.
  - 5-hour, daily, weekly, monthly rows.
  - Used/quota or remaining/quota.
  - Reset time where space allows.

Large Widget is optional after MVP.

### FR8 — Tests and Build

Required evidence should include whichever checks are available in upstream CodexBar:

- Swift build or Xcode build command.
- Existing test suite where practical.
- Targeted parser tests for Ark response models.
- Widget preview or simulator/manual verification notes.

### FR9 — Upstream Compatibility and Maintainability

The fork must remain practical to update when official CodexBar releases change.

Requirements:

- Preserve official CodexBar Git history and record the upstream baseline commit.
- Keep Ark-specific implementation in new Ark-scoped files where upstream
  extension points permit.
- Restrict shared upstream file changes to the minimum registration and wiring
  needed for the provider and Widget.
- Maintain a documented list of shared integration points that may conflict
  during future upstream updates.
- Synchronize upstream releases in dedicated maintenance branches / PRs, never
  mixed into Ark feature PRs.
- Re-run affected provider, snapshot, Widget, build, and test checks after each
  upstream synchronization.
- Surface incompatibilities explicitly; do not conceal them through unrelated
  refactors or broad architecture changes.

## 7. Non-Goals

The MVP must not:

- Build a separate macOS app from scratch.
- Build a backend service.
- Monitor all Volcengine billing categories.
- Monitor non-Agent Plan model API billing unless separately approved.
- Add usage prediction, model recommendation, or automatic provider switching.
- Add push notifications.
- Add analytics or telemetry.
- Add browser-cookie scraping.
- Rewrite CodexBar's global provider architecture.
- Rewrite the whole Widget system.

## 8. UX Principles

- Always visible but low-noise.
- Show only decision-useful numbers.
- Prefer remaining quota / reset time over raw billing complexity.
- Clearly show when data is stale or unavailable.
- Never expose credentials or account-sensitive details in UI screenshots or logs.

## 9. Security Requirements

- AK/SK or API keys must be stored using secure mechanisms.
- Local probe may use environment variables only.
- No credentials in commits, screenshots, logs, markdown, or test fixtures.
- Error messages must not echo secret-bearing request headers.
- If a request fails, show safe diagnostic categories:
  - unauthorized.
  - network unavailable.
  - rate limited.
  - unsupported response.
  - unknown error.

## 10. Milestones

### M0 — Fork Bootstrap + API Probe Preparation

Goal:

- Prepare the fork safely.
- Confirm upstream structure.
- Prepare an API probe without integrating into the app yet.

Deliverable:

- Local probe plan or script.
- No committed secrets.
- Documented response structure or documented blocker.

### M1 — Ark Provider Menu Bar MVP

Goal:

- Add Ark provider to CodexBar menu bar.

Deliverable:

- Ark status appears in menu bar using real or safely mocked API data.
- Basic error states exist.

### M2 — Ark Popover Details

Goal:

- Display four AFP windows in popover.

Deliverable:

- 5h / daily / weekly / monthly usage rows.
- Safe handling for missing fields.

### M3 — Widget Snapshot Integration

Goal:

- Make Ark data available to Widget Extension through CodexBar's existing snapshot path.

Deliverable:

- Snapshot includes Ark provider data.
- Widget can read Ark data.

### M4 — Widget Provider Picker + Small/Medium UI

Goal:

- Make Ark selectable and visible as a desktop Widget.

Deliverable:

- Ark appears in Widget provider picker.
- Small Widget works.
- Medium Widget works.

### M5 — Tests, Packaging, and Release Candidate

Goal:

- Stabilize the fork for daily use.

Deliverable:

- Build passes.
- Targeted tests pass.
- README usage instructions are accurate.
- Bee can install and use the fork locally.

### M6 — Optional Upstream Contribution Review

Goal:

- Decide whether to propose a PR upstream.

Deliverable:

- Bee decision.
- Upstream PR only if Bee explicitly approves.

## 11. Acceptance Criteria

The MVP is accepted when:

- Bee can configure Ark credentials safely.
- CodexBar menu bar shows Ark usage.
- Popover shows the relevant AFP windows.
- macOS desktop Widget can select Ark.
- Small and medium Widgets show useful Ark usage data.
- Stale/error states are clear.
- The upstream baseline and Ark/shared-file boundary are documented.
- Ark-specific logic is isolated wherever upstream extension points permit.
- A repeatable, separately reviewed upstream-update procedure exists.
- No credentials are committed or exposed.
- Codex audit passes.
- Bee approves the result.

## 12. Reference Links

These links are for Developer/Auditor verification. Always re-check upstream docs during implementation because project structure may change.

- CodexBar upstream: https://github.com/steipete/CodexBar
- CodexBar provider guide: https://github.com/steipete/CodexBar/blob/main/docs/provider.md
- CodexBar widgets guide: https://github.com/steipete/CodexBar/blob/main/docs/widgets.md
- CodexBar website: https://codexbar.app/
- Volcengine docs home: https://www.volcengine.com/docs/
