# 🚀 Quick Deployment Guide - Event Discovery

This is your **next step** guide to deploy the event discovery feature to production.

## ⚡ Quick Start (5-10 minutes)

### Step 1: Get API Keys

#### Google Custom Search API (2-3 min)
1. Go to https://console.cloud.google.com/
2. Enable "Custom Search API"
3. Create credentials → API Key
4. Copy your API key (looks like: `AIza...`)

#### Google Programmable Search Engine (2-3 min)
1. Visit https://programmablesearchengine.google.com/
2. Click "Add" to create new search engine
3. Under "Sites to search", add:
   - `*.eventbrite.ae`
   - `*.meetup.com`
   - `*.lovin.co`
4. Or select "Search the entire web"
5. Create and copy your Search Engine ID (CX)

#### OpenAI API Key (if you don't have it)
1. Visit https://platform.openai.com/api-keys
2. Create new secret key
3. Copy the key (starts with `sk-`)

### Step 2: Configure Firebase

```bash
# Navigate to functions directory
cd /Users/amanshah/WAZEET_APP_GPT/functions

# Set environment variables
firebase functions:config:set openai.api_key="sk-YOUR-OPENAI-KEY"
firebase functions:config:set google.search_api_key="YOUR-GOOGLE-API-KEY"
firebase functions:config:set google.search_cx="YOUR-SEARCH-ENGINE-ID"

# Verify configuration
firebase functions:config:get
```

Expected output:
```json
{
  "openai": {
    "api_key": "sk-..."
  },
  "google": {
    "search_api_key": "AIza...",
    "search_cx": "..."
  }
}
```

### Step 3: Deploy Cloud Functions

```bash
# Make sure you're in the functions directory
cd /Users/amanshah/WAZEET_APP_GPT/functions

# Build TypeScript (should already be built)
npm run build

# Deploy to Firebase
firebase deploy --only functions

# Or deploy specific function
firebase deploy --only functions:discoverDubaiEvents
```

Wait for deployment to complete (2-3 minutes).

### Step 4: Test the Function

#### Option A: Manual Trigger (Recommended)

In your Flutter app, you can call:
```dart
await FirebaseFunctions.instance
    .httpsCallable('triggerEventDiscovery')
    .call();
```

Or use Firebase CLI:
```bash
firebase functions:shell

# Then in the shell:
discoverDubaiEvents()
```

#### Option B: Wait for Scheduled Run

The function will automatically run at midnight Dubai time (Asia/Dubai timezone).

### Step 5: Verify in Firestore

1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project
3. Navigate to Firestore Database
4. Look for `discoveredEvents` collection
5. You should see event documents within 1-2 minutes

### Step 6: Test in Flutter App

1. Open the WAZEET app
2. Navigate to Community → Events tab
3. You should see the discovered events
4. Tap "View Details" to open event pages

## 🐛 Troubleshooting

### "Missing required environment variables"

```bash
# Check current config
firebase functions:config:get

# If empty, run Step 2 again
```

### "No search results found"

- Google Custom Search has 100 free searches/day limit
- Test manually: `https://www.googleapis.com/customsearch/v1?key=YOUR_KEY&cx=YOUR_CX&q=dubai events`
- If it returns results, the function should work

### TypeScript build errors

```bash
cd functions
rm -rf lib node_modules package-lock.json
npm install
npm run build
```

### Function timeout

Default timeout is 60s. If needed, update in `functions/src/index.ts`:
```typescript
export const discoverDubaiEvents = functions
  .region('me-central1')
  .runWith({ timeoutSeconds: 120 }) // Increase to 120s
  .pubsub.schedule('every 24 hours')
  // ...
```

## 📊 Monitoring

### View Logs

```bash
# Real-time logs
firebase functions:log --follow

# Specific function logs
firebase functions:log --only discoverDubaiEvents

# Last 100 lines
firebase functions:log --limit 100
```

### Check Function Execution

1. Firebase Console → Functions tab
2. Click `discoverDubaiEvents`
3. View logs, metrics, and errors

### Set Up Alerts

1. Firebase Console → Functions → discoverDubaiEvents
2. Click "Logs" tab
3. Set up email alerts for errors

## 💰 Cost Estimates

Based on daily execution:
- **Google Custom Search**: 100 free searches/day, then $5/1,000 queries
- **OpenAI API**: ~$0.001 per call (gpt-4o-mini)
- **Cloud Functions**: 2M free invocations/month
- **Firestore**: 50K reads/day free

**Estimated daily cost**: $0.03 (practically free)

## ✅ Post-Deployment Checklist

- [ ] API keys configured in Firebase
- [ ] Cloud Functions deployed successfully
- [ ] Manual test run completed
- [ ] Events visible in Firestore
- [ ] Events display in Flutter app
- [ ] External links working
- [ ] Logs monitored for errors
- [ ] Budget alerts set up (optional)

## 🔄 Update/Redeploy

If you make changes to the Cloud Function:

```bash
cd /Users/amanshah/WAZEET_APP_GPT/functions
npm run build
firebase deploy --only functions:discoverDubaiEvents
```

## 📞 Support

If you encounter issues:

1. Check logs: `firebase functions:log --only discoverDubaiEvents`
2. Verify API keys: `firebase functions:config:get`
3. Test Google Search API manually (see troubleshooting)
4. Check Firestore security rules
5. Review `docs/EVENT_DISCOVERY_SETUP.md` for detailed info

## 🎉 Success Indicators

You'll know it's working when:
- ✅ Function logs show "Event discovery complete: X new, Y updated"
- ✅ Firestore has documents in `discoveredEvents` collection
- ✅ Flutter app displays events in Community → Events tab
- ✅ "View Details" buttons open external event pages

---

**Total Time**: ~10 minutes (5 min setup + 5 min deploy + testing)

**Next Run**: Tomorrow at midnight Dubai time (automatic)

**Status**: Ready for deployment 🚀
