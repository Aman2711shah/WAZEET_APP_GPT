import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/post.dart';
import '../../models/user_profile.dart';
import '../../providers/community_posts_provider.dart';
import '../theme.dart';
import '../pages/user_profile_detail_page.dart';

class PostCard extends ConsumerWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiked = post.likedBy.contains('demo_user');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _navigateToProfile(context, post),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.purple.withOpacity(0.1),
                    backgroundImage: post.userPhotoUrl != null
                        ? NetworkImage(post.userPhotoUrl!)
                        : null,
                    child: post.userPhotoUrl == null
                        ? Text(
                            post.userName.isNotEmpty
                                ? post.userName[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              color: AppColors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _navigateToProfile(context, post),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              post.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            if (post.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 16,
                              ),
                            ],
                          ],
                        ),
                        if (post.userTitle != null)
                          Text(
                            post.userTitle!,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        Text(
                          timeago.format(post.createdAt, locale: 'en_short'),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () => _showPostOptions(context),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              post.content,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
          const SizedBox(height: 8),

          // Industry Tags
          if (post.industries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: post.industries.map((industryId) {
                  final industry = availableIndustries.firstWhere(
                    (i) => i.id == industryId,
                    orElse: () => Industry(
                      id: industryId,
                      name: industryId,
                      icon: '📊',
                      description: '',
                    ),
                  );
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          industry.icon,
                          style: const TextStyle(fontSize: 10),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          industry.name,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.purple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 8),

          // Image (if any)
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            Image.network(
              post.imageUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),

          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                if (post.likesCount > 0) ...[
                  Icon(Icons.thumb_up, size: 14, color: AppColors.purple),
                  const SizedBox(width: 4),
                  Text(
                    '${post.likesCount}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
                const Spacer(),
                if (post.commentsCount > 0)
                  Text(
                    '${post.commentsCount} comments',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                if (post.commentsCount > 0 && post.sharesCount > 0)
                  Text(
                    ' • ',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                if (post.sharesCount > 0)
                  Text(
                    '${post.sharesCount} shares',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Actions
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    ref
                        .read(communityPostsProvider.notifier)
                        .toggleLike(post.id, 'demo_user');
                  },
                  icon: Icon(
                    isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    size: 20,
                    color: isLiked ? AppColors.purple : Colors.grey.shade700,
                  ),
                  label: Text(
                    'Like',
                    style: TextStyle(
                      color: isLiked ? AppColors.purple : Colors.grey.shade700,
                      fontWeight: isLiked ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showComments(context, ref),
                  icon: Icon(
                    Icons.comment_outlined,
                    size: 20,
                    color: Colors.grey.shade700,
                  ),
                  label: Text(
                    'Comment',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _sharePost(context, ref),
                  icon: Icon(
                    Icons.share_outlined,
                    size: 20,
                    color: Colors.grey.shade700,
                  ),
                  label: Text(
                    'Share',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _sendPost(context),
                  icon: Icon(
                    Icons.send_outlined,
                    size: 20,
                    color: Colors.grey.shade700,
                  ),
                  label: Text(
                    'Send',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark_outline),
              title: const Text('Save post'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Post saved!')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copy link'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Link copied!')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_outlined),
              title: const Text('Report post'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Post reported')));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showComments(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Comments',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildComment('Sarah Al Mansouri', 'Great post! 👍', '2h'),
                    _buildComment('Ahmed Hassan', 'Very insightful', '5h'),
                    _buildComment('John Smith', 'Thanks for sharing!', '1d'),
                  ],
                ),
              ),
              const Divider(),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    child: Icon(Icons.person, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty) {
                          ref
                              .read(communityPostsProvider.notifier)
                              .incrementComments(post.id);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Comment added!')),
                          );
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: AppColors.purple),
                    onPressed: () {
                      ref
                          .read(communityPostsProvider.notifier)
                          .incrementComments(post.id);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Comment added!')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComment(String name, String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.purple.withOpacity(0.1),
            child: Text(
              name[0],
              style: TextStyle(color: AppColors.purple, fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(text, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Row(
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Like',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Reply',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sharePost(BuildContext context, WidgetRef ref) {
    ref.read(communityPostsProvider.notifier).incrementShares(post.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post shared to your network!')),
    );
  }

  void _sendPost(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Send via message feature coming soon!')),
    );
  }

  void _navigateToProfile(BuildContext context, Post post) {
    // Create a demo profile for the user
    final profile = UserProfile(
      id: post.userId,
      name: post.userName,
      email: '${post.userName.toLowerCase().replaceAll(' ', '.')}@example.com',
      title: post.userTitle,
      photoUrl: post.userPhotoUrl,
      company: 'Business Owner',
      location: 'Dubai, UAE',
      bio: 'Passionate about business growth and innovation in the UAE market.',
      industries: post.industries,
      skills: ['Business Strategy', 'Networking', 'Entrepreneurship'],
      connectionsCount: 250,
      followersCount: 180,
      postsCount: 42,
      joinedDate: DateTime(2024, 1, 15),
      isVerified: post.isVerified,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileDetailPage(profile: profile),
      ),
    );
  }
}
