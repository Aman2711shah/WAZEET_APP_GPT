# Migration Guide: Old AI Business Expert → New Streaming Version

## Overview

This guide helps you migrate from the original AI Business Expert (direct OpenAI calls from Flutter) to the new streaming version (Firebase Functions + SSE).

## Why Migrate?

### Old Version Issues
- ❌ API key exposed in Flutter app (security risk)
- ❌ Full response wait (15-30s, no feedback)
- ❌ No retry/error handling
- ❌ Limited to client-side logic
- ❌ Can't use tool calling/function-calling

### New Version Benefits
- ✅ API key secured in Firebase Functions
- ✅ Real-time streaming (first token in <1s)
- ✅ Robust retry + circuit breaker
- ✅ Tool calling for freezone recommendations
- ✅ Better error messages and UX
- ✅ Conversation persistence

## Migration Steps

### Step 1: Backup Current Implementation

```bash
# Create backup branch
git checkout -b backup/ai-expert-old
git add .
git commit -m "Backup: old AI Business Expert implementation"
git checkout main
```

### Step 2: Deploy Firebase Function

```bash
# Set OpenAI API key in Firebase (REMOVE from Flutter app config!)
firebase functions:config:set openai.key="sk-YOUR_KEY_HERE"

# Build and deploy
cd functions
npm run build
firebase deploy --only functions:aiBusinessChat

# Note the deployed URL
firebase functions:list
# Look for: https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/aiBusinessChat
```

### Step 3: Update Service Import

**Before:**
```dart
// Old import
import 'package:wazeet/services/ai_business_expert_service.dart';

// Old usage
final response = await AIBusinessExpertService.sendMessage(
  userMessage: text,
  conversationHistory: history,
);
```

**After:**
```dart
// New import
import 'package:wazeet/services/ai_business_expert_service_v2.dart';

// New usage (streaming)
await for (final event in AIBusinessExpertServiceV2.sendMessageStream(
  userMessage: text,
  conversationHistory: history,
)) {
  if (event.isContent) {
    // Append streaming content
    streamingContent += event.content ?? '';
  } else if (event.isDone) {
    // Complete!
    break;
  }
}
```

### Step 4: Update Page Import

**Before:**
```dart
// Old page
import 'package:wazeet/ui/pages/ai_business_expert_page.dart';

Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => AIBusinessExpertPage()),
);
```

**After:**
```dart
// New page (with _v2)
import 'package:wazeet/ui/pages/ai_business_expert_page_v2.dart';

Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const AIBusinessExpertPage()),
);
```

### Step 5: Update Floating Chatbot (Optional)

If using the floating widget:

**Before:**
```dart
import 'package:wazeet/ui/widgets/floating_ai_chatbot.dart';

// In your Stack
const FloatingAIChatbot(),
```

**After:**
```dart
import 'package:wazeet/ui/widgets/floating_ai_chatbot_v2.dart';

// In your Stack
const FloatingAIChatbotV2(),
```

### Step 6: Remove API Key from Flutter

**CRITICAL SECURITY STEP:**

1. Remove OpenAI key from `lib/config/app_config.dart` or wherever it's stored
2. Remove any `OPENAI_API_KEY` from environment variables
3. Verify key is NOT in version control history

```bash
# Check git history for leaked keys
git log -p --all -S 'sk-' | grep 'sk-'

# If found, consider rotating your OpenAI key immediately!
```

### Step 7: Update Firestore Collection Names (if needed)

The new version uses:
- `/conversations/{conversationId}` (was: `/ai_conversations/{conversationId}`)

**Option A: Migrate old data**
```dart
// One-time migration script
Future<void> migrateConversations() async {
  final oldSnap = await FirebaseFirestore.instance
      .collection('ai_conversations')
      .get();
  
  for (final doc in oldSnap.docs) {
    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(doc.id)
        .set(doc.data());
  }
}
```

**Option B: Start fresh**
- Just deploy new version
- Old conversations remain in `ai_conversations` (can delete later)

### Step 8: Test Migration

Run these tests:

1. **Basic Chat**
   ```
   User: "e-commerce, 1 visa, low budget"
   Expected: Streaming response + recommendations
   ```

2. **Conversation Restore**
   ```
   - Send a message
   - Close app
   - Reopen app
   - Expected: Message history restored
   ```

3. **View Recommendations**
   ```
   - Get recommendations
   - Tap "View" button
   - Expected: Navigate to FreezoneBrowserPage with filters
   ```

4. **Error Handling**
   ```
   - Disable WiFi mid-stream
   - Expected: Friendly error message
   ```

