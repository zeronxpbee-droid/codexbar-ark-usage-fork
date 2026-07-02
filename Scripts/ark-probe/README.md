# ark-probe — M0 Volcengine Ark `GetAFPUsage` probe

Standalone, isolated Swift Package for M0. It validates the request **signing**
and **response shape** for the Volcengine Ark Agent Plan `GetAFPUsage` OpenAPI
**before** any CodexBar provider/widget integration.

Status: **IMPLEMENTED / UNVERIFIED** — code is complete and statically checked,
but has not been compiled or tested in this environment (no Swift toolchain).
Compilation and test evidence must be produced on macOS/Codex (see below).

## Isolation guarantees

- Not referenced by the root `Package.swift` or `Sources/CodexBar*`.
- Imports no CodexBar module. Reuses only `swift-crypto` (same lib the app uses).
- Removing `Scripts/ark-probe/` fully removes the probe with zero app impact.

## Safety model

- Credentials are read **only** from environment variables:
  `VOLCENGINE_ACCESS_KEY_ID`, `VOLCENGINE_SECRET_ACCESS_KEY`.
- Default mode is **dry-run**: the request is signed and its *redacted shape* is
  printed; **no network call** is made.
- A live call requires the explicit `--live` flag **and** must be authorized by
  Bee (M0 rule). Live output is redacted — only window names + numeric quota
  fields; the raw envelope, request IDs, account identifiers, and the signature
  are never printed.
- Session tokens (STS `X-Security-Token`) are **not** supported in M0. The
  official spec requires that header to be part of the canonical signed headers;
  rather than emit an unsigned token header, the signer accepts long-lived IAM
  AK/SK only.

## Commands for Codex (produce M0 evidence on macOS)

The self-test target has **no test-framework dependency**, so it runs under
plain Command Line Tools (no full Xcode / `xctest` required):

```bash
cd Scripts/ark-probe
swift build
swift run ark-probe-selftest     # deterministic offline checks; exits non-zero on failure
```

`swift-crypto` is pinned `exact: "3.15.1"` and `Package.resolved` is committed,
so dependency resolution is reproducible.

If a full Xcode / `xctest` runner is available, the XCTest suite covers the same
assertions:

```bash
swift test
```

Optional dry-run (safe, no network; requires the two env vars to be set):

```bash
swift run ark-probe                 # dry-run, default host ark.cn-beijing.volces.com
swift run ark-probe --host ark.cn-beijing.volcengineapi.com
```

A live probe (Bee-authorized only):

```bash
swift run ark-probe --live
```

## Test vectors

Signature test vectors are produced by an **independent Python reference**
(`reference/volc_sign_reference.py`), not by the Swift signer under test, so the
tests cross-check against a second implementation. Re-run the reference with:

```bash
python3 reference/volc_sign_reference.py
```

## Open questions carried from M0

1. Production host: `ark.cn-beijing.volces.com` vs `ark.cn-beijing.volcengineapi.com`.
2. Least-privilege IAM policy for `GetAFPUsage`.
3. The signing spec assumptions (algorithm label, scope terminator `request`,
   signing-key seed without `AWS4` prefix, `X-Date`/`X-Content-Sha256` headers)
   are documented inline in `VolcengineArkSigner.swift` and must be confirmed
   against the official Volcengine signing reference before M1.
