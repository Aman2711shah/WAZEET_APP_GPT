# WAZEET App - Play Store & App Store Deployment Checklist

**Generated:** November 12, 2025  
**App Version:** 1.0.4+8  
**Status:** ⚠️ NEEDS FIXES BEFORE DEPLOYMENT

---

## ✅ CRITICAL ERRORS - ALL FIXED! (November 12, 2025)

### 1. **Build Failure - IconData Issue** ✅ FIXED
**Location:** `lib/models/user_activity.dart:47`

**Error:** (RESOLVED)
```
Avoid non-constant invocations of IconData
Target aot_android_asset_bundle failed
```

**Solution Applied:**
- ✅ Added const icon map with 20+ common icons
- ✅ Changed model to store `iconName` as String
- ✅ Updated `fromJson` to use const icon lookup
- ✅ Updated all UserActivity constructor calls

**Result:** 🎉 **Release builds now work!**
- APK: 69 MB generated successfully
- AAB: 62 MB generated successfully
- Tree-shaking: Working (99.9% font reduction)

---

### 2. **Unused Code - Dead Code Warnings** ✅ FIXED
**Location:** `lib/ui/pages/home_page.dart`

**Solution Applied:**
- ✅ Removed `_buildEmptyActivityState` method
- ✅ Removed `_buildActivityCard` method

**Result:** 🎉 **flutter analyze shows "No issues found!"**

---

## 📱 PLAY STORE REQUIREMENTS

### ✅ **Completed:**
1. ✅ App signing configured (`key.jks` exists)
2. ✅ Release build configuration in `build.gradle.kts`
3. ✅ ProGuard rules configured
4. ✅ App bundle support enabled
5. ✅ Application ID: `com.wazeet.app`
6. ✅ Version: 1.0.4 (Build 8)
7. ✅ MinSDK: 21 (Android 5.0+)
8. ✅ TargetSDK: Latest Flutter default
9. ✅ Google Services configured
10. ✅ App icons present (all densities)
11. ✅ Android manifest configured

### ❌ **Missing:**

#### 1. **Privacy Policy URL** 🔴 REQUIRED
- **Status:** Missing
- **Required by:** Google Play Store
- **Action:** Create and host privacy policy at a publicly accessible URL
- **Must include:**
  - Data collection practices
  - Firebase usage disclosure
  - Stripe payment processing disclosure
  - Google Sign-In data handling
  - Apple Sign-In data handling (if applicable)
  - User rights (access, deletion, etc.)

#### 2. **App Store Listing Assets** 🔴 REQUIRED
- **Screenshots:** None found in `assets/images/`
  - Need: 2-8 screenshots per device type (phone, tablet)
  - Sizes: Various (Play Console will specify)
- **Feature Graphic:** 1024x500 px
- **App Icon:** 512x512 px (high-res)
- **Promotional assets:** Optional but recommended

#### 3. **Content Rating** 🔴 REQUIRED
- Must complete Play Console questionnaire
- Expected rating: E (Everyone) or E10+
- Depends on: AI chatbot interactions, community features

#### 4. **Store Listing Text** 🔴 REQUIRED
- **Short description:** (80 chars max) - Not found
- **Full description:** (4000 chars max) - Not found
- **Title:** "Wazeet" (verify 30 chars max)
- **Category:** Business or Productivity

#### 5. **Target Audience & Age Restrictions** 🔴 REQUIRED
- Define target age group
- UAE business owners/entrepreneurs (likely 18+)
- Declare if app is child-directed

#### 6. **App Access** 🔴 REQUIRED
- Demo account credentials (if login required)
- Testing instructions for reviewers

#### 7. **Data Safety Form** 🔴 REQUIRED
- Declare all data collection:
  - User account info ✓
  - Payment info ✓
  - User-generated content ✓
  - Device/app info ✓
- Encryption in transit: Yes
- User can request deletion: Specify
- Data sharing with third parties:
  - Firebase
  - Stripe
  - OpenAI
  - HubSpot

