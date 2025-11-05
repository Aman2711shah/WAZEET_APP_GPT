#!/bin/bash
set -e

echo "🚀 WAZEET APK Build Script"
echo "=========================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check Flutter version
echo -e "${YELLOW}📌 Checking Flutter installation...${NC}"
flutter --version
echo ""

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠️  Warning: .env file not found${NC}"
    echo "Creating .env from .env.example..."
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${YELLOW}Please edit .env file and add your API keys${NC}"
        echo "Press Enter to continue or Ctrl+C to exit and configure .env first"
        read
    else
        echo -e "${RED}❌ .env.example not found${NC}"
        exit 1
    fi
fi

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
flutter clean
echo ""

# Get dependencies
echo -e "${YELLOW}📥 Getting dependencies...${NC}"
flutter pub get
echo ""

# Run Flutter doctor
echo -e "${YELLOW}🏥 Running Flutter doctor...${NC}"
flutter doctor
echo ""

# Ask user for build type
echo -e "${GREEN}Select build type:${NC}"
echo "1) Debug APK (for testing, larger size)"
echo "2) Release APK (optimized, production)"
echo "3) Split APKs by ABI (smaller files)"
echo "4) App Bundle for Play Store"
read -p "Enter choice [1-4]: " choice

case $choice in
    1)
        echo -e "${GREEN}🏗️  Building Debug APK...${NC}"
        flutter build apk --debug
        APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
        ;;
    2)
        echo -e "${GREEN}🏗️  Building Release APK...${NC}"
        flutter build apk --release
        APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
        ;;
    3)
        echo -e "${GREEN}🏗️  Building Split APKs...${NC}"
        flutter build apk --split-per-abi --release
        APK_PATH="build/app/outputs/flutter-apk/"
        ;;
    4)
        echo -e "${GREEN}🏗️  Building App Bundle...${NC}"
        flutter build appbundle --release
        APK_PATH="build/app/outputs/bundle/release/app-release.aab"
        ;;
    *)
        echo -e "${RED}❌ Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""

# Check if build was successful
if [ "$choice" == "3" ]; then
    # Check for split APKs
    if ls build/app/outputs/flutter-apk/*.apk 1> /dev/null 2>&1; then
        echo -e "${GREEN}✅ Build successful!${NC}"
        echo ""
        echo -e "${GREEN}📍 APK files:${NC}"
        ls -lh build/app/outputs/flutter-apk/*.apk
    else
        echo -e "${RED}❌ Build failed!${NC}"
        exit 1
    fi
elif [ -f "$APK_PATH" ]; then
    echo -e "${GREEN}✅ Build successful!${NC}"
    echo ""
    echo -e "${GREEN}📍 Output file:${NC}"
    echo "$APK_PATH"
    ls -lh "$APK_PATH"
    echo ""
    
    # Show file size
    SIZE=$(du -h "$APK_PATH" | cut -f1)
    echo -e "${GREEN}📦 File size: $SIZE${NC}"
    
    # Offer to install on connected device
    if command -v adb &> /dev/null; then
        DEVICES=$(adb devices | grep -w "device" | wc -l)
        if [ "$DEVICES" -gt 0 ]; then
            echo ""
            read -p "Install on connected device? [y/N]: " install
            if [[ $install =~ ^[Yy]$ ]]; then
                echo -e "${YELLOW}📲 Installing APK...${NC}"
                adb install -r "$APK_PATH"
                echo -e "${GREEN}✅ Installation complete!${NC}"
            fi
        fi
    fi
else
    echo -e "${RED}❌ Build failed!${NC}"
    echo "Check the error messages above for details."
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 Build process complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Test the APK on a device"
echo "2. Verify all features work correctly"
echo "3. Check logs for any errors"
echo ""
echo "For distribution:"
if [ "$choice" == "4" ]; then
    echo "- Upload AAB to Google Play Console"
else
    echo "- Share APK for testing"
    echo "- Or upload to distribution platform"
fi
echo ""
