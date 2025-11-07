# Community Data Integration - Quick Start

## ✅ What's Been Implemented

### Backend (Cloud Functions)
- ✅ `functions/src/config.ts` - Configuration with CSE credentials, cache TTL, rate limits
- ✅ `functions/src/community/googleCommunity.ts` - Three callable functions:
  - `communityFetchHashtags` - Trending hashtags from Twitter/LinkedIn
  - `communityFetchNews` - UAE business news with industry filter
  - `communityFetchEvents` - UAE business events with industry filter
- ✅ Server-side Firestore caching (4-hour TTL)
- ✅ Rate limiting (20 calls/hour per user)
- ✅ Authentication checks (must be signed in)

### Data Layer (Flutter)
- ✅ `lib/models/community_models.dart` - TrendingTag, NewsItem, EventItem models
- ✅ `lib/services/community/trending_service.dart` - Trending hashtags service
- ✅ `lib/services/community/news_service.dart` - Business news service
- ✅ `lib/services/community/events_service.dart` - Events service
- ✅ Client-side SharedPreferences caching (4-hour TTL)
- ✅ Exponential backoff retry (3 attempts)

### UI (Flutter)
- ✅ `lib/ui/pages/community/trending_tab.dart` - Trending topics tab
- ✅ `lib/ui/pages/community/news_tab.dart` - Business news tab with industry filter
- ✅ `lib/ui/pages/community/events_tab.dart` - Events tab with industry filter
- ✅ Pull-to-refresh, manual refresh, error states, empty states
- ✅ External browser links for articles and events
- ✅ Integration into existing `community_page.dart`

### Documentation
- ✅ `docs/COMMUNITY_DATA.md` - Complete integration guide

## 🔧 Required Setup Steps

### 1. Set Firebase Configuration (CRITICAL)

```bash
# Set your Google Custom Search API credentials
firebase functions:config:set google.cse_key="YOUR_API_KEY_HERE"
firebase functions:config:set google.cse_cx="YOUR_SEARCH_ENGINE_ID_HERE"

# Verify the configuration
firebase functions:config:get
```

### 2. Install Dependencies

```bash
# Cloud Functions dependencies
cd functions
npm install

# Flutter dependencies (already in pubspec.yaml)
cd ..
flutter pub get
```

### 3. Deploy Cloud Functions

```bash
cd functions
npm run build
firebase deploy --only functions:communityFetchHashtags,functions:communityFetchNews,functions:communityFetchEvents
```

### 4. Test in App

```bash
flutter run
```

Navigate to Community page → Test each tab:
- **Trending**: Should show hashtags with counts
- **Events**: Filter by industry, should show upcoming events
- **Business News**: Filter by industry, should show recent news

## 📋 Quick Reference

### Cache Times
- Server: 4 hours (Firestore)
- Client: 4 hours (SharedPreferences)

### Rate Limits
- 20 calls/hour per user per endpoint
- Window resets after 1 hour

### Industry Filters
Available for News and Events tabs:
- All Industries
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

### API Costs
- Free: 100 queries/day
- Paid: $5 per 1,000 queries (after 100/day)

## 🐛 Troubleshooting

### "CSE credentials not configured"
→ Run: `firebase functions:config:set google.cse_key="KEY" google.cse_cx="CX"`

### "Rate limit exceeded"
→ Wait up to 1 hour, or increase `RATE_LIMIT_MAX` in `functions/src/config.ts`

### No results showing
→ Check Google CSE configuration, ensure it searches the whole web

### Cache not working
→ Clear app data and reinstall

## 📝 Next Steps (Optional)

### Cleanup Old Code (Optional)
The following unused methods in `community_page.dart` can be removed:
- `_buildTrendingTab()` (line ~1483)
- `_buildEventsTab()` (line ~1625)
- `_buildBusinessNewsTab()` (line ~1756)

These are now replaced by the new tab widgets but can be kept as reference.

### Widget Tests (Recommended)
Create `test/community/community_tabs_test.dart` to test:
- Tab widgets render lists when data present
- Empty states appear when lists empty
- Industry filter triggers new fetch
- External links open correctly

### Analytics (Future)
Track which hashtags, news, events are most clicked to personalize content.

## 📚 Full Documentation

See `docs/COMMUNITY_DATA.md` for complete details including:
- Architecture diagram
- API endpoint specifications
- Query strategies
- Caching strategy
- Error handling
- Cost considerations
- Future enhancements

## ✨ Features

- **Real-time trending hashtags** from UAE business community
- **Latest business news** from major UAE news sources
- **Upcoming events** with date, venue, and organizer info
- **Industry filtering** for personalized content
- **Offline support** via client-side caching
- **Smart retry logic** with exponential backoff
- **Rate limiting** to prevent API abuse
- **Beautiful UI** with Material Design 3

## 🎉 Ready to Use!

Once you complete steps 1-4 above, the Community tabs will be fully functional with real data from Google Custom Search API.
