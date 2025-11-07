# 🚀 Pre-Deployment Checklist

Use this checklist before deploying the AI Business Expert streaming feature to production.

---

## 📋 Configuration

### Firebase Functions
- [ ] OpenAI API key obtained from https://platform.openai.com/api-keys
- [ ] API key set in Firebase config:
  ```bash
  firebase functions:config:set openai.key="sk-proj-..."
  firebase functions:config:get  # Verify it's set
  ```
- [ ] Firebase project ID identified (check `.firebaserc` or Firebase Console)
- [ ] Billing enabled on Firebase project (required for Functions)
- [ ] OpenAI billing enabled (add payment method)

### Flutter App
- [ ] Service URL updated in `lib/services/ai_business_expert_service_v2.dart`:
  ```dart
  static const String _functionUrl =
      'https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/aiBusinessChat';
  ```
- [ ] Old OpenAI API key removed from `lib/config/app_config.dart` (if exists)
- [ ] No API keys in version control (check git history)

### Firestore
- [ ] `freezones` collection populated with data
- [ ] Freezone documents have required fields:
  - `name` (string)
  - `abbreviation` (string)
  - `industries` (array)
  - `costs` (object)
  - `key_advantages` (array)
  - `emirate` (string)
- [ ] Document IDs match normalized format (e.g., `rakez`, `ajman_free_zone`)

---

## 🏗️ Build & Deploy

### TypeScript Compilation
- [ ] Functions build without errors:
  ```bash
  cd functions
  npm run build
  ```
- [ ] No lint errors:
  ```bash
  npm run lint
  ```

### Function Deployment
- [ ] Deploy function:
  ```bash
  firebase deploy --only functions:aiBusinessChat
  ```
- [ ] Verify deployment successful (check console output)
- [ ] Get deployed URL:
  ```bash
  firebase functions:list
  ```
- [ ] Test function with curl (replace TOKEN and URL):
  ```bash
  curl -X POST \
    -H "Authorization: Bearer YOUR_FIREBASE_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"messages":[{"role":"user","content":"Hello"}],"userId":"test"}' \
    https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/aiBusinessChat
  ```

### Security Rules
- [ ] Firestore rules updated:
  ```bash
  firebase deploy --only firestore:rules
  ```
- [ ] Rules include `/conversations/` collection protection
- [ ] Test rules in Firebase Console (Rules Playground)

### Flutter Build
- [ ] No compilation errors:
  ```bash
  flutter clean
  flutter pub get
  flutter build apk --release  # Android
  flutter build ios --release  # iOS
  ```
- [ ] No lint warnings on new files:
  ```bash
  flutter analyze lib/services/ai_business_expert_service_v2.dart
  flutter analyze lib/ui/pages/ai_business_expert_page_v2.dart
  ```

---

## 🧪 Testing

### Manual Tests
- [ ] **Test 1: Basic Chat**
  - Open AI Business Expert page
  - Send: "e-commerce, 1 visa, low budget"
  - Expected: Streaming response appears word-by-word
  - Expected: "View" button appears
  - Expected: Recommendations count badge shows

- [ ] **Test 2: Tool Calling**
  - Continue conversation
  - Expected: AI calls `recommend_freezones` tool
  - Expected: 2-3 freezone names appear in response
  - Expected: Each has brief reasoning

- [ ] **Test 3: Cost Inquiry**
  - Ask: "How much is RAKEZ?"
  - Expected: AI calls `estimate_cost` tool
  - Expected: Cost breakdown appears (setup, visas, total)

- [ ] **Test 4: View Recommendations**
  - Tap "View" button
  - Expected: Navigate to FreezoneBrowserPage
  - Expected: Filtered list shows recommended freezones
  - Expected: "Recommendations mode" badge visible

- [ ] **Test 5: Quick Replies**
  - Tap "E-commerce" chip
  - Expected: Message sent immediately
  - Expected: AI responds with relevant questions

- [ ] **Test 6: Error Handling**
  - Turn off WiFi mid-conversation
  - Expected: Friendly error message
  - Expected: Chat remains stable (no crash)
  - Expected: Can retry after reconnecting

- [ ] **Test 7: Conversation Persistence**
  - Send a few messages
  - Close app completely
  - Reopen app
  - Navigate to AI Business Expert
  - Expected: Previous messages restored

- [ ] **Test 8: New Conversation**
  - Tap "Start Over" (refresh icon)
  - Confirm dialog
  - Expected: Chat clears
  - Expected: Greeting message appears
  - Expected: Old conversation archived in Firestore

### Edge Cases
- [ ] **Long response:** Ask complex question → verify full response arrives
- [ ] **Rate limiting:** Send 10 messages rapidly → verify circuit breaker activates gracefully
- [ ] **Invalid freezone:** Ask about "Mars Free Zone" → verify AI handles gracefully
- [ ] **Offline start:** Open app with no internet → verify error message, no crash
- [ ] **Sign out:** Sign out mid-chat → verify appropriate error handling

