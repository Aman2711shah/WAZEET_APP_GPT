#!/bin/bash

# Script to get SHA-1 and SHA-256 fingerprints for Android keystores
# This is needed to configure Google Sign-In in Firebase Console

echo "═══════════════════════════════════════════════════════════════"
echo "  Android SHA Fingerprints for Firebase Configuration"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to extract and display SHA fingerprints
extract_sha() {
    local keystore_path=$1
    local alias=$2
    local password=$3
    local keystore_type=$4

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}$keystore_type Keystore${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "Path: $keystore_path"
    echo "Alias: $alias"
    echo ""

    if [ ! -f "$keystore_path" ]; then
        echo -e "${RED}✗ Keystore not found at: $keystore_path${NC}"
        echo ""
        return 1
    fi

    # Get SHA-1
    echo -e "${YELLOW}SHA-1 Fingerprint:${NC}"
    keytool -list -v -alias "$alias" -keystore "$keystore_path" -storepass "$password" 2>/dev/null | \
        grep "SHA1:" | \
        sed 's/.*SHA1: //' | \
        tr -d ' ' || echo -e "${RED}Failed to extract SHA-1${NC}"

    echo ""

    # Get SHA-256
    echo -e "${YELLOW}SHA-256 Fingerprint:${NC}"
    keytool -list -v -alias "$alias" -keystore "$keystore_path" -storepass "$password" 2>/dev/null | \
        grep "SHA256:" | \
        sed 's/.*SHA256: //' | \
        tr -d ' ' || echo -e "${RED}Failed to extract SHA-256${NC}"

    echo ""
}

echo "📋 Extracting fingerprints..."
echo ""

# 1. Debug Keystore (for development/testing)
DEBUG_KEYSTORE="$HOME/.android/debug.keystore"
if [ -f "$DEBUG_KEYSTORE" ]; then
    extract_sha "$DEBUG_KEYSTORE" "androiddebugkey" "android" "DEBUG"
else
    echo -e "${RED}✗ Debug keystore not found at: $DEBUG_KEYSTORE${NC}"
    echo -e "${YELLOW}  Run 'flutter run' once to generate it automatically${NC}"
    echo ""
fi

# 2. Release Keystore (for production builds)
RELEASE_KEYSTORE="$(pwd)/android/key.jks"
KEY_PROPERTIES="$(pwd)/android/key.properties"

if [ -f "$KEY_PROPERTIES" ]; then
    # Read values from key.properties
    STORE_FILE=$(grep "^storeFile=" "$KEY_PROPERTIES" | cut -d'=' -f2 | xargs)
    KEY_ALIAS=$(grep "^keyAlias=" "$KEY_PROPERTIES" | cut -d'=' -f2 | xargs)
    STORE_PASSWORD=$(grep "^storePassword=" "$KEY_PROPERTIES" | cut -d'=' -f2 | xargs)

    # Resolve path
    if [[ "$STORE_FILE" != /* ]]; then
        STORE_FILE="$(pwd)/android/$STORE_FILE"
    fi

    extract_sha "$STORE_FILE" "$KEY_ALIAS" "$STORE_PASSWORD" "RELEASE"
elif [ -f "$RELEASE_KEYSTORE" ]; then
    echo -e "${YELLOW}⚠ Found key.jks but no key.properties file${NC}"
    echo -e "${YELLOW}  Please provide the keystore password and alias:${NC}"
    echo ""
    read -p "Enter key alias: " KEY_ALIAS
    read -sp "Enter keystore password: " STORE_PASSWORD
    echo ""
    extract_sha "$RELEASE_KEYSTORE" "$KEY_ALIAS" "$STORE_PASSWORD" "RELEASE"
else
    echo -e "${YELLOW}⚠ No release keystore found at: $RELEASE_KEYSTORE${NC}"
    echo ""
fi

# Instructions
echo "═══════════════════════════════════════════════════════════════"
echo -e "${GREEN}📝 Next Steps:${NC}"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "1. Copy the SHA-1 and SHA-256 fingerprints above"
echo ""
echo "2. Go to Firebase Console:"
echo "   https://console.firebase.google.com/"
echo ""
echo "3. Select your project: business-setup-application"
echo ""
echo "4. Go to: Project Settings > Your apps > Android app (com.wazeet.app)"
echo ""
echo "5. Scroll to 'SHA certificate fingerprints' section"
echo ""
echo "6. Click 'Add fingerprint' and paste:"
echo "   - DEBUG SHA-1 (for development)"
echo "   - DEBUG SHA-256 (for development)"
echo "   - RELEASE SHA-1 (for production)"
echo "   - RELEASE SHA-256 (for production)"
echo ""
echo "7. Click 'Save' at the bottom"
echo ""
echo "8. Download the NEW google-services.json file"
echo ""
echo "9. Replace: android/app/google-services.json"
echo ""
echo "10. Run: flutter clean && flutter pub get"
echo ""
echo "11. Rebuild and test: flutter run -v"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo -e "${GREEN}✓ Done! Make sure to test on both debug and release builds${NC}"
echo ""
