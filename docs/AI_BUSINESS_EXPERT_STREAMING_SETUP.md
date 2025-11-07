# AI Business Expert - Streaming Setup Guide

This guide explains how to set up and configure the enhanced AI Business Expert feature with OpenAI streaming, tool calls, and persistence.

## Architecture Overview

### Components
1. **Firebase Cloud Function** (`aiBusinessChat`) - Handles OpenAI API calls with streaming
2. **Flutter Service** (`AIBusinessExpertServiceV2`) - Manages streaming connections and state
3. **UI** (`AIBusinessExpertPage`) - Real-time chat interface with recommendations
4. **Firestore** - Persists conversations and messages

### Features
- ✅ Real-time streaming responses (SSE)
- ✅ Tool calling for freezone recommendations and cost estimates
- ✅ Automatic retry with exponential backoff
- ✅ Circuit breaker for rate limiting
- ✅ Conversation persistence in Firestore
- ✅ Quick-reply chips for common queries
- ✅ Direct navigation to filtered freezone list

---

## Setup Instructions

### 1. Configure OpenAI API Key

The OpenAI API key should be stored in Firebase Functions configuration (NOT in the app code).

```bash
# Set the OpenAI API key
firebase functions:config:set openai.key="sk-your-openai-api-key-here"

# Verify configuration
firebase functions:config:get

# Deploy functions
cd functions
npm run build
firebase deploy --only functions:aiBusinessChat
```

### 2. Update Flutter Service URL

Edit `lib/services/ai_business_expert_service_v2.dart` and replace the function URL:

```dart
static const String _functionUrl =
    'https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/aiBusinessChat';
```

Replace `YOUR_PROJECT_ID` with your actual Firebase project ID.

You can find this URL after deploying:
```bash
firebase functions:list
```

### 3. Update Firestore Security Rules

Add rules to protect conversation data:

```
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Conversations - users can only access their own
    match /conversations/{conversationId} {
      allow read, write: if request.auth != null 
                         && request.auth.uid == resource.data.userId;
      
      match /messages/{messageId} {
        allow read, write: if request.auth != null 
                           && request.auth.uid == get(/databases/$(database)/documents/conversations/$(conversationId)).data.userId;
      }
    }
    
    // Freezones - read-only for all authenticated users
    match /freezones/{freezoneId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
```

Deploy rules:
```bash
firebase deploy --only firestore:rules
```

### 4. Install Dependencies

Ensure the following are in your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_core: ^2.24.0
  http: ^1.1.0
  flutter_riverpod: ^2.4.0
```

Functions dependencies (already in `functions/package.json`):
```json
{
  "dependencies": {
    "firebase-admin": "^12.0.0",
    "firebase-functions": "^5.0.0",
    "openai": "^4.20.0"
  }
}
```

### 5. Local Development

To test functions locally:

```bash
# Start Firebase emulators
cd functions
npm run serve

# Update service URL to local emulator
# In ai_business_expert_service_v2.dart:
static const String _functionUrl =
    'http://127.0.0.1:5001/YOUR_PROJECT_ID/us-central1/aiBusinessChat';
```

---

## Usage

### In Your App

Replace the old AI Business Expert page import:

```dart
// OLD
import 'package:wazeet/ui/pages/ai_business_expert_page.dart';

// NEW
import 'package:wazeet/ui/pages/ai_business_expert_page_v2.dart';
```

Update navigation:

```dart
// Navigate to AI Business Expert
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => AIBusinessExpertPage(),
  ),
);
```

### Accessing Recommendations

The service exposes a `ValueNotifier` for recommendations:

```dart
// Listen to recommendations
AIBusinessExpertServiceV2.recommendations.addListener(() {
  final recs = AIBusinessExpertServiceV2.recommendations.value;
  print('Got ${recs.length} recommendations');
});