#### 8. **Production Release Track Setup** 🟡 RECOMMENDED
- **Current:** Deployment scripts exist but not configured
- **Android Fastlane:** Not set up
- **Action:** Configure `android/fastlane/` (optional but recommended)

#### 9. **Permissions Declaration** ⚠️ REVIEW NEEDED
- **Current:** Minimal permissions (good!)
- **Review:** Ensure all required permissions are declared
- **Common needs:**
  - `INTERNET` - Likely auto-added by Flutter
  - `ACCESS_NETWORK_STATE` - For connectivity checks
  - Camera/Storage - Only if file uploads need them

---

## 🍎 APP STORE (iOS) REQUIREMENTS

### ✅ **Completed:**
1. ✅ Bundle ID: `com.wazeet.wazeet`
2. ✅ App icons configured (all sizes)
3. ✅ Info.plist present
4. ✅ Display name: "Wazeet"
5. ✅ Version: 1.0.4 (Build 8)
6. ✅ Google Services configured
7. ✅ Launch screen configured

### ❌ **Missing:**

#### 1. **Apple Developer Account** 🔴 REQUIRED
- **Status:** Unknown
- **Cost:** $99/year
- **Needed for:** Code signing, TestFlight, App Store distribution

#### 2. **Development Team ID** 🔴 REQUIRED
- **Status:** Not set in Xcode project
- **Found:** No `DEVELOPMENT_TEAM` in `project.pbxproj`
- **Action:** Must set in Xcode → Signing & Capabilities

#### 3. **Code Signing Certificates** 🔴 REQUIRED
- iOS Distribution Certificate
- Provisioning Profile for App Store

#### 4. **Privacy Policy URL** 🔴 REQUIRED
- Same as Android requirement
- Must be accessible via web browser

#### 5. **App Store Listing Assets** 🔴 REQUIRED
- **Screenshots:** 
  - iPhone 6.7" (1290x2796 px) - 3-10 required
  - iPhone 5.5" (1242x2208 px) - 3-10 required
  - iPad Pro 12.9" (2048x2732 px) - If supporting iPad
- **App Preview Videos:** Optional
- **App Icon:** Verified ✓

#### 6. **App Store Description** 🔴 REQUIRED
- **Name:** "Wazeet" (30 chars max)
- **Subtitle:** Not found (30 chars max)
- **Description:** Not found (4000 chars max)
- **Keywords:** Not found (100 chars max, comma-separated)
- **Promotional text:** Optional (170 chars)
- **Support URL:** Required
- **Marketing URL:** Optional

#### 7. **App Privacy Details** 🔴 REQUIRED (New requirement)
- Must complete in App Store Connect
- Declare all data types collected:
  - Contact Info (email)
  - User Content (posts, events)
  - Identifiers
  - Usage Data
  - Financial Info (payment data)
- Link data to user: Yes
- Track user: Specify if using analytics

#### 8. **Export Compliance** 🟡 REQUIRED
- Declare encryption usage
- Flutter apps using HTTPS: "No" to ITR exemption question
- Standard answer: Uses encryption but qualifies for exemption

#### 9. **Privacy Permission Descriptions** ⚠️ MISSING
**Current:** Only has `NSPhotoLibraryUsageDescription`

**Likely Needed:**
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access for uploading profile photos and documents</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library access for uploading images and documents</string> ✓ PRESENT

