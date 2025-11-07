import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// User preferences model
class UserPreferences {
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;

  const UserPreferences({
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
  });

  factory UserPreferences.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const UserPreferences();
    }
    return UserPreferences(
      emailNotifications: map['emailNotifications'] as bool? ?? true,
      pushNotifications: map['pushNotifications'] as bool? ?? true,
      smsNotifications: map['smsNotifications'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'smsNotifications': smsNotifications,
    };
  }

  UserPreferences copyWith({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
  }) {
    return UserPreferences(
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
    );
  }
}

/// Service for managing user preferences
class UserPreferencesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  String? get _uid => _auth.currentUser?.uid;

  /// Stream of user preferences
  Stream<UserPreferences> get preferences$ {
    if (_uid == null) {
      return Stream.value(const UserPreferences());
    }

    return _firestore.collection('users').doc(_uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      final prefsMap = data?['preferences'] as Map<String, dynamic>?;
      return UserPreferences.fromMap(prefsMap);
    });
  }

  /// Get preferences once
  Future<UserPreferences> getPreferences() async {
    if (_uid == null) {
      return const UserPreferences();
    }

    final doc = await _firestore.collection('users').doc(_uid).get();
    final data = doc.data();
    final prefsMap = data?['preferences'] as Map<String, dynamic>?;
    return UserPreferences.fromMap(prefsMap);
  }

  /// Update email notifications preference
  Future<void> setEmailNotifications(bool enabled) async {
    if (_uid == null) throw Exception('User not authenticated');

    await _firestore.collection('users').doc(_uid).set({
      'preferences': {'emailNotifications': enabled},
    }, SetOptions(merge: true));
  }

  /// Update push notifications preference
  Future<void> setPushNotifications(bool enabled) async {
    if (_uid == null) throw Exception('User not authenticated');

    await _firestore.collection('users').doc(_uid).set({
      'preferences': {'pushNotifications': enabled},
    }, SetOptions(merge: true));
  }

  /// Update SMS notifications preference
  Future<void> setSmsNotifications(bool enabled) async {
    if (_uid == null) throw Exception('User not authenticated');

    await _firestore.collection('users').doc(_uid).set({
      'preferences': {'smsNotifications': enabled},
    }, SetOptions(merge: true));
  }

  /// Update all preferences at once
  Future<void> updatePreferences(UserPreferences prefs) async {
    if (_uid == null) throw Exception('User not authenticated');

    await _firestore.collection('users').doc(_uid).set({
      'preferences': prefs.toMap(),
    }, SetOptions(merge: true));
  }
}
