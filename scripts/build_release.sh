#!/bin/bash

################################################################################
# WAZEET Production Build Script
# Builds release APK, AAB for Android and IPA for iOS
# Usage: ./scripts/build_release.sh [android|ios|all]
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Emoji for better visual feedback
CHECK="✅"
CROSS="❌"
ROCKET="🚀"
HAMMER="🔨"
PACKAGE="📦"
APPLE="🍏"
ROBOT="🤖"
CLOCK="⏰"
INFO="ℹ️"
WARNING="⚠️"

################################################################################
# Helper Functions
################################################################################

log_header() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}${1}${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

log_step() {
    echo -e "${BLUE}${HAMMER} [$(date '+%H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}${CHECK} $1${NC}"
}

log_error() {
    echo -e "${RED}${CROSS} $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}${WARNING} $1${NC}"
}

log_info() {
    echo -e "${MAGENTA}${INFO} $1${NC}"
}

timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

################################################################################
# Platform Detection
################################################################################

detect_platform() {
    case "$(uname -s)" in
        Darwin*)
            PLATFORM="macOS"
            CAN_BUILD_IOS=true
            CAN_BUILD_ANDROID=true
            ;;
        Linux*)
            PLATFORM="Linux"
            CAN_BUILD_IOS=false
            CAN_BUILD_ANDROID=true
            ;;
        MINGW*|MSYS*|CYGWIN*)
            PLATFORM="Windows"
            CAN_BUILD_IOS=false
            CAN_BUILD_ANDROID=true
            ;;
        *)
            PLATFORM="Unknown"
            CAN_BUILD_IOS=false
            CAN_BUILD_ANDROID=true
            ;;
    esac
}

################################################################################
# Version Management
################################################################################

get_version_info() {
    if [ -f "pubspec.yaml" ]; then
        VERSION_LINE=$(grep "^version:" pubspec.yaml)
        VERSION_FULL=$(echo "$VERSION_LINE" | awk '{print $2}')
        VERSION_NAME=$(echo "$VERSION_FULL" | cut -d'+' -f1)
        VERSION_CODE=$(echo "$VERSION_FULL" | cut -d'+' -f2)
        
        log_info "Current version: ${VERSION_NAME} (Build ${VERSION_CODE})"
    else
        log_error "pubspec.yaml not found!"
        exit 1
    fi
}

increment_version() {
    local current_code=$1
    local new_code=$((current_code + 1))
    
    log_step "Incrementing build number: ${current_code} → ${new_code}"
    
    # Update pubspec.yaml
    sed -i.bak "s/^version: ${VERSION_NAME}+${current_code}/version: ${VERSION_NAME}+${new_code}/" pubspec.yaml
    rm pubspec.yaml.bak
    
    VERSION_CODE=$new_code
    log_success "Build number updated to ${new_code}"
}

################################################################################
# Pre-flight Checks
################################################################################

check_flutter() {
    log_step "Checking Flutter installation..."
    
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    FLUTTER_VERSION=$(flutter --version | head -1)
    log_success "Flutter found: ${FLUTTER_VERSION}"
}

check_android_tools() {
    log_step "Checking Android build tools..."
    
    if [ ! -d "android" ]; then
        log_error "Android directory not found!"
        return 1
    fi
    
    # Check for keystore configuration
    if [ ! -f "android/key.properties" ]; then
        log_warning "No android/key.properties found!"
        log_info "Create keystore with:"
        log_info "  keytool -genkey -v -keystore android/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias wazeet"
        log_warning "Builds will use debug signing (not suitable for production!)"
        return 0
    fi
    
    # Check if keystore file exists
    KEYSTORE_FILE=$(grep "storeFile=" android/key.properties | cut -d'=' -f2)
    KEYSTORE_PATH="android/${KEYSTORE_FILE#../}"
    
    if [ ! -f "$KEYSTORE_PATH" ]; then
        log_warning "Keystore file not found at: ${KEYSTORE_PATH}"
        log_info "Generate it with:"
        log_info "  keytool -genkey -v -keystore ${KEYSTORE_PATH} -keyalg RSA -keysize 2048 -validity 10000 -alias wazeet"
        return 0
    fi
    
    log_success "Android keystore configured at: ${KEYSTORE_PATH}"
}

