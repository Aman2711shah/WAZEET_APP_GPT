# WAZEET App - Issue Location Map

This document provides a visual guide to where issues are located in the app.

## App Structure Overview

```
WAZEET App
├── Home Tab ⚠️⚠️
│   ├── Profile Avatar (top-right) ⚠️
│   ├── Quick Stats Card ❌ (hardcoded data)
│   ├── Quick Actions Grid ⚠️
│   │   ├── Company Setup ⚠️
│   │   ├── Visa Services ✓
│   │   ├── Find Your Free Zone ✓
│   │   ├── Tax Services ✓
│   │   ├── Accounting ✓
│   │   └── Freezone Finder ⚠️
│   ├── Tips & Insights
│   │   ├── Ask AI Advisor → Freezone Browser ✓
│   │   ├── Investment Map ✓
│   │   ├── Corporate Tax Info ✓
│   │   ├── Tax Deadline Info ✓
│   │   └── Golden Visa Info ✓
│   └── Recent Activity ❌ (hardcoded data)
│
├── Services Tab ⚠️
│   ├── Search Bar ⚠️ (limited functionality)
│   ├── Service Categories ⚠️ (null check needed)
│   └── Service Detail Pages ✓
│
├── Community Tab ⚠️⚠️
│   ├── Post Feed ✓
│   ├── Create Button (when active) ❌
│   │   ├── Write Article ❌ (not functional)
│   │   ├── Create Poll ❌ (not functional)
│   │   ├── Create Event ❌ (not functional)
│   │   └── Share Photo ❌ (not functional)
│   └── User Profiles ✓
│
├── Track Tab ⚠️
│   ├── Request ID Input ⚠️
│   ├── Track Button ⚠️ (poor error handling)
│   └── Status Display ⚠️
│
└── More Tab ⚠️⚠️
    ├── Profile Section ⚠️
    ├── Edit Profile ❌ (incomplete)
    ├── Linked Accounts ❌ (placeholder)
    ├── Account Settings ✓
    ├── Appearance Settings ✓
    ├── Privacy Policy ✓
    ├── Admin Requests ❌❌ (no access control)
    └── Sign Out ⚠️

Floating Elements
├── AI Chatbot (bottom-right) ⚠️⚠️
│   ├── Chat Window ⚠️ (fixed size, not responsive)
│   └── API Integration ❌ (fails without .env)
└── Human Support (bottom-left) ✓
    └── Contact Options ✓

Legend:
✓ = Working properly
⚠️ = Minor issues or improvements needed
⚠️⚠️ = Multiple issues present
❌ = Critical issue or not functional
❌❌ = Severe security/functionality issue
```

## Issues by Screen

### 🏠 Home Page (home_page.dart)
**Location:** `lib/ui/pages/home_page.dart`

#### Issues Found:
1. **Lines 217-248:** Hardcoded statistics (MEDIUM)
   - Shows fake numbers: "3 Active Services", "5 Pending Tasks", "12 Documents"
   - Should fetch real user data from Firebase

2. **Lines 534-557:** Hardcoded activity cards (MEDIUM)
   - Shows fake activity: "Employment Visa Renewal", "VAT Registration", etc.
   - Misleading for new users

3. **Line 2014:** Company Setup Modal (MEDIUM)
   - Opens but completion status unclear
   - Need to verify full flow works

4. **Lines 343-419:** Quick Actions (HIGH)
   - Service category access uses `firstWhere` without null check
   - Will crash if categories not loaded

### 💼 Services Page (services_page.dart)
**Location:** `lib/ui/pages/services_page.dart`

#### Issues Found:
1. **Lines 125-132:** Search functionality (LOW)
   - Only filters visible categories
   - Doesn't search sub-services or details

2. **Lines 48-56:** Network image loading (LOW)
   - Basic error handling
   - Could use better placeholders

3. **Service Provider Dependency (HIGH):**
   - Depends on `servicesProvider` which may return empty list
   - Needs null/empty state handling

### 👥 Community Page (community_page.dart)
**Location:** `lib/ui/pages/community_page.dart`

#### Issues Found:
1. **Lines 75-100:** Article Editor (MEDIUM)
   - Dialog shown but no save functionality
   - No Firebase integration

2. **Lines 23-72:** Create Options Menu (MEDIUM)
   - All create actions are incomplete
   - Buttons lead nowhere

3. **Post Feed:**
   - May not handle empty state well
   - No loading indicator mentioned

### 📊 Applications/Track Page (applications_page.dart)
**Location:** `lib/ui/pages/applications_page.dart`

#### Issues Found:
1. **Lines 49-70:** Error handling (MEDIUM)
   - Generic error messages
   - No retry mechanism
   - No examples of valid ID format

2. **Lines 36-70:** Network calls (MEDIUM)
   - No loading state shown to user
   - Could improve UX

### ⚙️ More/Profile Page (profile_page.dart)
**Location:** `lib/ui/pages/profile_page.dart`

#### Issues Found:
1. **Lines 19-23:** User handling (HIGH)
   - Allows null user (no auth required)
   - Shows default data even when not authenticated

2. **Navigation to sub-pages:**
   - Edit Profile → Incomplete (HIGH)
   - Linked Accounts → Placeholder (MEDIUM)
   - Admin Requests → No access control (HIGH)

### 🤖 AI Chatbot (floating_ai_chatbot.dart)
**Location:** `lib/ui/widgets/floating_ai_chatbot.dart`

#### Issues Found:
1. **Lines 392-395:** Fixed dimensions (MEDIUM)
   - 380x550 fixed size
   - Not responsive to screen size
   - May cover entire screen on small devices

2. **Lines 128-169:** API dependency (MEDIUM)
   - Fails silently without API key
   - No user notification of degraded mode

