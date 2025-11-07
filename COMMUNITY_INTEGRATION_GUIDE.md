# Community Feature - Quick Integration Guide

## Summary

The WAZEET app **already has working News and Events features**! This PR adds the missing **People & Connections** feature.

## What's Already Working ✅

- ✅ **Business News Tab** - Live RSS feeds from Google News, Bloomberg, Reuters
- ✅ **Events Tab** - Automated Cloud Function discovers events daily using OpenAI
- ✅ **Industry Filtering** - Both News and Events support industry filters
- ✅ **Real-time Updates** - Firestore streams automatically update UI

## What's New 🆕

- 🆕 **User Profiles** - Real profiles from Firestore
- 🆕 **Suggested Connections** - Based on industry, activity, mutual connections
- 🆕 **Connect/Accept/Ignore Flow** - Full connection management
- 🆕 **Mutual Connections Count** - Shows how many connections you have in common

## Files Created

```
lib/community/
├── models.dart                  # UserProfile, Connection, NewsItem, EventItem
├── people_repository.dart       # Connection management & suggestions
├── news_repository.dart         # Alternative Google Custom Search implementation
└── events_repository.dart       # Alternative Google Custom Search implementation
```

## Quick Start

### 1. Deploy Firestore Rules

```bash
firebase deploy --only firestore:rules
```

### 2. Create Firestore Indexes

Visit Firebase Console → Firestore → Indexes and create:

**Index 1:**
- Collection: `users`
- Fields: `isDiscoverable ==`, `lastActiveAt desc`

**Index 2:**
- Collection: `users`
- Fields: `industries array-contains`, `isDiscoverable ==`, `lastActiveAt desc`

**Index 3:**
- Collection: `connections`
- Fields: `a ==`, `b ==`, `state ==`

Or just run a query and click the auto-generated index creation link!

### 3. Add Provider to App

**File:** `lib/providers/community_provider.dart` (create)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../community/people_repository.dart';

final peopleRepositoryProvider = Provider<PeopleRepository>((ref) {
  return PeopleRepository();
});
```

### 4. Add Suggested Connections to Feed Tab

**File:** `lib/ui/pages/community_page.dart`

In `_buildFeedTab()`, after the search box, add:

```dart
const SizedBox(height: 16),

// Suggested Connections Card
Card(
  elevation: 2,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Suggested Connections',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // Navigate to full people list (optional)
              },
              child: Text('See all', style: TextStyle(color: AppColors.purple)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<UserProfile>>(
          stream: ref.read(peopleRepositoryProvider).suggested(limit: 3),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading suggestions'),
              );
            }

            final users = snapshot.data ?? [];

            if (users.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'No suggestions right now',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            return Column(
              children: users.map((user) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundImage: user.photoURL.isNotEmpty
                        ? NetworkImage(user.photoURL)
                        : null,
                    backgroundColor: AppColors.purple.withOpacity(0.2),
                    child: user.photoURL.isEmpty
                        ? Text(
                            user.displayName[0].toUpperCase(),
                            style: TextStyle(
                              color: AppColors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  title: Text(user.displayName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.headline, style: TextStyle(fontSize: 12)),
                      if (user.mutualConnectionsCount > 0)
                        Text(
                          '${user.mutualConnectionsCount} mutual connections',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                    ],
                  ),
                  trailing: OutlinedButton(
                    onPressed: () async {
                      try {
                        await ref.read(peopleRepositoryProvider).sendRequest(user.uid);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Connection request sent!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.purple,
                      side: BorderSide(color: AppColors.purple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Connect'),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    ),
  ),
),
```

### 5. Import Required Packages

Add to top of `community_page.dart`:

```dart
import '../../community/models.dart';
import '../../community/people_repository.dart';
import '../../providers/community_provider.dart'; // if you created it
```

### 6. Test

Run the app and:
1. Navigate to Community tab
2. Check that News and Events work (they already should!)
3. See Suggested Connections in Feed tab (new!)
4. Click "Connect" on a user

## User Profile Creation

When a user signs up or first logs in, create their profile:

```dart
Future<void> createUserProfile(User firebaseUser) async {
  final profile = UserProfile(
    uid: firebaseUser.uid,
    displayName: firebaseUser.displayName ?? 'User',
    photoURL: firebaseUser.photoURL ?? '',
    headline: 'Entrepreneur', // Can be updated later
    industries: [], // User can select during onboarding
    location: 'Dubai, UAE',
    createdAt: DateTime.now(),
    lastActiveAt: DateTime.now(),
    connectionsCount: 0,
    isDiscoverable: true,
  );

  await FirebaseFirestore.instance
      .collection('users')
      .doc(firebaseUser.uid)
      .set(profile.toFirestore());
}
```

## Testing Checklist

- [ ] Firestore rules deployed
- [ ] Indexes created (3 total)
- [ ] Provider added to app
- [ ] Suggested Connections card shows in Feed
- [ ] Can see user profiles
- [ ] "Connect" button works
- [ ] Mutual connections count displays
- [ ] News tab shows real articles
- [ ] Events tab shows real events
- [ ] No errors in console

## Troubleshooting

**"No suggestions right now"**
- Create test user profiles in Firestore
- Set `isDiscoverable: true`
- Add some `industries`
- Set `lastActiveAt` to recent timestamp

**"Permission denied"**
- Check Firestore rules deployed
- Verify user is signed in
- Check user document exists with `isDiscoverable: true`

**"Index required"**
- Click the auto-generated link in the error
- Or manually create indexes in Firebase Console

**News/Events not showing**
- Check `functions/src/index.ts` for `discoverDubaiEvents`
- Trigger manually: `firebase functions:call discoverDubaiEvents`
- Check Cloud Function logs in Firebase Console

## Performance Tips

1. **Limit suggested users to 3-5** to avoid slow mutual connection calculations
2. **Use `limit` parameter** in Firestore queries
3. **Consider pagination** for full people list page
4. **Cache user profiles** in memory for 5 minutes
5. **Use Cloud Function** for mutual connections if >20 users

## Next Steps

1. ✅ Deploy rules and create indexes
2. ✅ Add provider and UI
3. ⏭️ Create full People list page
4. ⏭️ Add connection request notifications
5. ⏭️ Implement messaging between connections
6. ⏭️ Add user profile detail page

## Support

- **Firebase Console:** https://console.firebase.google.com
- **Firestore Data:** Check `users`, `connections`, `connection_requests` collections
- **Cloud Functions:** Check logs for `discoverDubaiEvents`

---

**Status:** ✅ Ready to integrate

**Estimated Integration Time:** 15-30 minutes

**Breaking Changes:** None (all new features)

**Backward Compatible:** Yes