check_ios_tools() {
    if [ "$CAN_BUILD_IOS" = false ]; then
        log_warning "iOS builds not supported on ${PLATFORM}"
        return 1
    fi
    
    log_step "Checking iOS build tools..."
    
    if ! command -v pod &> /dev/null; then
        log_error "CocoaPods not installed. Install with: sudo gem install cocoapods"
        return 1
    fi
    
    if ! command -v xcodebuild &> /dev/null; then
        log_error "Xcode command line tools not found. Install Xcode from App Store."
        return 1
    fi
    
    log_success "iOS build tools ready"
    return 0
}

################################################################################
# Clean and Prepare
################################################################################

prepare_build() {
    log_header "${HAMMER} Preparing Build Environment"
    
    log_step "Cleaning previous builds..."
    flutter clean
    log_success "Clean complete"
    
    log_step "Getting dependencies..."
    flutter pub get
    log_success "Dependencies fetched"
    
    log_step "Running Flutter analyze..."
    if flutter analyze --no-fatal-infos; then
        log_success "Code analysis passed"
    else
        log_warning "Code analysis found issues (continuing anyway)"
    fi
}

################################################################################
# Android Build
################################################################################

build_android() {
    log_header "${ROBOT} Building Android Release"
    
    local start_time=$(date +%s)
    
    # Build APK (split per ABI for smaller size)
    log_step "Building release APK (split per ABI)..."
    if flutter build apk --release --split-per-abi; then
        log_success "APK build complete"
        
        # List APK files
        log_info "APK files:"
        ls -lh build/app/outputs/flutter-apk/*.apk | awk '{print "  - " $9 " (" $5 ")"}'
    else
        log_error "APK build failed"
        return 1
    fi
    
    # Build AAB for Play Store
    log_step "Building release AAB (Play Store)..."
    if flutter build appbundle --release; then
        log_success "AAB build complete"
        
        # Show AAB file
        log_info "AAB file:"
        ls -lh build/app/outputs/bundle/release/app-release.aab | awk '{print "  - " $9 " (" $5 ")"}'
    else
        log_error "AAB build failed"
        return 1
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_success "Android build completed in ${duration}s"
    
    # Store build info
    ANDROID_BUILD_SUCCESS=true
    ANDROID_BUILD_TIME=$duration
    ANDROID_APK_PATH="build/app/outputs/flutter-apk/"
    ANDROID_AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
}

################################################################################
# iOS Build
################################################################################

build_ios() {
    if [ "$CAN_BUILD_IOS" = false ]; then
        log_warning "Skipping iOS build (not supported on ${PLATFORM})"
        IOS_BUILD_SUCCESS=false
        return 0
    fi
    
    log_header "${APPLE} Building iOS Release"
    
    local start_time=$(date +%s)
    
    # Update CocoaPods
    log_step "Updating CocoaPods..."
    cd ios
    pod install --repo-update
    cd ..
    log_success "Pods updated"
    
    # Build IPA
    log_step "Building release IPA..."
    if flutter build ipa --release --export-method app-store; then
        log_success "IPA build complete"
        
        # Show IPA file
        log_info "IPA file:"
        if [ -f "build/ios/ipa/wazeet.ipa" ]; then
            ls -lh build/ios/ipa/wazeet.ipa | awk '{print "  - " $9 " (" $5 ")"}'
            IOS_IPA_PATH="build/ios/ipa/wazeet.ipa"
        else
            log_warning "IPA file not found at expected location"
            IOS_IPA_PATH="(check build/ios/archive/)"
        fi
    else
        log_error "IPA build failed"
        log_info "You may need to:"
        log_info "  1. Open ios/Runner.xcworkspace in Xcode"
        log_info "  2. Configure signing with your Apple Developer account"
        log_info "  3. Select Product → Archive"
        log_info "  4. Distribute to App Store Connect"
        return 1
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_success "iOS build completed in ${duration}s"
    
    # Store build info
    IOS_BUILD_SUCCESS=true
    IOS_BUILD_TIME=$duration
}

################################################################################
# Build Report Generation
################################################################################

generate_build_report() {
    log_header "📝 Generating Build Report"
    
    local report_file="BUILD_REPORT.md"
    
    cat > "$report_file" <<EOF
# 🚀 WAZEET Build Report

**Generated:** $(timestamp)  
**Platform:** ${PLATFORM}  
**Flutter Version:** ${FLUTTER_VERSION}

---

## 📱 Version Information

- **Version Name:** ${VERSION_NAME}
- **Build Number:** ${VERSION_CODE}
- **Bundle ID (iOS):** com.wazeet.wazeet
- **Application ID (Android):** com.wazeet.app

---

## ${ROBOT} Android Build

EOF

    if [ "$ANDROID_BUILD_SUCCESS" = true ]; then
        cat >> "$report_file" <<EOF
**Status:** ✅ Success  
**Build Time:** ${ANDROID_BUILD_TIME}s

### APK Files (Split per ABI)
\`\`\`
$(ls -lh build/app/outputs/flutter-apk/*.apk 2>/dev/null | awk '{print $9 " - " $5}' || echo "No APK files found")
\`\`\`

**Location:** \`${ANDROID_APK_PATH}\`

### AAB File (Play Store)
\`\`\`
$(ls -lh build/app/outputs/bundle/release/app-release.aab 2>/dev/null | awk '{print $9 " - " $5}' || echo "No AAB file found")
\`\`\`

**Location:** \`${ANDROID_AAB_PATH}\`

### Checksums
\`\`\`
$(find build/app/outputs/flutter-apk/ -name "*.apk" -exec sha256sum {} \; 2>/dev/null || echo "Checksums not available")
$(sha256sum build/app/outputs/bundle/release/app-release.aab 2>/dev/null || echo "Checksum not available")
\`\`\`

### Upload to Play Console
1. Go to [Google Play Console](https://play.google.com/console)
2. Select your app
3. Navigate to **Release → Production**
4. Create new release and upload \`app-release.aab\`

EOF
    else
        cat >> "$report_file" <<EOF
**Status:** ❌ Failed or Skipped

EOF
    fi

    cat >> "$report_file" <<EOF
---

## ${APPLE} iOS Build

EOF

    if [ "$IOS_BUILD_SUCCESS" = true ]; then
        cat >> "$report_file" <<EOF
**Status:** ✅ Success  
**Build Time:** ${IOS_BUILD_TIME}s

### IPA File
\`\`\`
$(ls -lh build/ios/ipa/*.ipa 2>/dev/null | awk '{print $9 " - " $5}' || echo "IPA location: ${IOS_IPA_PATH}")
\`\`\`

**Location:** \`${IOS_IPA_PATH}\`

### Upload to App Store Connect
1. Open Xcode
2. Navigate to **Window → Organizer**
3. Select the archive
4. Click **Distribute App**
5. Choose **App Store Connect**
6. Follow the upload wizard

Or use command line:
\`\`\`bash
xcrun altool --upload-app --type ios --file "${IOS_IPA_PATH}" \\
  --username "your@apple.id" --password "@keychain:APP_SPECIFIC_PASSWORD"
\`\`\`

EOF
    elif [ "$CAN_BUILD_IOS" = false ]; then
        cat >> "$report_file" <<EOF
**Status:** ⚠️  Skipped (iOS builds require macOS)

EOF
    else
        cat >> "$report_file" <<EOF
**Status:** ❌ Failed

Check the build logs above for errors. Common issues:
- Missing code signing certificates
- Incorrect provisioning profiles
- Bundle identifier mismatch

EOF
    fi

    cat >> "$report_file" <<EOF
---

## 🧪 Pre-Release Checklist

- [ ] Version number incremented
- [ ] App tested on physical devices
- [ ] All Firebase services configured
- [ ] Stripe payment integration tested
- [ ] App icons and splash screens updated
- [ ] Privacy policy and terms of service links working
- [ ] Push notification permissions tested
- [ ] Deep linking tested
- [ ] App Store / Play Store listings prepared
- [ ] Screenshots and promotional materials ready

---

## 📋 Next Steps

### Android
1. Test the APK on a physical device:
   \`\`\`bash
   adb install ${ANDROID_APK_PATH}app-arm64-v8a-release.apk
   \`\`\`

2. Upload AAB to Play Console for internal testing
3. Promote to production when ready

### iOS
1. Upload to TestFlight for beta testing
2. Submit for App Store review
3. Monitor crash reports and user feedback

---

## 📊 Build Artifacts

| Platform | Type | Path | Size |
|----------|------|------|------|
EOF

    # Add Android artifacts
    if [ "$ANDROID_BUILD_SUCCESS" = true ]; then
        for apk in build/app/outputs/flutter-apk/*.apk; do
            if [ -f "$apk" ]; then
                size=$(ls -lh "$apk" | awk '{print $5}')
                echo "| Android | APK | \`$apk\` | $size |" >> "$report_file"
            fi
        done
        
        if [ -f "$ANDROID_AAB_PATH" ]; then
            size=$(ls -lh "$ANDROID_AAB_PATH" | awk '{print $5}')
            echo "| Android | AAB | \`$ANDROID_AAB_PATH\` | $size |" >> "$report_file"
        fi
    fi

    # Add iOS artifacts
    if [ "$IOS_BUILD_SUCCESS" = true ]; then
        if [ -f "$IOS_IPA_PATH" ]; then
            size=$(ls -lh "$IOS_IPA_PATH" | awk '{print $5}')
            echo "| iOS | IPA | \`$IOS_IPA_PATH\` | $size |" >> "$report_file"
        fi
    fi

    cat >> "$report_file" <<EOF

---

**Build Script:** \`scripts/build_release.sh\`  
**Build Host:** $(hostname)  
**Build User:** $(whoami)
EOF

    log_success "Build report generated: ${report_file}"
}

################################################################################
# Main Execution
################################################################################

main() {
    local build_target="${1:-all}"
    
    log_header "${ROCKET} WAZEET Production Build Script"
    log_info "Build target: ${build_target}"
    log_info "Platform: ${PLATFORM}"
    log_info "Started at: $(timestamp)"
    
    # Initialize build status variables
    ANDROID_BUILD_SUCCESS=false
    IOS_BUILD_SUCCESS=false
    ANDROID_BUILD_TIME=0
    IOS_BUILD_TIME=0
    
    # Detect platform capabilities
    detect_platform
    
    # Pre-flight checks
    check_flutter
    get_version_info
    
    # Ask to increment version
    if [ -t 0 ]; then  # Check if running interactively
        echo ""
        read -p "Increment build number? (y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            increment_version "$VERSION_CODE"
            get_version_info  # Refresh version info
        fi
    fi
    
    # Prepare environment
    prepare_build
    
    # Build based on target
    case "$build_target" in
        android)
            check_android_tools
            build_android
            ;;
        ios)
            check_ios_tools && build_ios || log_warning "iOS build skipped"
            ;;
        all|*)
            check_android_tools
            build_android
            
            echo ""
            check_ios_tools && build_ios || log_warning "iOS build skipped"
            ;;
    esac
    
    # Generate build report
    echo ""
    generate_build_report
    
    # Final summary
    log_header "${ROCKET} Build Complete!"
    
    if [ "$ANDROID_BUILD_SUCCESS" = true ]; then
        log_success "Android build successful (${ANDROID_BUILD_TIME}s)"
    fi
    
    if [ "$IOS_BUILD_SUCCESS" = true ]; then
        log_success "iOS build successful (${IOS_BUILD_TIME}s)"
    fi
    
    log_info "Build report: BUILD_REPORT.md"
    log_info "Finished at: $(timestamp)"
    
    echo ""
}

# Run main function
main "$@"