3. **Lines 190-194:** Positioning (MEDIUM)
   - May overlap with bottom nav on some devices
   - Not tested on all screen sizes

### 🛡️ Security Issues

#### 🔴 CRITICAL
1. **Root directory:** Missing `.env` file
   - App won't start without it
   - No documentation for setup

2. **lib/config/app_config.dart:** API key management
   - May expose sensitive keys
   - Need to verify encryption

3. **lib/main.dart:** No authentication gate
   - App accessible without login
   - User features available to non-authenticated users

#### 🟠 HIGH
1. **lib/ui/pages/admin_requests_page.dart:** No access control
   - Any user can potentially access admin features
   - Need role-based access control (RBAC)

2. **firestore.rules:** Security rules not verified
   - Can't confirm proper data access restrictions
   - May allow unauthorized reads/writes

## Code Organization Issues

### Duplicate Code
```
lib/ui/widgets/floating_ai_chatbot.dart
lib/ui/pages/ai_business_expert_page.dart
└── Both define ChatMessage and ConversationProvider
    └── Should be in lib/models/ or lib/providers/
```

### Missing Error Boundaries
```
Most pages lack try-catch blocks around:
├── Network calls
├── Firebase operations
├── Navigation operations
└── User input processing
```

### Hardcoded Values Scattered Throughout
```
Colors, Sizes, Durations, Strings:
├── lib/ui/pages/*.dart (inline magic numbers)
├── lib/ui/widgets/*.dart (inline colors)
└── Should be in:
    ├── lib/ui/theme.dart (colors, text styles)
    ├── lib/config/constants.dart (sizes, durations)
    └── lib/l10n/ (strings for i18n)
```

## Testing Coverage Gaps

### Untested Critical Paths
1. **Authentication Flow**
   - Sign Up → Profile Creation → Main App
   - Sign In → Token Refresh → Main App
   - Password Reset → Email Verification

2. **Service Request Flow**
   - Browse Services → Select → Fill Form → Submit → Track
   - Document Upload → Status Check → Completion

3. **Payment Flow** (if implemented)
   - Service Selection → Payment → Confirmation → Receipt

4. **AI Chatbot Flow**
   - Open Chat → Conversation → Extract Requirements → Navigate to Results

### Missing Test Files
```
test/
├── widget_test.dart (default, may be outdated)
└── Missing:
    ├── unit/
    │   ├── services/
    │   ├── providers/
    │   └── models/
    ├── widget/
    │   └── All page widgets
    └── integration/
        └── Critical user flows
```

## Performance Concerns Map

### Heavy Operations
```
lib/ui/pages/
├── community_page.dart
│   └── Loads all posts at once (pagination needed)
├── services_page.dart
│   └── Loads all categories and services (lazy loading needed)
└── freezone_browser_page.dart
    └── Loads all freezones with images (pagination needed)
```

### Unnecessary Rebuilds
```
Stateful widgets that may rebuild too often:
├── main_nav.dart (entire navigation on tab switch)
├── floating_ai_chatbot.dart (animation triggers)
└── Various pages (lack of const constructors)
```

### Image Loading
```
Network images without caching:
├── services_page.dart (header image)
├── profile_page.dart (header image)
├── home_page.dart (gradient instead, good!)
└── User uploaded images (profile photos, posts)
    └── Need: cached_network_image package
```

## Accessibility Violations Map

### 🔴 Critical Accessibility Issues
1. **lib/main.dart:42-48**
   ```dart
   textScaler: const TextScaler.linear(1.0)
   // Blocks system text scaling
   // WCAG 2.1 Violation: 1.4.4 Resize text
   ```

2. **Color Contrast Issues**
   ```
   Multiple locations:
   ├── White text on light gradients
   ├── Purple text on white (may be too light)
   └── Gray text (may not meet 4.5:1 ratio)
   ```

3. **Touch Targets**
   ```
   Small interactive elements:
   ├── Tab bar icons (may be < 44x44)
   ├── Card action buttons
   └── List item actions
   ```

### Missing Accessibility Features
- [ ] Screen reader labels (Semantics widgets)
- [ ] Keyboard navigation support
- [ ] Focus management
- [ ] Skip links / navigation shortcuts
- [ ] Alt text for images
- [ ] ARIA-like roles for custom widgets

## Next Steps Priorities

### Week 1 (Blockers)
1. Create `.env` file with proper documentation
2. Add authentication gate to app
3. Fix service provider null checks
4. Remove/restrict admin page access
5. Fix text scaling issue

### Week 2 (Core Features)
1. Implement community post creation
2. Replace hardcoded dashboard data with real data
3. Add loading states to all async operations
4. Improve error handling across the app

### Week 3 (Polish & Security)
1. Complete edit profile functionality
2. Add offline mode support
3. Review and test Firebase security rules
4. Accessibility audit and fixes

### Week 4 (Testing & Launch Prep)
1. Write and run integration tests
2. Performance profiling and optimization
3. Final bug fixes
4. Documentation and deployment prep

---

## How to Use This Map

1. **For Developers:**
   - Navigate to specific file locations to fix issues
   - Use issue numbers from BUGS_QUICK_REFERENCE.md
   - Cross-reference with CODE_REVIEW_REPORT.md for details

2. **For QA/Testers:**
   - Follow the app structure to test each screen
   - Verify fixes against issue descriptions
   - Report new issues found

3. **For Project Managers:**
   - Track progress using issue counts
   - Prioritize based on severity levels
   - Estimate completion using weekly milestones

---

**Last Updated:** November 5, 2025  
**Issue Count:** 40+ identified  
**Files Reviewed:** 20+ core files  
**Test Coverage:** Insufficient (needs comprehensive test suite)
