#!/usr/bin/env python3
"""Independent reference calculation for VolcengineArkSigner test vectors.

This is deliberately a SEPARATE implementation (Python + hashlib/hmac) so the
Swift signer's unit-test vectors are NOT self-generated. Run this to (re)produce
the expected canonical request / body hash / credential scope / signature that
are hardcoded into ArkProbeKitTests.

Spec assumptions mirror VolcengineArkSigner.swift and must be verified against
the official Volcengine signing reference:
  - algorithm label: HMAC-SHA256
  - credential scope terminator: "request"
  - signing key seed: raw secret (no "AWS4" prefix)
  - date header X-Date = yyyyMMddTHHmmssZ (UTC); payload header X-Content-Sha256
"""
import hashlib
import hmac

ALGORITHM = "HMAC-SHA256"
SCOPE_TERMINATOR = "request"


def sha256_hex(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def hmac_sha256(key: bytes, data: bytes) -> bytes:
    return hmac.new(key, data, hashlib.sha256).digest()


def uri_encode(s: str) -> str:
    allowed = set(
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
    )
    out = []
    for ch in s:
        if ch in allowed:
            out.append(ch)
        else:
            out.append("".join("%%%02X" % b for b in ch.encode("utf-8")))
    return "".join(out)


def uri_encode_path(path: str) -> str:
    return "/".join(uri_encode(seg) for seg in path.split("/"))


def canonical_query(query):
    if not query:
        return ""
    parts = ["%s=%s" % (uri_encode(k), uri_encode(v)) for k, v in query]
    return "&".join(sorted(parts))


def sign(method, host, path, query, content_type, body, ak, sk, region, service,
         x_date, short_date):
    body_hash = sha256_hex(body)
    headers = [
        ("content-type", content_type),
        ("host", host),
        ("x-content-sha256", body_hash),
        ("x-date", x_date),
    ]
    headers.sort(key=lambda kv: kv[0])
    signed_headers = ";".join(k for k, _ in headers)
    canonical_headers = "\n".join("%s:%s" % (k, v) for k, v in headers)

    canonical_request = "\n".join([
        method.upper(),
        uri_encode_path(path if path else "/"),
        canonical_query(query),
        canonical_headers + "\n",
        signed_headers,
        body_hash,
    ])

    credential_scope = "%s/%s/%s/%s" % (short_date, region, service, SCOPE_TERMINATOR)
    string_to_sign = "\n".join([
        ALGORITHM,
        x_date,
        credential_scope,
        sha256_hex(canonical_request.encode("utf-8")),
    ])

    k_date = hmac_sha256(sk.encode("utf-8"), short_date.encode("utf-8"))
    k_region = hmac_sha256(k_date, region.encode("utf-8"))
    k_service = hmac_sha256(k_region, service.encode("utf-8"))
    k_signing = hmac_sha256(k_service, SCOPE_TERMINATOR.encode("utf-8"))
    signature = hmac_sha256(k_signing, string_to_sign.encode("utf-8")).hex()

    return {
        "body_hash": body_hash,
        "signed_headers": signed_headers,
        "canonical_request": canonical_request,
        "credential_scope": credential_scope,
        "string_to_sign": string_to_sign,
        "signature": signature,
    }


if __name__ == "__main__":
    # Fixed, non-real test inputs.
    result = sign(
        method="POST",
        host="ark.cn-beijing.volces.com",
        path="/",
        query=[("Action", "GetAFPUsage"), ("Version", "2024-01-01")],
        content_type="application/json",
        body=b"{}",
        ak="AKTESTEXAMPLE000000000",   # non-real
        sk="TESTSECRET0000000000000000000000",  # non-real
        region="cn-beijing",
        service="ark",
        x_date="20260702T000000Z",
        short_date="20260702",
    )
    for key in ("body_hash", "signed_headers", "credential_scope", "signature"):
        print("%s: %s" % (key, result[key]))
    print("--- canonical_request ---")
    print(result["canonical_request"])
    print("--- string_to_sign ---")
    print(result["string_to_sign"])
