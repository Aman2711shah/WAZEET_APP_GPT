import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/community_feed_provider.dart';
import '../ui/widgets/gradient_header.dart';
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
          const GradientHeader(title: 'Community'),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const AppSearchBar(hint: 'Search for people or posts'),
                const SizedBox(height: 16),
                ...posts.map(
                  (post) => PostCard(
                    post: post,
                    onOpenComments: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
