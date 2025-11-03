# Beta Distribution Architecture

## Deployment Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    Developer Workstation                        │
│                                                                 │
│  ┌──────────────────┐      ┌──────────────────┐               │
│  │ iOS Deployment   │      │ Android Deploy   │               │
│  │                  │      │                  │               │
│  │ ./scripts/       │      │ ./scripts/       │               │
│  │ deploy-ios-      │      │ deploy-android-  │               │
│  │ beta.sh          │      │ beta.sh          │               │
│  └────────┬─────────┘      └────────┬─────────┘               │
│           │                         │                          │
│           ▼                         ▼                          │
│  ┌────────────────────────────────────────────┐               │
│  │         Fastlane (ios/Fastfile)            │               │
│  │         Fastlane (android/Fastfile)        │               │
│  │                                            │               │
│  │  • Increment build number                  │               │
│  │  • Build release binary (IPA/AAB)          │               │
│  │  • Upload to distribution platform         │               │
│  │  • Commit & tag version                    │               │
│  └────────────────────────────────────────────┘               │
└─────────────────────────────────────────────────────────────────┘
                             │
                             │
         ┌───────────────────┴───────────────────┐
         │                                       │
         ▼                                       ▼
┌─────────────────────┐              ┌─────────────────────┐
│  App Store Connect  │              │  Google Play        │
│  (TestFlight)       │              │  Console            │
│                     │              │                     │
│  ✓ Internal Testing │              │  ✓ Internal Testing │
│  ✓ External Testing │              │  ✓ Closed Beta      │
│  ✓ Ready for Review │              │  ✓ Open Beta        │
└─────────────────────┘              └─────────────────────┘
         │                                       │
         │                                       │
         ▼                                       ▼
┌─────────────────────┐              ┌─────────────────────┐
│   Beta Testers      │              │   Beta Testers      │
│   (iOS)             │              │   (Android)         │
│                     │              │                     │
│   TestFlight App    │              │   Play Store        │
└─────────────────────┘              └─────────────────────┘
```

## GitHub Actions CI/CD Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                       GitHub Repository                         │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Trigger Events:                                         │  │
│  │  • Manual: Workflow Dispatch (Actions tab)              │  │
│  │  • Auto: Git tag push (v*.*.*-beta)                     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              │                                  │
│                              ▼                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │     .github/workflows/deploy-beta.yml                    │  │
│  │                                                          │  │
│  │  ┌────────────────┐       ┌────────────────┐            │  │
│  │  │ deploy-ios Job │       │ deploy-android │            │  │
│  │  │                │       │      Job       │            │  │
│  │  │ • Setup Flutter│       │ • Setup Flutter│            │  │
│  │  │ • Setup Ruby   │       │ • Setup Ruby   │            │  │
│  │  │ • Install Gems │       │ • Install Gems │            │  │
│  │  │ • Code Signing │       │ • Keystore     │            │  │
│  │  │ • Run Fastlane │       │ • Run Fastlane │            │  │
│  │  └───────┬────────┘       └───────┬────────┘            │  │
│  └──────────┼────────────────────────┼─────────────────────┘  │
└─────────────┼────────────────────────┼─────────────────────────┘
              │                        │
              │                        │
    ┌─────────▼─────────┐    ┌─────────▼─────────┐
    │  GitHub Secrets   │    │  GitHub Secrets   │
    │  (iOS)            │    │  (Android)        │
    │                   │    │                   │
    │  • API Keys       │    │  • Keystore       │
    │  • Certificates   │    │  • Play API Key   │
    │  • Credentials    │    │  • Passwords      │
    └───────────────────┘    └───────────────────┘
              │                        │
              ▼                        ▼
    ┌─────────────────────┐  ┌─────────────────────┐
    │   TestFlight        │  │   Play Console      │
    └─────────────────────┘  └─────────────────────┘
```

## Version Management Flow

