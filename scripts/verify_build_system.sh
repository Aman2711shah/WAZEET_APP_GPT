#!/bin/bash

################################################################################
# WAZEET Build System Verification
# Checks if all build system components are properly configured
################################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

CHECK="✅"
CROSS="❌"
WARNING="⚠️"
INFO="ℹ️"

pass_count=0
fail_count=0
warn_count=0

log_pass() {
    echo -e "${GREEN}${CHECK}${NC} $1"
    ((pass_count++))
}

log_fail() {
    echo -e "${RED}${CROSS}${NC} $1"
    ((fail_count++))
}

log_warn() {
    echo -e "${YELLOW}${WARNING}${NC} $1"
    ((warn_count++))
}

log_info() {
    echo -e "${CYAN}${INFO}${NC} $1"
}

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🚀 WAZEET Build System Verification${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check Flutter
log_info "Checking Flutter installation..."
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -1)
    log_pass "Flutter installed: ${FLUTTER_VERSION}"
else
    log_fail "Flutter not found in PATH"
fi

# Check build script
log_info "Checking build scripts..."
if [ -f "scripts/build_release.sh" ]; then
    if [ -x "scripts/build_release.sh" ]; then
        log_pass "Build script exists and is executable"
    else
        log_warn "Build script exists but is not executable (run: chmod +x scripts/build_release.sh)"
    fi
else
    log_fail "Build script not found at scripts/build_release.sh"
fi

# Check pubspec.yaml
log_info "Checking project configuration..."
if [ -f "pubspec.yaml" ]; then
    VERSION=$(grep "^version:" pubspec.yaml | awk '{print $2}')
    log_pass "pubspec.yaml found (version: ${VERSION})"
else
    log_fail "pubspec.yaml not found"
fi

# Check Android configuration
log_info "Checking Android configuration..."

if [ -d "android" ]; then
    log_pass "Android directory exists"
    
    # Check build.gradle.kts
    if grep -q "signingConfigs" android/app/build.gradle.kts; then
        log_pass "Android signing configuration found"
    else
        log_fail "Android signing configuration not found in build.gradle.kts"
    fi
    
    # Check key.properties
    if [ -f "android/key.properties" ]; then
        log_pass "android/key.properties exists"
        
        # Check if placeholder passwords
        if grep -q "wazeet_release_2024" android/key.properties; then
            log_warn "key.properties contains placeholder passwords - update with your actual passwords!"
        else
            log_pass "key.properties appears to be customized"
        fi
    else
        log_fail "android/key.properties not found"
    fi
    
    # Check keystore
    KEYSTORE_FILE=$(grep "storeFile=" android/key.properties 2>/dev/null | cut -d'=' -f2)
    if [ -n "$KEYSTORE_FILE" ]; then
        KEYSTORE_PATH="android/${KEYSTORE_FILE#../}"
        if [ -f "$KEYSTORE_PATH" ]; then
            log_pass "Android keystore found at ${KEYSTORE_PATH}"
        else
            log_warn "Keystore not found at ${KEYSTORE_PATH} - generate with keytool"
        fi
    fi
    
    # Check ProGuard rules
    if [ -f "android/app/proguard-rules.pro" ]; then
        log_pass "ProGuard rules configured"
    else
        log_warn "ProGuard rules not found"
    fi
else
    log_fail "Android directory not found"
fi

# Check iOS configuration
log_info "Checking iOS configuration..."

if [ -d "ios" ]; then
    log_pass "iOS directory exists"
    
    # Check if on macOS
    if [[ "$(uname -s)" == "Darwin" ]]; then
        log_pass "Running on macOS - iOS builds supported"
        
        # Check Xcode
        if command -v xcodebuild &> /dev/null; then
            XCODE_VERSION=$(xcodebuild -version | head -1)
            log_pass "Xcode installed: ${XCODE_VERSION}"
        else
            log_warn "Xcode not found - install from App Store"
        fi
        
        # Check CocoaPods
        if command -v pod &> /dev/null; then
            POD_VERSION=$(pod --version)
            log_pass "CocoaPods installed: ${POD_VERSION}"
        else
            log_warn "CocoaPods not found - install with: sudo gem install cocoapods"
        fi
        
        # Check Podfile
        if [ -f "ios/Podfile" ]; then
            log_pass "iOS Podfile exists"
        else
            log_warn "iOS Podfile not found"
        fi
    else
        log_warn "Not running on macOS - iOS builds not supported on this platform"
    fi
else
    log_fail "iOS directory not found"
fi

# Check documentation
log_info "Checking documentation..."

if [ -f "BUILD_GUIDE.md" ]; then
    log_pass "BUILD_GUIDE.md exists"
else
    log_warn "BUILD_GUIDE.md not found"
fi

if [ -f "BUILD_QUICK_REF.md" ]; then
    log_pass "BUILD_QUICK_REF.md exists"
else
    log_warn "BUILD_QUICK_REF.md not found"
fi

if [ -f "BUILD_SYSTEM_SUMMARY.md" ]; then
    log_pass "BUILD_SYSTEM_SUMMARY.md exists"
else
    log_warn "BUILD_SYSTEM_SUMMARY.md not found"
fi

# Check CI/CD
log_info "Checking CI/CD configuration..."

if [ -f ".github/workflows/build-release.yml" ]; then
    log_pass "GitHub Actions workflow exists"
else
    log_warn "GitHub Actions workflow not found"
fi

# Check .gitignore
log_info "Checking .gitignore..."

if [ -f "android/.gitignore" ]; then
    if grep -q "key.properties" android/.gitignore; then
        log_pass "key.properties is gitignored"
    else
        log_warn "key.properties not in .gitignore"
    fi
    
    if grep -q "*.jks" android/.gitignore; then
        log_pass "Keystore files are gitignored"
    else
        log_warn "Keystore files not in .gitignore"
    fi
else
    log_warn "android/.gitignore not found"
fi

# Summary
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📊 Verification Summary${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${GREEN}✅ Passed:${NC} $pass_count"
echo -e "  ${YELLOW}⚠️  Warnings:${NC} $warn_count"
echo -e "  ${RED}❌ Failed:${NC} $fail_count"
echo ""

if [ $fail_count -eq 0 ] && [ $warn_count -eq 0 ]; then
    echo -e "${GREEN}🎉 All checks passed! Build system is ready.${NC}"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo "  1. Generate keystore: cd android && keytool -genkey -v -keystore key.jks ..."
    echo "  2. Update android/key.properties with your passwords"
    echo "  3. Configure iOS signing in Xcode (if on macOS)"
    echo "  4. Run: ./scripts/build_release.sh"
    echo ""
    exit 0
elif [ $fail_count -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Some warnings found. Review and fix as needed.${NC}"
    echo ""
    echo -e "${CYAN}Common fixes:${NC}"
    echo "  - Generate keystore: keytool -genkey -v -keystore android/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias wazeet"
    echo "  - Update android/key.properties with your passwords"
    echo "  - Install CocoaPods: sudo gem install cocoapods"
    echo "  - Make script executable: chmod +x scripts/build_release.sh"
    echo ""
    exit 0
else
    echo -e "${RED}❌ Some checks failed. Fix the issues above before building.${NC}"
    echo ""
    echo -e "${CYAN}Troubleshooting:${NC}"
    echo "  - Review BUILD_GUIDE.md for detailed setup instructions"
    echo "  - Run: flutter doctor -v"
    echo "  - Check that all required files are present"
    echo ""
    exit 1
fi
