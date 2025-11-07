# iOS Build Report

- Build date/time (UTC): 2025-11-03 19:03:08 UTC
- Export method used: Ad Hoc (failed: no valid signing certificates/provisioning profiles found)

## Artifacts
- IPA: /Users/amanshah/WAZEET_APP_GPT/build/ios/ipa/Runner.ipa
- App bundle: /Users/amanshah/WAZEET_APP_GPT/build/ios/iphoneos/Runner.app
- Latest archive: ~/Library/Developer/Xcode/Archives/<YYYY-MM-DD>/Runner <timestamp>.xcarchive

## IPA Integrity
- IPA Size: N/A (IPA not created)
- IPA SHA256: N/A (IPA not created)

## Notes
- The build failed during code signing. To resolve:
  - Open `ios/Runner.xcworkspace` in Xcode.
  - In the `Runner` target, Signing & Capabilities, select your Apple Development Team.
  - Ensure the Bundle Identifier is unique and matches your provisioning profile(s).
  - For App Store export, ensure a valid Distribution certificate and App Store provisioning profile exist.
  - For Ad Hoc export, ensure an Ad Hoc profile including your device UDID exists.
  - After configuring, re-run:
    - `flutter build ipa --release --export-method app-store`
    - or fallback: `flutter build ipa --release --export-method ad-hoc`
