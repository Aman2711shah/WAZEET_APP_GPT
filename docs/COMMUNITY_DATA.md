# Community Data Integration

This document describes the Google Custom Search API integration for populating the Community tabs with trending topics, business news, and events.

## Overview

The WAZEET app uses Google Custom Search JSON API (CSE) to fetch real-time community data from across the web. The integration is implemented as:

1. **Firebase Cloud Functions** - Secure proxy with caching and rate limiting
2. **Flutter Services** - Client-side services with local caching
3. **UI Tabs** - Three dedicated tabs for different content types

## Architecture

```
Flutter App
  ↓ (calls)
Cloud Functions (secure proxy)
  ↓ (caches in Firestore, checks rate limits)
Google Custom Search API
  ↓ (returns search results)
Cloud Functions (transforms data)
  ↓ (returns typed results)
Flutter App (caches in SharedPreferences)
```

## Configuration Setup

### Step 1: Set Firebase Function Configuration

Before deploying, you **must** set your Google CSE credentials:

```bash
firebase functions:config:set google.cse_key="YOUR_API_KEY_HERE"
firebase functions:config:set google.cse_cx="YOUR_SEARCH_ENGINE_ID_HERE"
```

To verify the configuration:

```bash
firebase functions:config:get
```

### Step 2: Get Google CSE Credentials

