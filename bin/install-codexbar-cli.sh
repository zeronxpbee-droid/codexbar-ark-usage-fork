#!/usr/bin/env bash
set -euo pipefail

# M5A S27: fork CLI command is codexbar-ark to avoid replacing official codexbar.
APP="/Applications/CodexBar Ark.app"
HELPER="$APP/Contents/Helpers/CodexBarCLI"
TARGETS=("/usr/local/bin/codexbar-ark" "/opt/homebrew/bin/codexbar-ark")

if [[ ! -x "$HELPER" ]]; then
  echo "CodexBarCLI helper not found at $HELPER. Please reinstall CodexBar Ark." >&2
  exit 1
fi

osascript - "$HELPER" <<'APPLESCRIPT'
on run argv
  set helperPath to item 1 of argv
  set installCommand to "set -euo pipefail" & linefeed & ¬
    "HELPER=" & quoted form of helperPath & linefeed & ¬
    "TARGETS=(\"/usr/local/bin/codexbar-ark\" \"/opt/homebrew/bin/codexbar-ark\")" & linefeed & ¬
    "for t in \"${TARGETS[@]}\"; do" & linefeed & ¬
    "  mkdir -p \"$(dirname \"$t\")\"" & linefeed & ¬
    "  ln -sf \"$HELPER\" \"$t\"" & linefeed & ¬
    "  echo \"Linked $t -> $HELPER\"" & linefeed & ¬
    "done"

  do shell script "bash -c " & quoted form of installCommand with administrator privileges
end run
APPLESCRIPT

echo "CodexBar Ark CLI installed. Try: codexbar-ark usage"
