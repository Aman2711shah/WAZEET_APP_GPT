# Quick Reference: New Bottom Sheet Actions

## 🎯 What Changed

**REMOVED:** "Copy details" action (with copy icon)

**ADDED:** Four new actions with enhanced functionality

## 📋 Action Reference

### 1. Send Email 📧
```dart
ListTile(
  leading: const Icon(Icons.email_outlined),
  title: const Text('Send Email'),
  subtitle: const Text('Contact us via email'),
  onTap: () async {
    await EmailService.sendEmail(
      subject: 'Inquiry about ${zone.name}',
      body: 'Hello, I am interested in...',
      context: context,
    );
  },
)
```
- Opens mailto: link
- Fallback form if email client unavailable
- Pre-filled with freezone details

### 2. Share Freezones & Mention 🔗
```dart
ListTile(
  leading: const Icon(Icons.share_outlined),
  title: const Text('Share Freezones & Mention'),
  subtitle: const Text('Share with team members'),
  onTap: () {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ShareFreezonesSheet(),
    );
  },
)
```
- Multi-select from 17 freezones
- Add @mentions (9 team options)
- Optional note field
- Preview before sharing

### 3. Call Now 📞
```dart
ListTile(
  leading: const Icon(Icons.call_outlined),
  title: const Text('Call Now'),
  subtitle: const Text('+971 55 998 6386'),
  onTap: () => PhoneService.makeCall(context),
  onLongPress: () => PhoneService.copyPhoneNumber(context),
)
```
- Tap to call: +971559986386
- Long press to copy number

### 4. Ask with AI (ChatGPT) 🤖
```dart
ListTile(
  leading: const Icon(Icons.smart_toy_outlined),
  title: const Text('Ask with AI (ChatGPT)'),
  subtitle: const Text('Get instant answers'),
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AskWithAISheet(),
        fullscreenDialog: true,
      ),
    );
  },
)
```
- Full-screen chat interface
- Powered by OpenAI gpt-4o-mini
- Message history (last 10)
- System prompt: UAE expertise

## 🔑 Firebase Setup Commands

```bash
# 1. Set OpenAI API key
firebase functions:config:set openai.api_key="sk-proj-your-key-here"

# 2. (Optional) Set custom model
firebase functions:config:set openai.model="gpt-4o-mini"

# 3. Deploy the function
cd functions
firebase deploy --only functions:aiChat

# 4. Verify deployment
firebase functions:list | grep aiChat
```

## 🧪 Testing Scenarios

### Email Action
1. Tap "Send Email" on iOS/Android → Opens Mail app
2. Tap "Send Email" on web → Shows fallback form
3. Verify subject includes freezone name
4. Verify body includes freezone details

### Share Action
1. Tap "Share Freezones & Mention"
2. Search for "DMCC" → Appears in list
3. Select 3 freezones
4. Add @Sales and @Legal
5. Add note: "Check these out"
6. Verify preview shows all selections
7. Tap Share → See success SnackBar

### Call Action
1. Tap "Call Now" → Launches phone dialer
2. Long press "Call Now" → Number copied
3. Paste → Verify +971559986386

### AI Chat Action
1. Tap "Ask with AI (ChatGPT)"
2. Type: "What is DMCC?"
3. Wait for response
4. Send another message
5. Close and reopen → History preserved
6. Tap delete icon → History cleared

## 📊 Telemetry Integration

```dart
// In your existing analytics service

// Email
analytics.logEvent('sheet_click_email');

// Share
analytics.logEvent('sheet_click_share_freezones', parameters: {
  'freezones_count': selectedFreezones.length,
  'mentions_count': selectedMentions.length,
});

// Call
analytics.logEvent('sheet_click_call_now');

// AI Chat
analytics.logEvent('sheet_click_ai_chat');
analytics.logEvent('ai_chat_message_sent', parameters: {
  'message_length': message.length,
});
analytics.logEvent('ai_chat_error', parameters: {
  'error_type': error.toString(),
});
```

## 🎨 Customization

### Change Phone Number
```dart
// In lib/services/phone_service.dart
static const String supportPhoneNumber = '+971559986386'; // Update here
```

### Add More Freezones
```dart
// In lib/data/freezones_data.dart
static const List<String> availableFreezones = [
  'JAFZA',
  'DMCC',
  // Add more here
];
```

### Add More Mentions
```dart
// In lib/data/mentions_data.dart
static const List<String> availableMentions = [
  '@Sales',
  '@Support',
  // Add more here
];
```

### Customize AI System Prompt
```javascript
// In functions/index.js
const SYSTEM_PROMPT = 'Your custom prompt here...';
```

## 🐛 Troubleshooting

### AI Chat Not Working
- Check Firebase Functions logs: `firebase functions:log`
- Verify API key: `firebase functions:config:get openai`
- Check network in Flutter DevTools

### Email Not Opening
- Verify device has email configured
- Check mailto: URL encoding
- Fallback form should appear on web

### Call Not Working
- Web: Calls not supported (expected)
- Mobile: Check permissions

### Share Not Appearing
- Check modal is not blocked by keyboard
- Verify isScrollControlled: true

## 📚 Documentation Files

- `AI_CHAT_SETUP_GUIDE.md` - Complete setup instructions
- `BOTTOM_SHEET_IMPLEMENTATION_SUMMARY.md` - Implementation summary
- `functions/aiChat.js` - Reference implementation
- `scripts/verify_bottom_sheet.sh` - Verification script

## 🚀 Deployment Checklist

- [ ] OpenAI API key configured in Firebase
- [ ] Firebase Functions deployed
- [ ] App tested on iOS
- [ ] App tested on Android  
- [ ] App tested on web
- [ ] Analytics events added
- [ ] Rate limiting configured
- [ ] Billing alerts set up
- [ ] Documentation updated

## 💬 Support

Need help? Use the AI chat feature in the app or contact:
- 📧 Email: support@wazeet.com
- 📞 Phone: +971 55 998 6386

---

**Last Updated:** November 6, 2025
**Version:** 1.0.0
