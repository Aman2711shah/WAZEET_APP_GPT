#!/bin/zsh
set -euo pipefail

PBXPROJ="$(dirname "$0")/../ios/Runner.xcodeproj/project.pbxproj"

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <APPLE_TEAM_ID>" >&2
  exit 1
fi

TEAM_ID="$1"

if [[ ! -f "$PBXPROJ" ]]; then
  echo "Error: project.pbxproj not found at $PBXPROJ" >&2
  exit 1
fi

echo "Setting DEVELOPMENT_TEAM to $TEAM_ID and enabling Automatic code signing for Runner target…"

# Ensure we only insert if not already present
if ! grep -q "DEVELOPMENT_TEAM" "$PBXPROJ"; then
  # Insert DEVELOPMENT_TEAM next to PRODUCT_BUNDLE_IDENTIFIER entries for Runner target configs
  # This adds entries in Debug/Release/Profile target build settings blocks for Runner.
  /usr/bin/sed -i '' \
    -e "s/\(PRODUCT_BUNDLE_IDENTIFIER = com\\.wazeet\\.wazeet;\)/\1\n\t\t\t\tDEVELOPMENT_TEAM = ${TEAM_ID};/" \
    "$PBXPROJ"
fi

# Ensure CODE_SIGN_STYLE is Automatic in Runner target build settings
if ! grep -q "CODE_SIGN_STYLE = Automatic;" "$PBXPROJ"; then
  /usr/bin/sed -i '' \
    -e "s/\(PRODUCT_BUNDLE_IDENTIFIER = com\\.wazeet\\.wazeet;\)/\1\n\t\t\t\tCODE_SIGN_STYLE = Automatic;/" \
    "$PBXPROJ"
fi

echo "Done. You can now try: flutter build ipa --release --export-method app-store"
