import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/comment.dart';
import '../models/post.dart';
import '../services/community/community_feed_service.dart';

final communityFeedServiceProvider = Provider<CommunityFeedService>((ref) {
  return CommunityFeedService();
});

final communityFeedSeedProvider = FutureProvider<void>((ref) async {
  await ref.read(communityFeedServiceProvider).seedDevDataIfNeeded();
});

final communityFeedProvider = StreamProvider.autoDispose<List<Post>>((ref) {
  return ref.watch(communityFeedServiceProvider).streamPublicFeed();
});

final postCommentsProvider = StreamProvider.autoDispose
    .family<List<Comment>, String>((ref, postId) {
      return ref.watch(communityFeedServiceProvider).streamComments(postId);
    });

final postLikeStatusProvider = StreamProvider.autoDispose.family<bool, String>((
  ref,
  postId,
) {
  return ref.read(communityFeedServiceProvider).streamLikeStatus(postId);
});

final currentUserProvider = Provider<User?>((ref) {
  return FirebaseAuth.instance.currentUser;
});
