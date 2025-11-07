// lib/community/people_repository.dart
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models.dart';

class PeopleRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PeopleRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String? get _currentUid => _auth.currentUser?.uid;

  /// Stream suggested users (real profiles from Firestore)
  Stream<List<UserProfile>> suggested({
    String? industry,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async* {
    if (_currentUid == null) {
      yield [];
      return;
    }

    Query query = _firestore
        .collection('users')
        .where('isDiscoverable', isEqualTo: true)
        .orderBy('lastActiveAt', descending: true)
        .limit(limit);

    if (industry != null && industry != 'All Industries') {
      query = query.where('industries', arrayContains: industry);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    await for (final snapshot in query.snapshots()) {
      final users = snapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .where((user) => user.uid != _currentUid)
          .toList();

      // Compute mutual connections
      await _computeMutualConnections(users);

      yield users;
    }
  }

  /// Compute mutual connections count for a list of users
  Future<void> _computeMutualConnections(List<UserProfile> users) async {
    if (_currentUid == null || users.isEmpty) return;

    try {
      // Get current user's accepted connections
      final myEdgesSnap = await _firestore
          .collection('user_edges')
          .doc(_currentUid)
          .collection('accepted')
          .get();

      final myConnections = myEdgesSnap.docs.map((doc) => doc.id).toSet();

      if (myConnections.isEmpty) {
        // No connections yet, all counts are 0
        return;
      }

      // For each user, get their connections and intersect
      for (final user in users) {
        final theirEdgesSnap = await _firestore
            .collection('user_edges')
            .doc(user.uid)
            .collection('accepted')
            .get();

        final theirConnections = theirEdgesSnap.docs
            .map((doc) => doc.id)
            .toSet();
        final mutualCount = myConnections.intersection(theirConnections).length;

        user.mutualConnectionsCount = mutualCount;
      }
    } catch (e, stack) {
      developer.log(
        'Error computing mutual connections: $e',
        name: 'PeopleRepository',
        error: e,
        stackTrace: stack,
      );
      // Silent fail, counts remain 0
    }
  }

  /// Send connection request
  Future<void> sendRequest(String otherUid) async {
    if (_currentUid == null) throw Exception('Not authenticated');

    final a = _currentUid!.compareTo(otherUid) < 0 ? _currentUid! : otherUid;
    final b = _currentUid!.compareTo(otherUid) < 0 ? otherUid : _currentUid!;
    final docId = '${a}_$b';

    // Check if connection already exists
    final existingDoc = await _firestore
        .collection('connections')
        .doc(docId)
        .get();
    if (existingDoc.exists) {
      final existing = Connection.fromFirestore(existingDoc);
      if (existing.state == ConnectionState.pending) {
        throw Exception('Connection request already sent');
      } else if (existing.state == ConnectionState.accepted) {
        throw Exception('Already connected');
      }
      // If ignored, allow to re-send
    }

    final connection = Connection(
      docId: docId,
      a: a,
      b: b,
      state: ConnectionState.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore
        .collection('connections')
        .doc(docId)
        .set(connection.toFirestore());

    // Also create request doc for quick lookup
    await _firestore
        .collection('connection_requests')
        .doc(otherUid)
        .collection('requests')
        .doc(_currentUid)
        .set({'state': 'pending', 'createdAt': FieldValue.serverTimestamp()});
  }

  /// Accept connection request
  Future<void> acceptRequest(String otherUid) async {
    if (_currentUid == null) throw Exception('Not authenticated');

    final a = _currentUid!.compareTo(otherUid) < 0 ? _currentUid! : otherUid;
    final b = _currentUid!.compareTo(otherUid) < 0 ? otherUid : _currentUid!;
    final docId = '${a}_$b';

    final batch = _firestore.batch();

    // Update connection state
    batch.update(_firestore.collection('connections').doc(docId), {
      'state': 'accepted',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Add to user_edges for both users
    batch.set(
      _firestore
          .collection('user_edges')
          .doc(_currentUid)
          .collection('accepted')
          .doc(otherUid),
      {'addedAt': FieldValue.serverTimestamp()},
    );

    batch.set(
      _firestore
          .collection('user_edges')
          .doc(otherUid)
          .collection('accepted')
          .doc(_currentUid),
      {'addedAt': FieldValue.serverTimestamp()},
    );

    // Increment connection counts
    batch.update(_firestore.collection('users').doc(_currentUid), {
      'connectionsCount': FieldValue.increment(1),
    });

    batch.update(_firestore.collection('users').doc(otherUid), {
      'connectionsCount': FieldValue.increment(1),
    });

    // Update request state
    batch.update(
      _firestore
          .collection('connection_requests')
          .doc(_currentUid)
          .collection('requests')
          .doc(otherUid),
      {'state': 'accepted'},
    );

    await batch.commit();
  }

  /// Ignore connection request
  Future<void> ignoreRequest(String otherUid) async {
    if (_currentUid == null) throw Exception('Not authenticated');

    final a = _currentUid!.compareTo(otherUid) < 0 ? _currentUid! : otherUid;
    final b = _currentUid!.compareTo(otherUid) < 0 ? otherUid : _currentUid!;
    final docId = '${a}_$b';

    final batch = _firestore.batch();

    // Update connection state
    batch.update(_firestore.collection('connections').doc(docId), {
      'state': 'ignored',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update request state
    batch.update(
      _firestore
          .collection('connection_requests')
          .doc(_currentUid)
          .collection('requests')
          .doc(otherUid),
      {'state': 'ignored'},
    );

    await batch.commit();
  }

  /// Get connection state with another user
  Future<ConnectionState?> getConnectionState(String otherUid) async {
    if (_currentUid == null) return null;

    final a = _currentUid!.compareTo(otherUid) < 0 ? _currentUid! : otherUid;
    final b = _currentUid!.compareTo(otherUid) < 0 ? otherUid : _currentUid!;
    final docId = '${a}_$b';

    final doc = await _firestore.collection('connections').doc(docId).get();

    if (!doc.exists) return null;

    final connection = Connection.fromFirestore(doc);
    return connection.state;
  }

  /// Stream pending requests to current user
  Stream<List<UserProfile>> pendingRequests() async* {
    if (_currentUid == null) {
      yield [];
      return;
    }

    await for (final snapshot
        in _firestore
            .collection('connection_requests')
            .doc(_currentUid)
            .collection('requests')
            .where('state', isEqualTo: 'pending')
            .snapshots()) {
      final requesterUids = snapshot.docs.map((doc) => doc.id).toList();

      if (requesterUids.isEmpty) {
        yield [];
        continue;
      }

      // Fetch user profiles
      final profiles = <UserProfile>[];
      for (final uid in requesterUids) {
        try {
          final userDoc = await _firestore.collection('users').doc(uid).get();
          if (userDoc.exists) {
            profiles.add(UserProfile.fromFirestore(userDoc));
          }
        } catch (e, stack) {
          developer.log(
            'Error fetching user $uid: $e',
            name: 'PeopleRepository',
            error: e,
            stackTrace: stack,
          );
        }
      }

      yield profiles;
    }
  }
}
