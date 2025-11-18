import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_activity.dart';

class UserActivityNotifier extends Notifier<AsyncValue<List<UserActivity>>> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  AsyncValue<List<UserActivity>> build() {
    _init();
    return const AsyncValue.loading();
  }

  void _init() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      state = const AsyncValue.data([]);
      return;
    }

    // Listen to user's activity collection
    // NOTE: Firestore rules use singular 'activity' subcollection
    // match /users/{uid}/activity/{activityId}
    _firestore
        .collection('users')
        .doc(userId)
        .collection('activity')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .listen(
          (snapshot) {
            try {
              final activities = snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return UserActivity.fromJson(data);
              }).toList();
              state = AsyncValue.data(activities);
            } catch (e, stackTrace) {
              state = AsyncValue.error(e, stackTrace);
            }
          },
          onError: (error, stackTrace) {
            state = AsyncValue.error(error, stackTrace);
          },
        );
  }

  Future<void> addActivity(UserActivity activity) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('activity')
        .doc(activity.id)
        .set(activity.toJson());
  }

  Future<void> updateActivity(
    String activityId,
    Map<String, dynamic> updates,
  ) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('activity')
        .doc(activityId)
        .update(updates);
  }

  Future<void> deleteActivity(String activityId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('activity')
        .doc(activityId)
        .delete();
  }

  void refresh() {
    _init();
  }
}

final userActivityProvider =
    NotifierProvider<UserActivityNotifier, AsyncValue<List<UserActivity>>>(
      UserActivityNotifier.new,
    );