// Clear recommendations
AIBusinessExpertServiceV2.clearRecommendations();
```

---

## Tool Call Examples

### 1. Recommend Freezones

**User Input:** "I want to start an e-commerce business with 2 visas, low budget"

**AI calls:**
```json
{
  "tool": "recommend_freezones",
  "arguments": {
    "activity": "e-commerce",
    "visas": 2,
    "budget": "low"
  }
}
```

**Function returns:**
```json
{
  "recommendations": [
    {
      "id": "rakez",
      "name": "RAKEZ",
      "abbreviation": "RAKEZ",
      "emirate": "Ras Al Khaimah",
      "reason": "Cost-effective; Fast setup"
    },
    {
      "id": "ajman_free_zone",
      "name": "Ajman Free Zone",
      "abbreviation": "AFZ",
      "emirate": "Ajman",
      "reason": "Low cost; Flexible packages"
    }
  ]
}
```

### 2. Estimate Cost

**User Input:** "What's the cost for RAKEZ with 2 visas?"

**AI calls:**
```json
{
  "tool": "estimate_cost",
  "arguments": {
    "freezone_id": "rakez",
    "visas": 2,
    "tenure": 1
  }
}
```

**Function returns:**
```json
{
  "freezone": "RAKEZ",
  "costs": {
    "setup": "AED 15,000",
    "visas": "AED 6,000 (2 visas)",
    "annualRenewal": "AED 10,500",
    "totalFirstYear": "AED 21,000"
  },
  "inclusions": ["Trade license", "Flexi-desk", "Visa processing"],
  "disclaimer": "These are rough estimates. Actual costs vary."
}
```

---

## Error Handling

### Rate Limiting
- Client retries up to 3 times with exponential backoff (800ms, 1600ms, 3200ms)
- After 3 consecutive 429 errors, circuit breaker activates for 1 minute
- User sees: "Too many requests. Please wait a moment."

### Timeouts
- 15-second timeout per request
- Automatic retry on timeout (up to 3 attempts)
- User sees: "Connection timeout. Please check your internet."

### Auth Errors
- If Firebase token is invalid: "Authentication failed. Please sign in again."
- No retry on auth errors

### Server Errors
- Any 5xx error triggers retry
- After max retries: "An error occurred. Please try again."

---

## Monitoring & Logging

### Cloud Functions Logs

```bash
# View real-time logs
firebase functions:log --only aiBusinessChat

# View specific time range
firebase functions:log --only aiBusinessChat --since 1h
```

### Analytics Events (Optional)

Add to your Firebase Analytics:

```dart
FirebaseAnalytics.instance.logEvent(
  name: 'ai_chat_completed',
  parameters: {
    'message_count': messages.length,
    'had_recommendations': recommendations.isNotEmpty,
  },
);
```

---

## Testing

### Manual Test Cases

1. **Basic Flow**
   - User: "e-commerce, 1 visa, low budget"
   - Expected: AI streams response, calls `recommend_freezones`, shows 3 options, "View" button appears

2. **Cost Inquiry**
   - User: "How much is RAKEZ?"
   - Expected: AI calls `estimate_cost`, shows breakdown

3. **Error Recovery**
   - Disable network mid-stream
   - Expected: Error message, chat remains stable

4. **Conversation Restore**
   - Close and reopen app
   - Expected: Previous conversation loads from Firestore

### Unit Tests

```dart
// test/ai_business_expert_service_v2_test.dart
test('Stream handles content chunks', () async {
  final events = <AIStreamEvent>[];
  await for (final event in service.sendMessageStream(...)) {
    events.add(event);
  }
  expect(events.any((e) => e.isContent), true);
  expect(events.any((e) => e.isDone), true);
});
```

---

## Troubleshooting

### "Service configuration error"
- OpenAI key not set. Run: `firebase functions:config:set openai.key="..."`

### "Unauthorized: Invalid token"
- User not signed in. Check `FirebaseAuth.instance.currentUser`

### Streaming stops mid-response
- Check function timeout (currently 60s)
- Verify SSE parsing in `ai_business_expert_service_v2.dart`

### Recommendations not showing
- Check Firestore `freezones` collection exists
- Verify freezone IDs match normalized format (e.g., `rakez`, not `RAKEZ` or `RAK Free Trade Zone`)

### High OpenAI costs
- Review `max_tokens` in function (currently 1000)
- Implement caching for common queries
- Consider switching to `gpt-3.5-turbo` for lower costs

---

## Production Checklist

- [ ] OpenAI API key configured in Firebase Functions
- [ ] Function URL updated in `ai_business_expert_service_v2.dart`
- [ ] Firestore security rules deployed
- [ ] Freezones collection populated in Firestore
- [ ] Error tracking enabled (Crashlytics/Sentry)
- [ ] Rate limiting tested with multiple users
- [ ] Conversation restore verified
- [ ] "View recommendations" navigation tested
- [ ] Cost estimates validated against actual freezone pricing
- [ ] Legal disclaimers reviewed

---

## Future Enhancements

- [ ] Add support for follow-up questions after recommendations
- [ ] Implement conversation summarization for very long chats
- [ ] Add voice input/output
- [ ] Multi-language support (Arabic)
- [ ] Export conversation as PDF
- [ ] Admin dashboard to view popular queries
- [ ] A/B test different system prompts
- [ ] Implement semantic search for better freezone matching

---

## Support

For issues or questions:
1. Check Firebase Functions logs: `firebase functions:log`
2. Review Flutter debug logs: Look for `[AI]` prefixed messages
3. Contact: support@wazeet.com
