#!/bin/bash
# iOS Release Build Script for WAZEET App
# Version: 1.0
# Usage: ./scripts/release-ios.sh

set -e  # Exit on error

echo "🚀 WAZEET iOS Release Build"
echo "==========================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ Error: iOS builds require macOS${NC}"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Error: Xcode is not installed${NC}"
    echo "Please install Xcode from the App Store."
    exit 1
fi

echo "🧹 Step 1: Cleaning previous builds..."
flutter clean
rm -rf build/

echo ""
echo "📦 Step 2: Getting dependencies..."
flutter pub get

echo ""
echo "📦 Step 3: Installing/updating CocoaPods..."
cd ios
pod install --repo-update
cd ..

echo ""
echo "🔍 Step 4: Running code analyzer..."
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
echo "🧪 Step 5: Running tests..."
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
echo "📦 Step 6: Building iOS release..."
flutter build ios --release

echo ""
echo -e "${GREEN}✅ iOS build completed successfully!${NC}"
echo ""
echo "📁 Build output:"
echo "  build/ios/iphoneos/Runner.app"
echo ""
echo "🎉 Next steps:"
echo "  1. Open Xcode workspace:"
echo "     ${GREEN}open ios/Runner.xcworkspace${NC}"
echo ""
echo "  2. In Xcode:"
echo "     - Select 'Any iOS Device' from the device menu"
echo "     - Product > Archive"
echo "     - Wait for archive to complete"
echo "     - Window > Organizer will open"
echo "     - Select your archive"
echo "     - Click 'Distribute App'"
echo "     - Choose 'App Store Connect'"
echo "     - Follow the prompts"
echo ""
echo "  3. After upload to App Store Connect:"
echo "     - Go to App Store Connect"
echo "     - Navigate to TestFlight"
echo "     - Add internal testers"
echo "     - Conduct smoke tests"
echo "     - Submit for App Store review when ready"
echo ""