---

## 📊 Monitoring

### Firebase Console
- [ ] Functions dashboard shows successful invocations
- [ ] No excessive errors in logs:
  ```bash
  firebase functions:log --only aiBusinessChat --since 1h
  ```
- [ ] Firestore shows new documents in `/conversations/`
- [ ] No unexpected billing spikes (check Billing section)

### OpenAI Dashboard
- [ ] Usage appears in https://platform.openai.com/usage
- [ ] Token usage within expected range (~5K tokens per conversation)
- [ ] No rate limit errors (429)
- [ ] Cost aligns with estimates (~$0.003 per conversation)

### App Analytics (Optional)
- [ ] Firebase Analytics events firing:
  - `ai_chat_opened`
  - `ai_chat_message_sent`
  - `ai_recommendations_viewed`
- [ ] Crashlytics shows no new crashes related to AI chat

---

## 🔒 Security

### API Keys
- [ ] OpenAI key NOT in Flutter app code
- [ ] OpenAI key NOT in version control
- [ ] Firebase Functions config encrypted (automatic)
- [ ] Old API key rotated (if previously exposed)

### Authentication
- [ ] Function requires Firebase Auth token
- [ ] Unauthenticated requests return 401
- [ ] User can only access own conversations
- [ ] Test with different user accounts

### Data Privacy
- [ ] Logs don't contain PII (check Firebase Functions logs)
- [ ] Conversation data only accessible to owner
- [ ] No sensitive data in error messages
- [ ] Firestore rules tested in Rules Playground

---

## 📱 Platform-Specific

### Android
- [ ] Min SDK version supports HTTP client (21+)
- [ ] ProGuard rules don't strip HTTP classes
- [ ] Release build tested on real device
- [ ] No network permission issues

### iOS
- [ ] Info.plist includes network usage description
- [ ] Release build tested on real device
- [ ] No certificate issues
- [ ] App Transport Security allows HTTPS

### Web (if applicable)
- [ ] CORS headers work with deployed function
- [ ] SSE supported in browser
- [ ] No mixed content warnings

---

## 📝 Documentation

- [ ] README updated with new feature
- [ ] Inline code comments added
- [ ] Setup guide accessible to team
- [ ] API documentation for function (if applicable)

---

## 🎯 Performance

- [ ] First response < 5s (from "Send" to first word)
- [ ] Full conversation < 30s (5 messages each side)
- [ ] App remains responsive during streaming
- [ ] No memory leaks (test with long conversations)
- [ ] UI updates smooth (60 FPS)

---

## 🚨 Rollback Plan

- [ ] Git tag created for current version:
  ```bash
  git tag -a v1.0.0-pre-ai-streaming -m "Before AI streaming"
  git push --tags
  ```
- [ ] Rollback steps documented
- [ ] Team knows how to revert to old version
- [ ] Old function can coexist with new one (different name)

---

## 👥 Team Readiness

- [ ] Team trained on new feature
- [ ] Support team knows how to troubleshoot
- [ ] QA team has test plan
- [ ] Product team reviewed UX
- [ ] Marketing materials prepared (if needed)

---

## 🎉 Launch

### Pre-Launch
- [ ] All checklist items above completed
- [ ] Stakeholders notified
- [ ] Announcement drafted (if public)
- [ ] Beta testers identified (if soft launch)

### During Launch
- [ ] Monitor Firebase Functions logs in real-time
- [ ] Watch OpenAI dashboard for usage spikes
- [ ] Check Crashlytics for new issues
- [ ] Respond to user feedback quickly

### Post-Launch (First 24h)
- [ ] Review function invocation count
- [ ] Check average response time
- [ ] Analyze user engagement (conversations started)
- [ ] Review support tickets for AI-related issues
- [ ] Verify cost aligns with estimates

---

## 📊 Success Metrics

Define success criteria (check after 1 week):
- [ ] Conversation completion rate > 70%
- [ ] Average response time < 5s
- [ ] Error rate < 5%
- [ ] User satisfaction (if surveyed) > 4/5
- [ ] Cost per conversation < $0.01
- [ ] No security incidents
- [ ] No critical bugs

---

## 🐛 Known Issues

Document any known issues before launch:
- [ ] None! ✅

If issues found:
- [ ] Issue 1: _____________________
  - Workaround: _____________________
  - Fix ETA: _____________________

---

## ✅ Final Approval

- [ ] Developer: Code reviewed and tested
- [ ] QA: All tests passed
- [ ] Product: UX approved
- [ ] Security: No vulnerabilities found
- [ ] DevOps: Infrastructure ready
- [ ] Legal: Privacy policy updated (if needed)

---

**Deployment Date:** _____________________  
**Deployed By:** _____________________  
**Notes:** _____________________

---

🎉 **Ready for production!** Good luck with the launch! 🚀

**Remember:** Monitor closely for first 24 hours. Keep Firebase Functions and OpenAI dashboards open. Have rollback plan ready (but you won't need it! 😉)
