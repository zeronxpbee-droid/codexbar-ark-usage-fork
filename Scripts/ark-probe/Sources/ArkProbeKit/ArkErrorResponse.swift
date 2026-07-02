import Foundation

/// Safe extractor for the Volcengine standard OpenAPI error structure.
///
/// Volcengine error responses wrap failure details in an envelope shaped like:
///
///     {
///       "ResponseMetadata": {
///         "RequestId": "...",
///         "Error": { "Code": "SignatureDoesNotMatch", "Message": "..." }
///       }
///     }
///
/// Some services also emit a top-level `Error` object, so both shapes are
/// tolerated. This type intentionally extracts **only** the machine-readable
/// error `Code`. It never reads, stores, or exposes the human-readable
/// `Message`, `RequestId`, account/resource/tenant identifiers, or any other
/// envelope field (docs/PRD.md §9, AGENTS.md §6). If no code can be located, the
/// caller renders `errorCode: <unavailable>` rather than falling back to any raw
/// content.
///
/// Security note (Entry 012 Finding 1): the error `Code` is **server-controlled,
/// untrusted input**. A hostile or buggy server could return a value containing
/// newlines, control characters, whitespace, or an unbounded length — any of
/// which could break the single-line diagnostic contract or smuggle content into
/// the output. Therefore the extractor accepts a value ONLY if it matches a
/// bounded, single-line ASCII machine-code grammar:
///
///     [A-Za-z0-9][A-Za-z0-9._-]{0,127}
///
/// Anything that does not match (including a value that merely has surrounding
/// whitespace) yields `nil`, and the caller renders `errorCode: <unavailable>`.
/// This same validation is re-applied at the public rendering boundary so the
/// renderer is safe even if called directly with a hostile value.
public enum ArkErrorResponse {
    /// Maximum accepted length for a validated error code (grammar allows a
    /// leading char plus up to 127 trailing chars).
    public static let maxCodeLength = 128

    /// Extract the standard error `Code` from a non-2xx response body.
    ///
    /// Returns `nil` when the body is not JSON, is not an object, contains no
    /// recognizable error code, or the code fails the strict grammar. Only a
    /// validated code string is ever returned; no other field is read out of the
    /// parsed structure.
    public static func extractErrorCode(from data: Data) -> String? {
        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        // Preferred: ResponseMetadata.Error.Code
        if let metadata = root["ResponseMetadata"] as? [String: Any],
           let code = Self.code(fromErrorObject: metadata["Error"])
        {
            return code
        }

        // Tolerated fallback: a top-level Error object.
        if let code = Self.code(fromErrorObject: root["Error"]) {
            return code
        }

        return nil
    }

    /// Validate an arbitrary, untrusted string against the strict error-code
    /// grammar `[A-Za-z0-9][A-Za-z0-9._-]{0,127}`.
    ///
    /// Returns the string unchanged if — and only if — it fully matches the
    /// grammar; otherwise returns `nil`. The value is NOT trimmed, lowered, or
    /// otherwise normalized: a value that only conforms after trimming is
    /// rejected, because trailing/leading whitespace is itself a signal of an
    /// untrusted or malformed code. This is the single source of truth for code
    /// validity and is reused by the rendering boundary.
    public static func validatedCode(_ candidate: String) -> String? {
        let scalars = candidate.unicodeScalars
        // Bounded length: 1...128 scalars.
        guard scalars.count >= 1, scalars.count <= maxCodeLength else { return nil }

        for (index, scalar) in scalars.enumerated() {
            let value = scalar.value
            let isDigit = value >= 0x30 && value <= 0x39            // 0-9
            let isUpper = value >= 0x41 && value <= 0x5A            // A-Z
            let isLower = value >= 0x61 && value <= 0x7A            // a-z
            let isAlnum = isDigit || isUpper || isLower

            if index == 0 {
                // First character must be strictly alphanumeric.
                guard isAlnum else { return nil }
            } else {
                // Subsequent characters: alphanumeric or . _ -
                let isDot = value == 0x2E                           // .
                let isUnderscore = value == 0x5F                    // _
                let isHyphen = value == 0x2D                        // -
                guard isAlnum || isDot || isUnderscore || isHyphen else { return nil }
            }
        }
        return candidate
    }

    /// Pull only the `Code` string out of an `Error` object, ignoring every
    /// other key (notably `Message`). The value is treated as untrusted and must
    /// pass `validatedCode(_:)`; anything else yields `nil`.
    private static func code(fromErrorObject object: Any?) -> String? {
        guard let error = object as? [String: Any],
              let code = error["Code"] as? String
        else { return nil }
        return validatedCode(code)
    }
}