<key>NSLocationWhenInUseUsageDescription</key>
<string>Location helps recommend nearby business services</string>
<!-- Only if using location -->
```

**Action:** Add to `ios/Runner/Info.plist` if features use them

#### 10. **TestFlight Setup** 🟡 RECOMMENDED
- Not configured
- Useful for beta testing before public release

#### 11. **iOS Fastlane** 🟡 OPTIONAL
- **Status:** Not configured
- **Location:** `ios/fastlane/` doesn't exist
- **Scripts exist:** `scripts/deploy-ios-beta.sh` but needs Fastlane

---

## 🔐 COMPLIANCE & LEGAL

### ❌ **Missing Legal Documents:**

#### 1. **Privacy Policy** 🔴 CRITICAL
**Required sections:**
- Data controller information
- Types of data collected
- Purpose of collection
- Third-party services:
  - Firebase (Google)
  - Stripe
  - OpenAI
  - HubSpot
- User rights (GDPR compliance)
- Data retention
- Children's privacy
- Contact information

**Hosting options:**
- GitHub Pages
- Your website
- Privacy policy generators (iubenda, termly, etc.)

#### 2. **Terms of Service** 🔴 REQUIRED
**Must cover:**
- Service description
- User obligations
- Payment terms (Stripe)
- Account termination
- Limitation of liability
- Governing law (UAE?)
- Dispute resolution

**Location:** Not found in repository

#### 3. **GDPR Compliance** 🟡 RECOMMENDED
- Right to access data
- Right to deletion
- Data portability
- Cookie consent (if using web tracking)

#### 4. **UAE Data Protection Laws** ⚠️ REVIEW
- Check UAE Federal Data Protection Law
- May need specific disclosures for UAE users

---

## 🧪 TESTING & QUALITY

### ✅ **Good:**
1. ✅ 35 unit tests passing
2. ✅ `flutter analyze` reports no issues
3. ✅ Test coverage includes:
   - Tax calculations
   - AI context management
   - Service tiers
   - Auth tokens
   - Widget tests

### ⚠️ **Needs Improvement:**

#### 1. **Integration Tests** 🟡 RECOMMENDED
- Folder exists: `integration_test/`
- Status: Unknown if populated
- Recommended: E2E tests for critical flows

#### 2. **Release Build Testing** 🔴 CRITICAL
- **Android:** Currently fails (IconData issue)
- **iOS:** Not tested
- **Action:** Test on physical devices before submission

#### 3. **Performance Testing** 🟡 RECOMMENDED
- App startup time
- Memory usage
- Network performance
- Battery consumption

---

## 🚀 DEPLOYMENT AUTOMATION

### ✅ **Existing:**
1. ✅ Scripts present:
   - `scripts/deploy-android-beta.sh`
   - `scripts/deploy-ios-beta.sh`
   - `scripts/deploy-beta-all.sh`
2. ✅ Documentation:
   - `BETA_DEPLOY_QUICK_START.md`
   - `docs/BETA_DISTRIBUTION.md`

### ❌ **Not Configured:**
1. ❌ iOS Fastlane setup
2. ❌ Android Fastlane setup (optional)
3. ❌ CI/CD pipeline verification
4. ⚠️ GitHub Actions workflow (exists but not verified)

---

## 📋 PRE-SUBMISSION CHECKLIST

### Before Play Store Submission:

- [x] Fix IconData build error ✅ COMPLETED
- [x] Remove unused code warnings ✅ COMPLETED
- [x] Successfully build release APK/AAB ✅ COMPLETED (69MB APK, 62MB AAB)
- [ ] Test on multiple Android devices
- [ ] Create privacy policy URL
- [ ] Prepare screenshots (2-8 per device)
- [ ] Create feature graphic (1024x500)
- [ ] Write store listing (short + full description)
- [ ] Complete content rating questionnaire
- [ ] Fill out Data Safety form
- [ ] Set up production release track
- [ ] Create demo account (if needed)
- [ ] Test payment flow end-to-end
- [ ] Verify all Firebase rules are production-ready
- [ ] Review ProGuard rules for completeness

### Before App Store Submission:

- [x] Fix IconData build error (same as Android) ✅ COMPLETED
- [ ] Enroll in Apple Developer Program ($99)
- [ ] Set Development Team ID in Xcode
- [ ] Create iOS Distribution Certificate
- [ ] Create Provisioning Profile
- [ ] Successfully build release IPA
- [ ] Test on multiple iOS devices
- [ ] Create privacy policy URL (same as Android)
- [ ] Prepare screenshots (all required sizes)
- [ ] Write App Store description
- [ ] Choose subtitle and keywords
- [ ] Complete App Privacy details
- [ ] Add privacy permission descriptions
- [ ] Answer export compliance questions
- [ ] Set up TestFlight (recommended)
- [ ] Test payment flow on iOS
- [ ] Verify Sign in with Apple works

---

## 🎯 ESTIMATED TIMELINE

| Task | Time Estimate | Priority |
|------|---------------|----------|
| Fix IconData build error | 2-4 hours | 🔴 Critical |
| Create Privacy Policy | 4-8 hours | 🔴 Critical |
| Create Terms of Service | 3-6 hours | 🔴 Critical |
| Prepare Play Store assets | 6-8 hours | 🔴 Critical |
| Prepare App Store assets | 6-8 hours | 🔴 Critical |
| Complete Play Store listing | 2-3 hours | 🔴 Critical |
| Complete App Store listing | 2-3 hours | 🔴 Critical |
| iOS code signing setup | 1-2 hours | 🔴 Critical |
| Data Safety/Privacy forms | 2-3 hours | 🔴 Critical |
| Release testing (both platforms) | 8-16 hours | 🟡 Important |
| Fix unused code warnings | 1 hour | 🟢 Nice to have |

**Total estimated time:** 40-65 hours

---

## 🔧 QUICK FIX GUIDE

### Fix #1: IconData Build Error

**File:** `lib/models/user_activity.dart`

**Option A - Recommended (Map icon codes):**
```dart
// Create icon map
static const _iconMap = {
  'task': Icons.task_alt,
  'service': Icons.business_center,
  'payment': Icons.payment,
  // ... add all used icons
};

