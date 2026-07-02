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
public enum ArkErrorResponse {
    /// Extract the standard error `Code` from a non-2xx response body.
    ///
    /// Returns `nil` when the body is not JSON, is not an object, or contains no
    /// recognizable error code. Only the code string is ever returned; no other
    /// field is read out of the parsed structure.
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

    /// Pull only the `Code` string out of an `Error` object, ignoring every
    /// other key (notably `Message`). Non-empty strings only.
    private static func code(fromErrorObject object: Any?) -> String? {
        guard let error = object as? [String: Any],
              let code = error["Code"] as? String
        else { return nil }
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
