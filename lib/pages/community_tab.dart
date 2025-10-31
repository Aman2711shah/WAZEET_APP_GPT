import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/community_posts_provider.dart';
import '../ui/theme.dart';
import '../ui/widgets/gradient_header.dart';
import '../ui/widgets/search_bar.dart';
import '../ui/widgets/post_card.dart';

class CommunityTab extends ConsumerWidget {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(communityPostsProvider);

    return ListView(
      children: [
        const GradientHeader(title: 'Community'),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const AppSearchBar(hint: 'Search for people or posts'),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.edit, color: AppColors.purple),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('Share an update...')),
                      IconButton(
                        icon: const Icon(Icons.photo),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.image),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...posts.map((post) => PostCard(post: post)),
            ],
          ),
        ),
      ],
    );
  }
}
