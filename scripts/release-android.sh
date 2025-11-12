#!/bin/bash
# Android Release Build Script for WAZEET App
# Version: 1.0
# Usage: ./scripts/release-android.sh

set -e  # Exit on error

echo "🚀 WAZEET Android Release Build"
echo "================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if keystore exists
if [ ! -f "android/key.jks" ]; then
    echo -e "${RED}❌ Error: Keystore not found at android/key.jks${NC}"
    echo "Please generate keystore first or ensure it's in the correct location."
    exit 1
fi

# Check if key.properties exists
if [ ! -f "android/key.properties" ]; then
    echo -e "${RED}❌ Error: key.properties not found at android/key.properties${NC}"
    echo "Please create key.properties with keystore configuration."
    exit 1
fi

echo "🧹 Step 1: Cleaning previous builds..."
flutter clean
rm -rf build/

echo ""
echo "📦 Step 2: Getting dependencies..."
flutter pub get

echo ""
echo "🔍 Step 3: Running code analyzer..."
if flutter analyze; then
    echo -e "${GREEN}✅ Code analysis passed${NC}"
else
    echo -e "${YELLOW}⚠️  Code analysis found issues. Continue? (y/n)${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Build cancelled."
        exit 1
    fi
fi

echo ""
echo "🧪 Step 4: Running tests..."
if flutter test; then
    echo -e "${GREEN}✅ All tests passed${NC}"
else
    echo -e "${YELLOW}⚠️  Some tests failed. Continue? (y/n)${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Build cancelled."
        exit 1
    fi
fi

echo ""
echo "📦 Step 5: Building release App Bundle (AAB)..."
flutter build appbundle --release

echo ""
echo "📦 Step 6: Building release APKs (split per ABI)..."
flutter build apk --release --split-per-abi

echo ""
echo -e "${GREEN}✅ Android builds completed successfully!${NC}"
echo ""
echo "📁 Build outputs:"
echo "  AAB (Play Store):  build/app/outputs/bundle/release/app-release.aab"
echo "  APKs (Direct):     build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
echo "                     build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk"
echo "                     build/app/outputs/flutter-apk/app-x86_64-release.apk"
echo ""
echo "📊 File sizes:"
ls -lh build/app/outputs/bundle/release/app-release.aab | awk '{print "  AAB: " $5}'
ls -lh build/app/outputs/flutter-apk/app-arm64-v8a-release.apk | awk '{print "  APK (arm64): " $5}'
echo ""
echo "🎉 Next steps:"
echo "  1. Test the APK on a physical device"
echo "  2. Upload AAB to Play Console Internal Testing track"
echo "  3. Conduct thorough smoke tests"
echo "  4. Promote to Production when ready"
echo ""
