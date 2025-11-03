# Beta Deployment - Quick Reference

## 🚀 One-Command Deployments

### Deploy iOS Beta to TestFlight
```bash
./scripts/deploy-ios-beta.sh
```

### Deploy Android Beta to Play Console
```bash
./scripts/deploy-android-beta.sh
```

### Deploy Both Platforms
```bash
./scripts/deploy-beta-all.sh
```

---

## ⚙️ First-Time Setup Checklist

### iOS Setup (15 min)
- [ ] Install Fastlane: `gem install fastlane`
- [ ] Navigate to ios: `cd ios && bundle install`
- [ ] Get App Store Connect API Key (Key ID, Issuer ID, .p8 file)
- [ ] Setup Match: `fastlane match init` then `fastlane match appstore`
- [ ] Configure Xcode signing (Runner.xcworkspace → Team)
- [ ] Test: `./scripts/deploy-ios-beta.sh`

### Android Setup (15 min)
- [ ] Install Fastlane: `gem install fastlane`
- [ ] Navigate to android: `cd android && bundle install`
- [ ] Create upload keystore: `keytool -genkey -v -keystore upload-keystore.jks ...`
- [ ] Create `android/key.properties` with keystore details
- [ ] Update `android/app/build.gradle.kts` with signing config
- [ ] Create Play Console service account and download JSON
- [ ] Test: `./scripts/deploy-android-beta.sh`

### GitHub Actions (Optional - 30 min)
- [ ] Add iOS secrets to GitHub (8 secrets - see docs)
- [ ] Add Android secrets to GitHub (3 secrets - see docs)
- [ ] Test: Push tag `v1.0.0-beta` or use manual workflow trigger

---

## 📚 Documentation

- Full setup guide: `docs/BETA_DISTRIBUTION.md`
- Test plans: `docs/TEST_PLAN_ALPHA.md` and `docs/TEST_PLAN_BETA.md`
- Bug reports: `.github/ISSUE_TEMPLATE/bug_report.md`

---

## 🔍 What Happens When You Deploy

### iOS
1. ✅ Checks git is clean
2. 🔢 Auto-increments build number
3. 🏗️ Builds release IPA
4. ⬆️ Uploads to TestFlight (App Store Connect)
5. 🏷️ Commits version bump and creates git tag
6. 📤 Pushes to remote repository

### Android
1. ✅ Checks git is clean
2. 🔢 Auto-increments version code in `pubspec.yaml`
3. 🏗️ Builds release AAB (App Bundle)
4. ⬆️ Uploads to Play Console Internal Testing track
5. 🏷️ Commits version bump and creates git tag
6. 📤 Pushes to remote repository

---

## 🆘 Common Issues

### iOS
- **Code signing error**: Run `fastlane match appstore` to sync certificates
- **No team found**: Open Xcode, select team in Runner target settings
- **API key error**: Check secrets are set correctly

### Android
- **Keystore not found**: Verify path in `key.properties`
- **Play API error**: Check service account has Release Manager role
- **Version exists**: Increment version manually in `pubspec.yaml`

---

## 💡 Pro Tips

- Always commit/push changes before deploying
- Monitor builds in App Store Connect / Play Console after upload
- Use `fastlane build` to test builds without uploading
- Check logs: `ios/fastlane/report.xml` and terminal output
- Set up GitHub Actions for hands-free deployments on git tags

---

## 🎯 Distribution Flow

```
Local Deploy → Internal Testing → External Beta → Production

iOS:     TestFlight Internal → TestFlight External → App Store
Android: Internal Track → Closed Beta Track → Open Beta → Production
```

---

**Need help?** See full documentation in `docs/BETA_DISTRIBUTION.md`
