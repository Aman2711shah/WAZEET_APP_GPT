# AI Chat & New Actions Setup Guide

## Overview
This guide explains how to set up the new bottom sheet actions in the WAZEET Flutter app, including the AI chat functionality powered by OpenAI.

## What's New

The "Copy details" action has been replaced with four new actions:

1. **Send Email** - Opens email client or fallback form
2. **Share Freezones & Mention** - Multi-select freezones and @mentions with preview
3. **Call Now** - Direct dial to +971559986386
4. **Ask with AI (ChatGPT)** - Full-screen AI chat assistant

## Files Created

### Services
- `lib/services/email_service.dart` - Email handling with mailto: and fallback
- `lib/services/phone_service.dart` - Phone call and number copy
- `lib/services/ai_chat_service.dart` - AI chat with message history

### Widgets
- `lib/ui/widgets/share_freezones_sheet.dart` - Freezone sharing with mentions
- `lib/ui/widgets/ask_with_ai_sheet.dart` - Full-screen AI chat UI

### Data
- `lib/data/freezones_data.dart` - List of available freezones
- `lib/data/mentions_data.dart` - List of team mentions

### Backend
- `functions/index.js` - Updated with aiChat endpoint
- `functions/aiChat.js` - Standalone reference implementation

## Firebase Functions Setup

### 1. Install OpenAI Package

```bash
cd functions
npm install openai
```

### 2. Set Environment Variables

Set your OpenAI API key (required):

```bash
firebase functions:config:set openai.api_key="sk-proj-your-key-here"
```

Optional: Set a custom model (defaults to gpt-4o-mini):

```bash
firebase functions:config:set openai.model="gpt-4"
```

### 3. Deploy the Function

```bash
firebase deploy --only functions:aiChat
```

### 4. Verify Deployment

Check the Firebase Console > Functions to ensure `aiChat` is deployed successfully.

## Testing the Features

### 1. Send Email
- Tap "Send Email" from the bottom sheet
- On mobile: Opens default email app
- On web/desktop: Shows fallback form
- Long press phone number to copy

### 2. Share Freezones & Mention
- Tap "Share Freezones & Mention"
- Search and select multiple freezones
- Add @mentions from the list
- Add optional note
- Preview shows all selections
- Tap "Share" to send (logs payload for now)

### 3. Call Now
- Tap "Call Now" to dial
- Long press the tile to copy number
- Works on devices with phone capability

### 4. Ask with AI
- Tap "Ask with AI (ChatGPT)"
- Opens full-screen chat interface
- Type questions about UAE company setup
- AI responds using OpenAI API via Firebase Functions
- Chat history saved locally (last 10 messages)
- Tap delete icon to clear history

## Security Best Practices

✅ **DO:**
- Keep OpenAI API key in Firebase Functions config only
- Never commit API keys to git
- Monitor OpenAI usage and costs
- Set reasonable max_tokens in function
- Consider adding authentication checks
- Implement rate limiting for production

❌ **DON'T:**
- Never put API keys in client code
- Never expose keys in environment files committed to git
- Don't skip error handling in production

## Cost Management

The AI chat uses OpenAI's API which has per-token pricing:
- Model: gpt-4o-mini (recommended for cost efficiency)
- Max tokens per request: 1000
- Consider implementing user quotas or rate limits
- Monitor usage in OpenAI dashboard

## Telemetry (Optional)

Add analytics events in your existing analytics service:

```dart
// In email_service.dart
analytics.logEvent('sheet_click_email');

// In phone_service.dart
analytics.logEvent('sheet_click_call_now');

// In share_freezones_sheet.dart
analytics.logEvent('sheet_click_share_freezones');

// In ask_with_ai_sheet.dart
analytics.logEvent('sheet_click_ai_chat');
analytics.logEvent('ai_chat_message_sent');
```

## Troubleshooting

### AI Chat Not Working
1. Check Firebase Functions logs: `firebase functions:log`
2. Verify OpenAI API key is set: `firebase functions:config:get`
3. Ensure openai npm package is installed
4. Check internet connectivity

### Email Not Opening
- Mobile: Ensure device has email app configured
- Web: Fallback form should appear automatically

### Phone Call Not Working
- Verify device has phone capability
- Check tel: URL scheme is not blocked
- On web, shows toast message (calls not supported)

## Next Steps

1. **Add Authentication**: Uncomment auth check in `aiChat` function
2. **Implement Rate Limiting**: Add Firebase Extensions or custom logic
3. **Add Real Share Endpoint**: Replace share logging with actual API call
4. **Add Analytics**: Integrate with your existing analytics service
5. **Add Tests**: Write integration tests for each action

## Support

For questions or issues:
- Email: support@wazeet.com
- Phone: +971559986386
- Or ask the AI assistant in the app! 😊
