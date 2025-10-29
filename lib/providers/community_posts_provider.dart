import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';

/// Provider for community posts with in-memory storage (demo mode)
final communityPostsProvider =
    StateNotifierProvider<CommunityPostsNotifier, List<Post>>((ref) {
      return CommunityPostsNotifier();
    });

class CommunityPostsNotifier extends StateNotifier<List<Post>> {
  CommunityPostsNotifier() : super([]) {
    _loadDemoPosts();
  }

  void _loadDemoPosts() {
    // Add some demo posts with industry tags
    state = [
      Post(
        id: '1',
        userId: 'demo_user',
        userName: 'David Chen',
        userTitle: 'Entrepreneur',
        content:
            'Excited to announce that WAZEET is now live in Dubai! We\'re making business setup easier than ever. 🚀',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likesCount: 24,
        commentsCount: 5,
        sharesCount: 3,
        likedBy: [],
        industries: ['tech', 'consulting'],
        isVerified: true,
      ),
      Post(
        id: '2',
        userId: 'user2',
        userName: 'Sarah Al Mansouri',
        userTitle: 'Business Consultant',
        content:
            'Just completed my 50th successful business setup in Dubai! Grateful for the amazing clients and partners. 🙏',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likesCount: 42,
        commentsCount: 8,
        sharesCount: 2,
        likedBy: [],
        industries: ['consulting', 'finance'],
        isVerified: true,
      ),
      Post(
        id: '3',
        userId: 'user3',
        userName: 'Ahmed Hassan',
        userTitle: 'Startup Founder',
        content:
            'Looking for recommendations on the best free zones for tech startups in Dubai. Any insights? 💭',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likesCount: 18,
        commentsCount: 12,
        sharesCount: 1,
        likedBy: [],
        industries: ['tech', 'realestate'],
        isVerified: false,
      ),
    ];
  }

  void addPost(Post post) {
    state = [post, ...state];
  }

  void toggleLike(String postId, String userId) {
    state = state.map((post) {
      if (post.id == postId) {
        final isLiked = post.likedBy.contains(userId);
        return post.copyWith(
          likesCount: isLiked ? post.likesCount - 1 : post.likesCount + 1,
          likedBy: isLiked
              ? post.likedBy.where((id) => id != userId).toList()
              : [...post.likedBy, userId],
        );
      }
      return post;
    }).toList();
  }

  void incrementComments(String postId) {
    state = state.map((post) {
      if (post.id == postId) {
        return post.copyWith(commentsCount: post.commentsCount + 1);
      }
      return post;
    }).toList();
  }

  void incrementShares(String postId) {
    state = state.map((post) {
      if (post.id == postId) {
        return post.copyWith(sharesCount: post.sharesCount + 1);
      }
      return post;
    }).toList();
  }
}
