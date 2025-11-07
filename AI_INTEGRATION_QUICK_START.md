# Quick Integration Guide - AI Business Expert Streaming

## Step 1: Deploy Firebase Function

```bash
# Navigate to functions directory
cd functions

# Set the OpenAI API key (ALREADY DONE ✅)
firebase functions:config:set openai.key="sk-your-openai-api-key-here"

# Verify configuration
firebase functions:config:get

# Deploy functions (ALREADY DONE ✅)
cd functions
npm run build
firebase deploy --only functions:aiBusinessChat

# Your deployed URL:
# https://us-central1-business-setup-application.cloudfunctions.net/aiBusinessChat

# Get the deployed URL
firebase functions:list
# Look for: aiBusinessChat (https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/aiBusinessChat)
```

### 2. Update Service URL ✅ DONE

Edit `lib/services/ai_business_expert_service_v2.dart`:

```dart
static const String _functionUrl =
    'https://us-central1-business-setup-application.cloudfunctions.net/aiBusinessChat';
```

✅ Already updated with your Firebase project ID: `business-setup-application`

## Step 3: Update Navigation

Replace old AI Business Expert imports with new versions:

### Option A: Full Page (Recommended)

```dart
// In your navigation (e.g., main_nav.dart or wherever you open AI chat)
import 'package:wazeet/ui/pages/ai_business_expert_page_v2.dart';

// When user taps "AI Business Expert"
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const AIBusinessExpertPage(),
  ),
);
```

### Option B: Floating Widget

```dart
// In your main scaffold (e.g., main_nav.dart)
import 'package:wazeet/ui/widgets/floating_ai_chatbot_v2.dart';

// Add to Stack overlay
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // Your main content
        IndexedStack(...),
        
        // Floating AI button
        const FloatingAIChatbotV2(),
      ],
    ),
  );
}
```

## Step 4: Deploy Firestore Rules

```bash
firebase deploy --only firestore:rules
```

Make sure your `firestore.rules` includes:

```
match /conversations/{conversationId} {
  allow read, write: if request.auth != null 
                     && request.auth.uid == resource.data.userId;
  
  match /messages/{messageId} {
    allow read, write: if request.auth != null;
  }
}
```

## Step 5: Test

1. Run the app: `flutter run`
2. Open AI Business Expert
3. Type: "e-commerce, 1 visa, low budget"
4. Watch for:
   - ✅ Streaming response (text appears in real-time)
   - ✅ "View" button appears after recommendations
   - ✅ Clicking "View" opens freezone browser with filtered results
   - ✅ Quick-reply chips work
   - ✅ Close and reopen app → conversation restores

## Troubleshooting

### "Service configuration error"
```bash
firebase functions:config:set openai.key="sk-..."
firebase deploy --only functions
```

### URL not found (404)
- Check function is deployed: `firebase functions:list`
- Verify URL in service file matches deployed URL
- Check Firebase region (default: us-central1)

### Streaming doesn't work
- Check CORS headers in function
- Verify `Accept: text/event-stream` header
- Test with Postman/curl first

### No recommendations appear
- Check Firestore `freezones` collection exists
- Verify freezone docs have required fields: `name`, `industries`, `costs`
- Check browser console for errors

## Cost Estimation

- OpenAI gpt-4o-mini: ~$0.15 per 1M input tokens, ~$0.60 per 1M output tokens
- Average conversation (10 messages): ~5K tokens = ~$0.003
- With tool calls: ~10K tokens = ~$0.006
- Expected monthly cost for 1000 users: ~$6-20 (depends on usage)

## Next Steps

- [ ] Monitor Firebase Functions logs for errors
- [ ] Set up billing alerts in Firebase Console
- [ ] A/B test different system prompts
- [ ] Add analytics events to track user interactions
- [ ] Implement caching for common queries

## Support

Questions? Check:
1. `docs/AI_BUSINESS_EXPERT_STREAMING_SETUP.md` (full documentation)
2. Firebase Functions logs: `firebase functions:log --only aiBusinessChat`
3. Flutter debug logs: Look for `[AI]` or `🎯` prefixed messages
