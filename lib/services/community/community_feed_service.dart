import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../../models/comment.dart';
import '../../models/post.dart';

class CommunityFeedService {
  CommunityFeedService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _storage = storage;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage? _storage;

  Stream<List<Post>> streamPublicFeed({int limit = 50}) {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<Comment>> streamComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList(),
        );
  }

  Stream<bool> streamLikeStatus(String postId, {String? testUserId}) {
    final uid = _auth.currentUser?.uid ?? testUserId;
    if (uid == null) return Stream<bool>.value(false);

    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists);
  }

  Future<void> toggleLike({
    required String postId,
    required bool currentlyLiked,
    String? testUserId,
  }) async {
    final uid = _auth.currentUser?.uid ?? testUserId;
    if (uid == null) throw Exception('Please sign in to like posts');

    final likeRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(uid);

    if (currentlyLiked) {
      await likeRef.delete();
    } else {
      await likeRef.set({'createdAt': FieldValue.serverTimestamp()});
    }
  }

  Future<void> addComment({
    required String postId,
    required String text,
    String? testUserId,
  }) async {
    final uid = _auth.currentUser?.uid ?? testUserId;
    if (uid == null) throw Exception('Please sign in to comment');

    final profile = await _firestore.collection('profiles').doc(uid).get();
    final profileData = profile.data() ?? {};

    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
          'authorId': uid,
          'authorName':
              profileData['fullName'] ?? profileData['username'] ?? 'Member',
          'authorAvatarUrl': profileData['avatarUrl'],
          'text': text,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> reportPost({
    required String postId,
    required String reason,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Please sign in to report posts');

    await _firestore.collection('reports').add({
      'postId': postId,
      'reporterId': uid,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createPost({
    String? text,
    List<PlatformFile> images = const [],
    String? testAuthorId,
  }) async {
    final uid = _auth.currentUser?.uid ?? testAuthorId;
    if (uid == null) {
      throw Exception('Please sign in before posting');
    }
    if ((text == null || text.trim().isEmpty) && images.isEmpty) {
      throw Exception('Please add text or at least one image');
    }

    final profileSnap = await _firestore.collection('profiles').doc(uid).get();
    final profile = profileSnap.data() ?? {};

    final docRef = _firestore.collection('posts').doc();
    final media = await _uploadImages(docRef.id, images);

    await docRef.set({
      'authorId': uid,
      'author': {
        'fullName': profile['fullName'] ?? profile['username'] ?? 'Member',
        'headline': profile['bio'],
        'avatarUrl': profile['avatarUrl'],
        'isVerified': profile['isVerified'] ?? false,
      },
      'text': text?.trim(),
      'visibility': 'public',
      'media': media.map((m) => m.toJson()).toList(),
      'industries': profile['industries'] ?? const [],
      'likeCount': 0,
      'commentCount': 0,
      'sharesCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<PostMedia>> _uploadImages(
    String postId,
    List<PlatformFile> files,
  ) async {
    if (files.isEmpty) return [];

    final List<PostMedia> media = [];
    for (final file in files) {
      final path = 'posts/$postId/${_randomId()}${_extensionFor(file)}';
      final bytes = file.bytes ?? await File(file.path!).readAsBytes();

      int? width;
      int? height;
      try {
        final descriptor = await ui.instantiateImageCodec(bytes);
        final frame = await descriptor.getNextFrame();
        width = frame.image.width;
        height = frame.image.height;
      } catch (_) {
        // Ignore dimension failures
      }

      final metadata = SettableMetadata(
        contentType: file.extension == 'png' ? 'image/png' : 'image/jpeg',
        customMetadata: {
          'postId': postId,
          'ownerId': _auth.currentUser?.uid ?? '',
          'type': 'image',
          'mime': file.extension == 'png' ? 'image/png' : 'image/jpeg',
          if (width != null) 'width': width.toString(),
          if (height != null) 'height': height.toString(),
        },
      );

      final storage = _storage ?? FirebaseStorage.instance;
      await storage.ref(path).putData(bytes, metadata);
      final url = await storage.ref(path).getDownloadURL();
      media.add(
        PostMedia(
          type: 'image',
          path: path,
          mime: metadata.contentType ?? 'image/jpeg',
          url: url,
          width: width,
          height: height,
        ),
      );
    }
    return media;
  }

  Future<void> seedDevDataIfNeeded() async {
    if (!kDebugMode) return;

    final seedDoc = _firestore.collection('_meta').doc('community_seed_v1');
    final seeded = await seedDoc.get();
    if (seeded.exists) return;

    final batch = _firestore.batch();

    final seedUsers = [
      {
        'uid': 'seed_user_david',
        'fullName': 'David Chen',
        'username': 'david.chen',
        'bio': 'Entrepreneur | WAZEET Founder',
        'avatarUrl': null,
        'isVerified': true,
      },
      {
        'uid': 'seed_user_sarah',
        'fullName': 'Sarah Al Mansouri',
        'username': 'sarah.consults',
        'bio': 'Business Consultant',
        'avatarUrl': null,
        'isVerified': true,
      },
      {
        'uid': 'seed_user_ahmed',
        'fullName': 'Ahmed Hassan',
        'username': 'ahmed.tech',
        'bio': 'Tech Founder',
        'avatarUrl': null,
        'isVerified': false,
      },
    ];

    for (final user in seedUsers) {
      batch.set(
        _firestore.collection('profiles').doc(user['uid'] as String),
        {...user, 'createdAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    }

    await batch.commit();

    final posts = [
      {
        'authorId': 'seed_user_david',
        'text':
            'Excited to announce our new partnership helping startups launch in Dubai Free Zones faster than ever. 🚀',
      },
      {
        'authorId': 'seed_user_sarah',
        'text':
            '50th successful business setup! Grateful for amazing founders who trust our team.',
      },
      {
        'authorId': 'seed_user_ahmed',
        'text':
            'Looking for recommendations: best free zone for AI-focused SaaS? Need remote setup + 2 visas.',
      },
      {
        'authorId': 'seed_user_sarah',
        'text':
            'Sharing a quick checklist for first-time founders in the UAE. Save this for later ✅',
      },
    ];

    for (final post in posts) {
      final docRef = _firestore.collection('posts').doc();
      await docRef.set({
        'authorId': post['authorId'],
        'author': {
          'fullName': seedUsers.firstWhere(
            (user) => user['uid'] == post['authorId'],
          )['fullName'],
          'headline': seedUsers.firstWhere(
            (user) => user['uid'] == post['authorId'],
          )['bio'],
          'avatarUrl': null,
          'isVerified': seedUsers.firstWhere(
            (user) => user['uid'] == post['authorId'],
          )['isVerified'],
        },
        'text': post['text'],
        'visibility': 'public',
        'media': [],
        'likeCount': Random().nextInt(40),
        'commentCount': Random().nextInt(10),
        'sharesCount': Random().nextInt(3),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await seedDoc.set({'seededAt': FieldValue.serverTimestamp()});
  }

  String _extensionFor(PlatformFile file) {
    final ext = file.extension;
    if (ext == null || ext.isEmpty) return '.jpg';
    return '.$ext';
  }

  String _randomId() {
    return _firestore.collection('_').doc().id;
  }
}
