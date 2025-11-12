import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:wazeet/constants/admin_whitelist.dart';

/// User role information
class UserRole {
  final bool isAdmin;
  final String? role;

  const UserRole({this.isAdmin = false, this.role});

  bool get canAccessAdmin => isAdmin;
}

/// Service to manage user roles and permissions
class RoleService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamController<UserRole>? _roleController;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot>? _firestoreSubscription;

  /// Watch user role from both custom claims and Firestore
  Stream<UserRole> watchUserRole() {
    _roleController?.close();
    _roleController = StreamController<UserRole>.broadcast();

    _authSubscription?.cancel();
    _authSubscription = _auth.idTokenChanges().listen((user) async {
      if (user == null) {
        _roleController?.add(const UserRole());
        _firestoreSubscription?.cancel();
        return;
      }
      final bool emailOverrideAdmin = isHardcodedAdminEmail(user.email);

      // Listen to Firestore role changes
      _firestoreSubscription?.cancel();
      _firestoreSubscription = _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((doc) async {
            // Get custom claims
            final idTokenResult = await user.getIdTokenResult(true);
            final customRole = idTokenResult.claims?['role'] as String?;

            // Get Firestore role
            final firestoreRole = doc.data()?['role'] as String?;

            // Check if user is admin from either source
            final isAdmin =
                emailOverrideAdmin ||
                (customRole != null &&
                    (customRole == 'admin' || customRole == 'super_admin')) ||
                (firestoreRole != null &&
                    (firestoreRole == 'admin' ||
                        firestoreRole == 'super_admin'));

            _roleController?.add(
              UserRole(
                isAdmin: isAdmin,
                role:
                    customRole ??
                    firestoreRole ??
                    (emailOverrideAdmin ? 'admin' : null),
              ),
            );
          });
    });

    return _roleController!.stream;
  }

  /// Refresh the user's ID token to get latest custom claims
  Future<void> refreshToken() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.getIdToken(true);
    }
  }

  /// Check if user can access admin features
  Future<bool> canAccessAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    if (isHardcodedAdminEmail(user.email)) {
      return true;
    }

    // Check custom claims
    final idTokenResult = await user.getIdTokenResult(true);
    final customRole = idTokenResult.claims?['role'] as String?;
    if (customRole != null &&
        (customRole == 'admin' || customRole == 'super_admin')) {
      return true;
    }

    // Check Firestore
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final firestoreRole = doc.data()?['role'] as String?;
    if (firestoreRole != null &&
        (firestoreRole == 'admin' || firestoreRole == 'super_admin')) {
      return true;
    }

    return false;
  }

  /// Dispose resources
  void dispose() {
    _authSubscription?.cancel();
    _firestoreSubscription?.cancel();
    _roleController?.close();
  }
}
