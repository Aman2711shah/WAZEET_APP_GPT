import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/community_feed_provider.dart';
import '../ui/widgets/promotional_banner.dart';
import '../ui/widgets/search_bar.dart';
import '../ui/widgets/post_card.dart';

class CommunityTab extends ConsumerWidget {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(communityFeedProvider);

    return feed.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error loading feed: $error')),
      data: (posts) => ListView(
        children: [
          const PromotionalBanner(
            title: 'Grow your network in Dubai',
            subtitle: 'Join events, connect with founders, find partners',
            height: 180,
            imageUrl:
                'https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=1600&h=800&fit=crop',
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const AppSearchBar(hint: 'Search for people or posts'),
                const SizedBox(height: 16),
                ...posts.map(
                  (post) => PostCard(post: post, onOpenComments: () {}),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