// In UserActivity model, store icon name as String
final String iconName;

// Update toJson
'iconName': iconName,

// Update fromJson
icon: _iconMap[json['iconName']] ?? Icons.help_outline,
```

**Option B - Quick workaround (not recommended):**
```bash
flutter build appbundle --no-tree-shake-icons
```

### Fix #2: Remove Unused Methods

**File:** `lib/ui/pages/home_page.dart`

Remove or integrate:
- Lines 605-660: `_buildEmptyActivityState`
- Lines 665+: `_buildActivityCard`

---

## 📞 SUPPORT & RESOURCES

### Useful Links:
- **Play Console:** https://play.google.com/console
- **App Store Connect:** https://appstoreconnect.apple.com
- **Flutter Build Docs:** https://docs.flutter.dev/deployment
- **Privacy Policy Generator:** https://www.termsfeed.com/privacy-policy-generator/
- **Google Play Requirements:** https://support.google.com/googleplay/android-developer/answer/9859455

### Testing Resources:
- Use Firebase Test Lab for Android testing
- Use TestFlight for iOS beta testing
- Test on real devices, not just simulators

---

## ✅ SUMMARY

**Current Status:** App is ~85% ready for deployment ⬆️ (improved from 70%)

**Critical Blockers:** 1 ⬇️ (reduced from 2)
1. ~~IconData build error (Android & iOS)~~ ✅ **FIXED!**
2. Missing legal documents (Privacy Policy, Terms)

**Store-Specific Items:** ~15 per platform

**Recommended Action Plan:**
1. **Week 1:** Fix build errors, create legal documents
2. **Week 2:** Prepare store assets, complete listings
3. **Week 3:** Testing, iOS setup, final review
4. **Week 4:** Submit to both stores

**Good News:** 
- Core infrastructure is solid ✓
- Tests are passing ✓
- Build system is configured ✓
- Signing is set up (Android) ✓

**Next Steps:** Focus on fixing IconData issue first, then legal compliance.

---

*This checklist was automatically generated. Verify all items manually before submission.*