### Step 9: Update Firestore Rules

Deploy new rules that support the `/conversations/` collection:

```bash
firebase deploy --only firestore:rules
```

### Step 10: Monitor After Deployment

```bash
# Watch function logs
firebase functions:log --only aiBusinessChat --follow

# Check for errors in first hour
firebase functions:log --only aiBusinessChat --since 1h | grep ERROR
```

## Side-by-Side Comparison

| Feature | Old Version | New Version |
|---------|-------------|-------------|
| **API Key** | In Flutter app | In Firebase Functions ✅ |
| **Response Time** | 15-30s wait | <1s first token ✅ |
| **Streaming** | ❌ No | ✅ Yes (SSE) |
| **Tool Calling** | ❌ No | ✅ Yes (3 tools) |
| **Retry Logic** | ❌ No | ✅ 3 retries + backoff |
| **Circuit Breaker** | ❌ No | ✅ Yes (rate limit handling) |
| **Persistence** | ✅ Yes (Firestore) | ✅ Yes (improved) |
| **Cost** | Same | Same (gpt-4o-mini) |
| **Security** | ⚠️ Key exposed | ✅ Key secured |

## Rollback Plan (If Issues)

If you encounter issues:

```bash
# 1. Revert to backup branch
git checkout backup/ai-expert-old

# 2. Redeploy old app
flutter build apk # or ios
# Upload to store

# 3. Keep new function (doesn't hurt)
# Just revert Flutter code

# 4. Fix issues and retry migration
```

## Common Migration Issues

### Issue 1: "Service configuration error"
**Cause:** OpenAI key not set in Firebase Functions
**Fix:**
```bash
firebase functions:config:set openai.key="sk-..."
firebase deploy --only functions
```

### Issue 2: "Unauthorized" error
**Cause:** Firebase Auth token not sent
**Fix:** Check user is signed in before calling service

### Issue 3: Streaming doesn't work
**Cause:** CORS or SSE parsing issues
**Fix:** 
- Check function CORS headers (already set in `aiBusinessChat.ts`)
- Verify `Accept: text/event-stream` header in service
- Test with curl: `curl -H "Authorization: Bearer TOKEN" URL`

### Issue 4: Old conversations not showing
**Cause:** Collection name changed
**Fix:** Run migration script (see Step 7) or start fresh

### Issue 5: Recommendations not clickable
**Cause:** Navigation not wired
**Fix:** Verify `FreezoneBrowserPage` accepts `prefilledRecommendations` param

## Performance Comparison

### Before Migration
```
User sends message
  ↓ 15-30s (no feedback)
Full response appears
```

### After Migration
```
User sends message
  ↓ <1s
First words appear (streaming)
  ↓ 2-4s
Full response complete (with tool calls)
  ↓ immediate
"View" button appears
```

## Cost Impact

**No increase!** Both versions use gpt-4o-mini.

- Before: Client → OpenAI
- After: Client → Firebase Function → OpenAI

Firebase Function overhead: ~$0 (within free tier for most apps)

## Security Improvements

### Before
```
Flutter App (debug.apk)
  └─ lib/config/app_config.dart
      └─ openAiApiKey = "sk-EXPOSED" ⚠️
```
Anyone can decompile APK and extract key!

### After
```
Flutter App (release.apk)
  └─ No API key ✅

Firebase Functions
  └─ Environment Config (encrypted)
      └─ openai.key = "sk-SECURE" ✅
```
Key never leaves server!

## Timeline

Estimated migration time:
- **Small app** (1-2 screens): 1-2 hours
- **Medium app** (5-10 screens): 2-4 hours
- **Large app** (20+ screens): 4-8 hours

Most time spent on testing, not coding.

## Post-Migration Checklist

- [ ] Old API key removed from Flutter code
- [ ] New API key set in Firebase Functions config
- [ ] Function deployed and tested
- [ ] Firestore rules updated
- [ ] All imports updated (service, page, widget)
- [ ] Floating chatbot replaced (if used)
- [ ] Manual testing completed (all 4 test cases)
- [ ] Error handling verified
- [ ] Conversation persistence verified
- [ ] View recommendations navigation verified
- [ ] Logs monitored for first hour
- [ ] Old API key rotated (security best practice)

## Support

Questions during migration?
1. Check `docs/AI_BUSINESS_EXPERT_STREAMING_SETUP.md`
2. Check `AI_INTEGRATION_QUICK_START.md`
3. Firebase logs: `firebase functions:log`
4. Flutter debug logs: Look for `[AI]` prefix

Happy migrating! 🚀
