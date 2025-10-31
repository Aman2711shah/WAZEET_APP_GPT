# Event Discovery Cloud Function Setup

This guide explains how to set up and deploy the automated Dubai business event discovery system using Firebase Cloud Functions.

## Overview

The system automatically discovers Dubai business events every 24 hours by:
1. Searching Google using Custom Search API
2. Parsing results with OpenAI GPT-4o-mini
3. Storing structured events in Firestore
4. Making them available to the Flutter app in real-time

## Prerequisites

1. **Google Custom Search API**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Enable "Custom Search API"
   - Create credentials → API Key
   - Copy your API key

2. **Google Programmable Search Engine**
   - Visit [Programmable Search Engine](https://programmablesearchengine.google.com/)
   - Click "Add" to create a new search engine
   - Set "Sites to search" to: `*.eventbrite.ae`, `*.meetup.com`, `*.lovin.co`
   - Or choose "Search the entire web" and use query filters
   - Copy your Search Engine ID (CX)

3. **OpenAI API Key**
   - Visit [OpenAI Platform](https://platform.openai.com/api-keys)
   - Create a new API key
   - Copy the key (starts with `sk-`)

## Setup Instructions

### 1. Install Dependencies

```bash
cd functions
npm install
```

This installs:
- `firebase-functions` - Cloud Functions runtime
- `firebase-admin` - Firestore access
- `axios` - HTTP requests to Google Search API
- `openai` - OpenAI SDK for GPT parsing
- `stripe` - Payment processing (existing)
- TypeScript tooling and type definitions

### 2. Configure Environment Variables

You have two options:

#### Option A: Firebase Environment Config (Recommended for Production)

```bash
# Set OpenAI API key
firebase functions:config:set openai.api_key="sk-your-openai-key"

# Set Google Custom Search API key
firebase functions:config:set google.search_api_key="YOUR_GOOGLE_API_KEY"

# Set Google Search Engine ID (CX)
firebase functions:config:set google.search_cx="YOUR_SEARCH_ENGINE_ID"

# Set Stripe keys (if not already set)
firebase functions:config:set stripe.secret_key="sk_test_..."
firebase functions:config:set stripe.webhook_secret="whsec_..."

# View current config
firebase functions:config:get
```

#### Option B: Local .env File (For Testing)

Create `functions/.env`:
```env
OPENAI_API_KEY=sk-your-openai-key
GOOGLE_CUSTOM_SEARCH_API_KEY=YOUR_GOOGLE_API_KEY
GOOGLE_CUSTOM_SEARCH_CX=YOUR_SEARCH_ENGINE_ID
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

**Important:** The `.env` file is already in `.gitignore` - never commit API keys!

### 3. Build TypeScript Code

```bash
cd functions
npm run build
```

This compiles `src/index.ts` → `lib/index.js`

### 4. Test Locally (Optional)

Start Firebase emulators:
```bash
firebase emulators:start --only functions
```

In another terminal, trigger the function manually:
```bash
firebase functions:shell

# Inside the shell:
discoverDubaiEvents()
```

### 5. Deploy to Firebase

Deploy all functions:
```bash
firebase deploy --only functions
```

Or deploy specific function:
```bash
firebase deploy --only functions:discoverDubaiEvents
```

## Cloud Functions Overview

### 1. `discoverDubaiEvents` (Scheduled)

**Trigger:** Runs every 24 hours at midnight Dubai time  
**Purpose:** Automatically discover and parse Dubai business events

**Process:**
1. Queries Google Custom Search API for Dubai events
2. Extracts titles, snippets, and URLs from top 5 results
3. Sends combined text to OpenAI GPT-4o-mini with JSON schema
4. Parses structured event data (name, date, time, location, category)
5. Stores events in Firestore `discoveredEvents` collection
6. Uses `sourceURL` as unique identifier to avoid duplicates

**Firestore Schema:**
```typescript
{
  eventName: string,
  date: string (YYYY-MM-DD),
  time: string | null (HH:MM),
  location: {
    venue: string,
    address: string | null
  },
  category: "Networking" | "Workshop" | "Conference" | "Competition" | "Other",
  sourceURL: string,
  description: string,
  attendees: number,
  discoveredAt: Timestamp,
  lastUpdated: Timestamp
}
```

### 2. `triggerEventDiscovery` (Callable)

**Trigger:** Manual HTTPS call from authenticated users  
**Purpose:** Manually trigger event discovery for testing

**Usage from Flutter:**
```dart
final functions = FirebaseFunctions.instance;
final result = await functions.httpsCallable('triggerEventDiscovery').call();
```

### 3. `createPaymentIntent` (Callable)

**Purpose:** Create Stripe payment intents (existing function)

### 4. `handleStripeWebhook` (HTTP)

**Purpose:** Handle Stripe webhook events (existing function)

## Firestore Security Rules

Add to `firestore.rules`:

```
// Allow read access to discovered events for all authenticated users
match /discoveredEvents/{eventId} {
  allow read: if request.auth != null;
  allow write: if false; // Only Cloud Functions can write
}
```

## Monitoring & Troubleshooting

### View Logs

```bash
# All function logs
firebase functions:log

# Specific function logs
firebase functions:log --only discoverDubaiEvents

# Follow logs in real-time
firebase functions:log --only discoverDubaiEvents --follow
```

### Common Issues

1. **"Missing required environment variables"**
   - Run `firebase functions:config:get` to verify config
   - Ensure all three keys are set: `openai.api_key`, `google.search_api_key`, `google.search_cx`

2. **"No search results found"**
   - Check Google Custom Search quota (100 free searches/day)
   - Verify Search Engine ID (CX) is correct
   - Test search manually: `https://www.googleapis.com/customsearch/v1?key=YOUR_KEY&cx=YOUR_CX&q=dubai events`

3. **TypeScript compilation errors**
   - Run `npm install` to ensure all dependencies are installed
   - Check `tsconfig.json` is present
   - Clear `lib/` folder and rebuild: `rm -rf lib && npm run build`

4. **Function timeout**
   - Default timeout is 60s, increase if needed in function config
   - Reduce number of search results (`num` parameter)

## Cost Considerations

- **Google Custom Search API:** 100 searches/day free, then $5 per 1,000 queries
- **OpenAI API:** ~$0.001 per call with gpt-4o-mini
- **Firebase Cloud Functions:** Free tier includes 2M invocations/month
- **Estimated cost:** ~$0.03/day with scheduled function (1 search + 1 OpenAI call)

## Next Steps

1. ✅ Cloud Function deployed
2. ⏳ Create event UI in Flutter app
3. ⏳ Add event detail page with registration
4. ⏳ Implement event reminders with push notifications
5. ⏳ Add event filtering and search in UI

## Testing the Function

Once deployed, check Firestore Console:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to Firestore Database
4. Look for `discoveredEvents` collection
5. Events should appear within 24 hours, or trigger manually

To trigger immediately:
```bash
# Using Firebase CLI
firebase functions:shell

# Then in the shell:
discoverDubaiEvents()
```

Or from Flutter app (as admin user):
```dart
await FirebaseFunctions.instance
    .httpsCallable('triggerEventDiscovery')
    .call();
```