If you don't have CSE credentials yet:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Enable the **Custom Search API**
3. Create an API key (restrict it to Custom Search API only)
4. Go to [Programmable Search Engine](https://programmablesearchengine.google.com/)
5. Create a new search engine or use existing
6. Get the Search Engine ID (cx parameter)

### Step 3: Deploy Cloud Functions

```bash
cd functions
npm install
npm run build
firebase deploy --only functions:communityFetchHashtags,functions:communityFetchNews,functions:communityFetchEvents
```

## API Endpoints

### 1. communityFetchHashtags

Fetches trending hashtags from Twitter and LinkedIn in the UAE business community.

**Function:** `communityFetchHashtags`

**Parameters:** None

**Returns:** `Array<{tag: string, count: number}>`

**Query Strategy:**
- Searches: `"UAE business" OR "Dubai startup" site:twitter.com OR site:linkedin.com`
- Extracts hashtags using regex: `/(?:^|\s)#([A-Za-z0-9_]{3,30})/g`
- Returns top 20 by frequency

**Cache Key:** `hashtags:uae:v1`

**Cache TTL:** 4 hours

**Rate Limit:** 20 calls/hour per user

### 2. communityFetchNews

Fetches recent UAE business news articles, optionally filtered by industry.

**Function:** `communityFetchNews`

**Parameters:**
- `industry` (optional): Industry filter (e.g., "FinTech", "E-commerce")

**Returns:** `Array<{title, source, url, snippet, publishedAt}>`

**Query Strategy:**
- Base: `UAE business news site:gulfnews.com OR site:khaleejtimes.com OR site:thenationalnews.com OR site:arabianbusiness.com after:7d`
- With industry: Adds industry name to the beginning

**Cache Key:** `news:${industry || 'all'}:v1`

**Cache TTL:** 4 hours

**Rate Limit:** 20 calls/hour per user per industry

### 3. communityFetchEvents

Fetches upcoming UAE business events, optionally filtered by industry.

**Function:** `communityFetchEvents`

**Parameters:**
- `industry` (optional): Industry filter (e.g., "Technology", "Healthcare")

**Returns:** `Array<{title, url, organizer, whenStart, whenEnd, venue, city, industry}>`

**Query Strategy:**
- Base: `UAE business event "Dubai" OR "Abu Dhabi" OR "Sharjah" ${industry || ''} conference OR expo OR summit OR forum`
- Extracts dates, venues, cities from snippets using regex patterns

**Cache Key:** `events:${industry || 'all'}:v1`

**Cache TTL:** 4 hours

**Rate Limit:** 20 calls/hour per user per industry

## Industry List

The following industries are supported for filtering news and events:

- All Industries (no filter)
- E-commerce
- FinTech
- Food & Beverage
- Healthcare
- Real Estate
- Technology
- Tourism & Hospitality
- Trade
- Logistics
- Manufacturing

These are defined in:
- `functions/src/config.ts` - Server-side
- `lib/ui/pages/community/news_tab.dart` - Client-side (news)
- `lib/ui/pages/community/events_tab.dart` - Client-side (events)

## Caching Strategy

### Server-Side (Firestore)

**Collection:** `community_cache`

**Document Structure:**
```json
{
  "key": "news:FinTech:v1",
  "data": [...],
  "timestamp": 1234567890000
}
```

**TTL:** 4 hours (14,400,000 ms)

**Purpose:** Share cached results across all users to minimize API calls

### Client-Side (SharedPreferences)

**Keys:**
- `wazeet.community.trending` - Trending hashtags
- `wazeet.community.news:${industry}` - News by industry
- `wazeet.community.events:${industry}` - Events by industry

**Storage Format:**
```json
{
  "data": [...],
  "timestamp": 1234567890000
}
```

**TTL:** 4 hours (14,400,000 ms)

**Purpose:** Instant load without network call, per-user caching

## Rate Limiting

**Collection:** `community_rate_limits`

**Document Structure:**
```json
{
  "userId": "user123",
  "endpoint": "communityFetchNews",
  "calls": 5,
  "window": 1234567890000
}
```

**Window:** 1 hour (3,600,000 ms)

**Limit:** 20 calls per hour per user per endpoint

**Enforcement:** Returns error if limit exceeded, resets after 1 hour

## Error Handling

### Client-Side

All services implement exponential backoff retry:

```typescript
Attempt 1: Immediate call
Attempt 2: Wait 1 second
Attempt 3: Wait 2 seconds
Attempt 4: Wait 4 seconds (give up)
```

### Server-Side

Errors are logged and returned with descriptive messages:

- `CSE credentials not configured` - Missing `google.cse_key` or `google.cse_cx`
- `Rate limit exceeded` - User has made too many calls
- `Google CSE API error` - API returned an error (check API key, quota, etc.)
- `Failed to fetch from Google CSE` - Network error

## UI Components

### TrendingTab (`lib/ui/pages/community/trending_tab.dart`)

**Features:**
- Displays hashtags as tappable pills with count badges
- Pull-to-refresh support
- Manual refresh button
- Opens Google search for hashtag on tap
- Empty state when no trending topics
- Error state with retry button

### NewsTab (`lib/ui/pages/community/news_tab.dart`)

**Features:**
- Industry filter dropdown
- News cards with title, source, snippet, time ago
- "Read More" button opens article in external browser
- Pull-to-refresh support
- Manual refresh button
- Empty state when no news for industry
- Error state with retry button

### EventsTab (`lib/ui/pages/community/events_tab.dart`)

**Features:**
- Industry filter dropdown
- Event cards with title, organizer, date, location, industry tag
- "Get Tickets" button opens event page in external browser
- Pull-to-refresh support
- Manual refresh button
- Empty state when no events for industry
- Error state with retry button

## Testing

### Local Testing

1. Ensure Firebase emulators are running:
   ```bash
   firebase emulators:start
   ```

2. Set test credentials in emulator config:
   ```bash
   firebase functions:config:set google.cse_key="test" google.cse_cx="test" --project your-project
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Production Testing

1. Set production credentials (see Configuration Setup)

2. Deploy functions:
   ```bash
   cd functions && firebase deploy --only functions
   ```

3. Navigate to Community page in app and test each tab:
   - Trending: Should show hashtags within 10 seconds
   - News: Try different industries, should show articles
   - Events: Try different industries, should show events

4. Test caching:
   - First load: Should show loading spinner
   - Second load (within 4 hours): Should load instantly from cache
   - Force refresh: Should reload from server

5. Test rate limiting:
   - Make 20+ calls within an hour
   - Should see rate limit error after 20 calls

## Troubleshooting

### "CSE credentials not configured"

**Cause:** Firebase config missing

**Solution:**
```bash
firebase functions:config:set google.cse_key="YOUR_KEY" google.cse_cx="YOUR_CX"
firebase deploy --only functions
```

### "Rate limit exceeded"

**Cause:** User made 20+ calls in the last hour

**Solution:** Wait for the rate limit window to reset (up to 1 hour), or increase `RATE_LIMIT_MAX` in `functions/src/config.ts`

### "No results found"

**Cause:** Google CSE returned no results for the query

**Solution:**
- Check that CSE is configured to search the whole web (not just specific sites)
- Try adjusting query parameters in `functions/src/community/googleCommunity.ts`
- Verify the date filters are not too restrictive

### Empty cache on every load

**Cause:** SharedPreferences not persisting or cache keys mismatched

**Solution:**
- Check console for cache read/write errors
- Verify cache key format matches between get and set
- Clear app data and reinstall

### API quota exceeded

**Cause:** Google CSE free tier limit reached (100 queries/day)

**Solution:**
- Increase cache TTL to reduce API calls
- Enable billing on Google Cloud to increase quota
- Implement more aggressive client-side caching

## Cost Considerations

### Google CSE Pricing

- **Free tier:** 100 queries/day
- **Paid tier:** $5 per 1000 queries (after 100/day)

### Optimization Tips

1. **Increase cache TTL** - Current 4 hours, could extend to 12-24 hours for less volatile data
2. **Reduce rate limit** - Current 20/hour, could reduce to 10/hour
3. **Implement CDN** - Cache API responses at edge for global users
4. **Batch requests** - Fetch multiple industries at once (not currently implemented)

## Maintenance

### Updating Industry List

1. Edit `INDUSTRIES` array in `functions/src/config.ts`
2. Edit `INDUSTRIES` array in `lib/ui/pages/community/news_tab.dart`
3. Edit `INDUSTRIES` array in `lib/ui/pages/community/events_tab.dart`
4. Redeploy functions: `firebase deploy --only functions`
5. Rebuild app: `flutter build`

### Changing Cache TTL

1. Edit `CACHE_TTL_MS` in `functions/src/config.ts` (server-side)
2. Edit `_cacheTTL` in Flutter services (client-side):
   - `lib/services/community/trending_service.dart`
   - `lib/services/community/news_service.dart`
   - `lib/services/community/events_service.dart`
3. Redeploy and rebuild

### Changing Rate Limit

1. Edit `RATE_LIMIT_MAX` in `functions/src/config.ts`
2. Redeploy functions: `firebase deploy --only functions`

## Future Enhancements

1. **Personalization** - Track user's preferred industries and show relevant content first
2. **Bookmarks** - Allow users to save news articles and events
3. **Notifications** - Push notifications for new trending topics
4. **Analytics** - Track which hashtags/news/events are most clicked
5. **Admin Dashboard** - View cache hit rates, API usage, rate limit violations
6. **Content Moderation** - Filter out inappropriate hashtags or spam
7. **Local Events** - Detect user's location and prioritize nearby events

## Related Files

### Cloud Functions
- `functions/src/config.ts` - Configuration and constants
- `functions/src/community/googleCommunity.ts` - Three callable functions
- `functions/src/index.ts` - Exports

### Flutter Models
- `lib/models/community_models.dart` - TrendingTag, NewsItem, EventItem

### Flutter Services
- `lib/services/community/trending_service.dart` - Trending hashtags
- `lib/services/community/news_service.dart` - Business news
- `lib/services/community/events_service.dart` - Upcoming events

### Flutter UI
- `lib/ui/pages/community/trending_tab.dart` - Trending topics tab
- `lib/ui/pages/community/news_tab.dart` - Business news tab
- `lib/ui/pages/community/events_tab.dart` - Events tab
- `lib/ui/pages/community_page.dart` - Main community page with tabs

## Support

For issues or questions, contact the development team or file an issue in the repository.
