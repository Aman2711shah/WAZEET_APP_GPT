# WAZEET Alpha Test Plan

## Purpose
Internal, developer-and-stakeholder-only testing to harden core navigation, authentication, and critical user journeys before any external exposure.

## Scope (in-scope for Alpha)
- App startup and navigation (MainNav, tab switching)
- Auth flows (sign-in/up if enabled, or stubs)
- Services discovery basics (list, details)
- Community tab surface & navigation
- Applications/Track tab presence and basic flows
- Profile basic rendering and settings toggles
- Network error states and retry affordances

Out-of-scope: payments in production mode, performance benchmarking, full accessibility audit (smoke only), deep analytics.

## Entry Criteria
- Repo builds locally on macOS, iOS Simulator, Android Emulator, and Web (Chrome)
- Unit tests pass; analyzer shows no errors
- Feature flags/config for non-ready features default OFF

## Exit Criteria
- No P0/P1 defects open; P2s triaged with owners
- All critical paths pass on 3 device classes (small/mid/large)
- Crash-free rate ≥ 99% in internal runs (if Crashlytics enabled)
- Smoke integration test green (app launches and renders main nav)

## Test Environments
- iOS: iPhone 13, 15 Pro (iOS 17+)
- Android: Pixel 5/7 emulators (API 30–35)
- Web: Chrome latest

## Test Data
- Test accounts (document in 1Password or secure vault)
- Sample events, freezones assets already in repo under `assets/`

## Test Scenarios
- Launch app: no crash, sees Community tab label
- Switch tabs: Home ↔ Services ↔ Community ↔ Track ↔ More
- Deep link (if available) opens expected screen
- Offline/airplane mode: show error banners and retry works
- First-run permissions prompts (if any) are explained and dismissible
- Profile: toggle theme (if supported), verify persistence

## Reporting & Triage
- File issues via `Bug report` template in GitHub
- Label: `alpha`, component (e.g., `ui`, `auth`, `community`), severity (P0–P3)
- Daily standup: review new bugs, assign owners, update status

## Acceptance Checklist
- [ ] App boots without errors on all platforms
- [ ] Bottom nav is usable; Community label visible
- [ ] No blocking crashes during 30-minute exploratory session
- [ ] Unit tests green; analyzer clean
- [ ] Integration test `app_launch_test.dart` green

---

## Test Session Notes
Use this section to capture exploratory notes, screenshots, and quick reproduction steps.