```
┌──────────────────────────────────────────────────────────────┐
│                    pubspec.yaml                              │
│                                                              │
│    version: 1.0.0+1                                          │
│             ↑     ↑                                          │
│             │     │                                          │
│         Version  Build                                       │
│          Name   Number                                       │
└──────────────────────────────────────────────────────────────┘
              │              │
              │              │
   ┌──────────▼──────┐  ┌───▼──────────────────────┐
   │   iOS Build     │  │   Android Build          │
   │                 │  │                          │
   │ Xcode project   │  │ Gradle/Kotlin script     │
   │ CFBundleShort   │  │ versionName: "1.0.0"     │
   │  VersionString  │  │ versionCode: 1           │
   │   = "1.0.0"     │  │                          │
   │                 │  │ Auto-incremented by      │
   │ CFBundleVersion │  │ Fastlane:                │
   │ = Auto-increment│  │ versionCode: 2, 3, 4...  │
   │   by agvtool    │  │                          │
   └─────────────────┘  └──────────────────────────┘
              │                      │
              │                      │
              ▼                      ▼
   ┌────────────────────────────────────────────┐
   │        Git Tags Created by Fastlane        │
   │                                            │
   │  ios-v1.0.0-123                            │
   │  android-v1.0.0-456                        │
   └────────────────────────────────────────────┘
```

## File Structure

```
WAZEET_APP_GPT/
├── .github/
│   ├── workflows/
│   │   └── deploy-beta.yml          # CI/CD automation
│   └── ISSUE_TEMPLATE/
│       └── bug_report.md            # Beta tester bug template
│
├── android/
│   ├── Fastfile                     # Android deployment lanes
│   ├── Gemfile                      # Ruby dependencies
│   ├── key.properties               # Keystore config (gitignored)
│   ├── play-store-credentials.json  # Service account (gitignored)
│   └── app/
│       └── upload-keystore.jks      # Signing key (gitignored)
│
├── ios/
│   ├── Fastfile                     # iOS deployment lanes
│   ├── Gemfile                      # Ruby dependencies
│   └── Runner.xcworkspace/          # Xcode project
│
├── scripts/
│   ├── deploy-ios-beta.sh           # One-command iOS deploy
│   ├── deploy-android-beta.sh       # One-command Android deploy
│   └── deploy-beta-all.sh           # Deploy both platforms
│
├── docs/
│   ├── BETA_DISTRIBUTION.md         # Complete setup guide
│   ├── TEST_PLAN_ALPHA.md           # Internal testing plan
│   └── TEST_PLAN_BETA.md            # External testing plan
│
├── integration_test/
│   └── app_launch_test.dart         # Basic smoke test
│
└── BETA_DEPLOY_QUICK_START.md       # Quick reference card
```

## Security Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Sensitive Files                        │
│                   (NEVER COMMITTED)                         │
│                                                             │
│  • .env                              (API keys)            │
│  • android/key.properties            (Passwords)           │
│  • android/app/upload-keystore.jks   (Signing key)         │
│  • android/play-store-credentials.json (Service account)   │
│  • ios/fastlane/match                (Certificates)        │
│  • **/*.p8                           (App Store key)       │
└─────────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    .gitignore                               │
│                                                             │
│  android/key.properties                                     │
│  android/app/upload-keystore.jks                            │
│  android/play-store-credentials.json                        │
│  ios/fastlane/report.xml                                    │
│  .env                                                       │
└─────────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              GitHub Repository Secrets                      │
│                (Encrypted at rest)                          │
│                                                             │
│  iOS: 8 secrets (API keys, certificates, passwords)        │
│  Android: 3 secrets (keystore, credentials, properties)    │
└─────────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              GitHub Actions Runner                          │
│            (Secrets injected as env vars)                   │
│                                                             │
│  • Secrets never logged                                     │
│  • Temp files cleaned after build                           │
│  • Artifacts uploaded securely                              │
└─────────────────────────────────────────────────────────────┘
```

## Success Metrics

### Alpha (Internal Testing)
- ✅ Crash-free rate ≥ 99%
- ✅ Zero P0/P1 bugs
- ✅ All critical paths tested on 3 device sizes
- ✅ Integration test passes

### Beta (External Testing)
- ✅ Crash-free sessions ≥ 99.5%
- ✅ System Usability Scale (SUS) ≥ 70
- ✅ Task completion rate ≥ 90%
- ✅ Zero P0/P1, P2s have workarounds

### Production Ready
- ✅ All Beta exit criteria met
- ✅ Performance benchmarks met
- ✅ Accessibility audit passed
- ✅ App Store/Play Store policies compliant
- ✅ Crash reporting and analytics configured
