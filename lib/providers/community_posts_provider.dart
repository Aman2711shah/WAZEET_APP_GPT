import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post.dart';

/// Provider for community posts with Firestore integration
final communityPostsProvider =
    StateNotifierProvider<CommunityPostsNotifier, List<Post>>((ref) {
      return CommunityPostsNotifier();
    });

class CommunityPostsNotifier extends StateNotifier<List<Post>> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CommunityPostsNotifier() : super([]) {
    _loadPosts();
  }

  /// Load posts from Firestore
  Future<void> _loadPosts() async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final posts = snapshot.docs.map((doc) {
        final data = doc.data();
        return Post(
          id: doc.id,
          userId: data['userId'] ?? '',
          userName: data['userName'] ?? 'Anonymous',
          userTitle: data['userTitle'] ?? '',
          userAvatar: data['userAvatar'],
          content: data['content'] ?? '',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          likesCount: data['likesCount'] ?? 0,
          commentsCount: data['commentsCount'] ?? 0,
          sharesCount: data['sharesCount'] ?? 0,
          likedBy: (data['likedBy'] as List<dynamic>?)?.cast<String>() ?? [],
          imageUrl: data['imageUrl'],
          industries: (data['industries'] as List<dynamic>?)?.cast<String>() ?? [],
          isVerified: data['isVerified'] ?? false,
        );
      }).toList();

      state = posts;
    } catch (e) {
      debugPrint('Error loading posts: $e');
      // Load demo posts as fallback
      _loadDemoPosts();
    }
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

  /// Add a new post and save to Firestore
  Future<void> addPost(Post post) async {
    // Optimistically update UI
    state = [post, ...state];

    try {
      // Get current user info
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('Cannot add post: user not authenticated');
        return;
      }

      // Save to Firestore
      await _firestore.collection('posts').doc(post.id).set({
        'userId': post.userId,
        'userName': post.userName,
        'userTitle': post.userTitle,
        'userAvatar': post.userAvatar,
        'content': post.content,
        'createdAt': Timestamp.fromDate(post.createdAt),
        'likesCount': post.likesCount,
        'commentsCount': post.commentsCount,
        'sharesCount': post.sharesCount,
        'likedBy': post.likedBy,
        'imageUrl': post.imageUrl,
        'industries': post.industries,
        'isVerified': post.isVerified,
      });

      debugPrint('Post saved to Firestore successfully');
    } catch (e) {
      debugPrint('Error saving post to Firestore: $e');
      // Post is already in state from optimistic update, so it will still show
    }
  }

  /// Toggle like on a post
  Future<void> toggleLike(String postId, String userId) async {
    // Optimistically update UI
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

    try {
      // Update Firestore
      final post = state.firstWhere((p) => p.id == postId);
      await _firestore.collection('posts').doc(postId).update({
        'likesCount': post.likesCount,
        'likedBy': post.likedBy,
      });
    } catch (e) {
      debugPrint('Error updating like in Firestore: $e');
    }
  }

  /// Increment comment count
  Future<void> incrementComments(String postId) async {
    // Optimistically update UI
    state = state.map((post) {
      if (post.id == postId) {
        return post.copyWith(commentsCount: post.commentsCount + 1);
      }
      return post;
    }).toList();

    try {
      await _firestore.collection('posts').doc(postId).update({
        'commentsCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error updating comment count in Firestore: $e');
    }
  }

  /// Increment share count
  Future<void> incrementShares(String postId) async {
    // Optimistically update UI
    state = state.map((post) {
      if (post.id == postId) {
        return post.copyWith(sharesCount: post.sharesCount + 1);
      }
      return post;
    }).toList();

    try {
      await _firestore.collection('posts').doc(postId).update({
        'sharesCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error updating share count in Firestore: $e');
    }
  }

  /// Refresh posts from Firestore
  Future<void> refresh() async {
    await _loadPosts();
  }
}
