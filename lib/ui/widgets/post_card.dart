import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../models/post.dart';
import '../../models/user_profile.dart';
import '../../providers/community_feed_provider.dart';
import '../pages/user_profile_detail_page.dart';
import '../theme.dart';

class PostCard extends ConsumerWidget {
  const PostCard({super.key, required this.post, required this.onOpenComments});

  final Post post;
  final VoidCallback onOpenComments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeStatus = ref.watch(postLikeStatusProvider(post.id));
    final isLiked = likeStatus.value ?? false;
    final service = ref.watch(communityFeedServiceProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref),
          if ((post.text ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                post.text!,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
          if ((post.text ?? '').isNotEmpty) const SizedBox(height: 8),
          _buildMediaSection(),
          if (post.industries.isNotEmpty) _buildIndustryTags(),
          _buildStats(),
          const Divider(height: 1),
          Row(
            children: [
              _PostActionButton(
                icon: isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                label: 'Like',
                isActive: isLiked,
                onTap: () => service.toggleLike(
                  postId: post.id,
                  currentlyLiked: isLiked,
                ),
              ),
              _PostActionButton(
                icon: Icons.mode_comment_outlined,
                label: 'Comment',
                onTap: onOpenComments,
              ),
              _PostActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: () => SharePlus.instance.share(
                  ShareParams(
                    text: '${post.authorName} on WAZEET: ${post.text ?? ''}',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _navigateToProfile(context),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.purple.withOpacity(0.1),
              backgroundImage: post.authorAvatarUrl != null
                  ? NetworkImage(post.authorAvatarUrl!)
                  : null,
              child: post.authorAvatarUrl == null
                  ? Text(
                      post.authorName.isNotEmpty
                          ? post.authorName[0].toUpperCase()
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
              onTap: () => _navigateToProfile(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        post.authorName,
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
                  if (post.authorTitle != null)
                    Text(
                      post.authorTitle!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  Text(
                    timeago.format(post.createdAt, locale: 'en_short'),
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () => _showPostOptions(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection() {
    if (post.media.isEmpty) return const SizedBox.shrink();
    final images = post.media.where((m) => m.type == 'image').toList();
    if (images.isEmpty) return const SizedBox.shrink();

    if (images.length == 1) {
      final image = images.first;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            image.url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: images.length.clamp(0, 4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemBuilder: (context, index) {
          final image = images[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              image.url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIndustryTags() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: post.industries
            .map(
              (industry) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  industry,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.purple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
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
    );
  }

  void _showPostOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Save Post'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Post saved!')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Report'),
              onTap: () async {
                Navigator.pop(context);
                final reason = await _promptReportReason(context);
                if (reason != null && reason.isNotEmpty) {
                  await ref
                      .read(communityFeedServiceProvider)
                      .reportPost(postId: post.id, reason: reason);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thanks for the report.')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _promptReportReason(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Tell us what’s wrong'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfileDetailPage(
          profile: UserProfile(
            id: post.authorId,
            name: post.authorName,
            email: 'member@wazeet.com',
            title: post.authorTitle,
            bio: post.text,
            photoUrl: post.authorAvatarUrl,
            industries: post.industries,
            isVerified: post.isVerified,
          ),
        ),
      ),
    );
  }
}

class _PostActionButton extends StatelessWidget {
  const _PostActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 20,
          color: isActive ? AppColors.purple : Colors.grey.shade700,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.purple : Colors.grey.shade700,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
