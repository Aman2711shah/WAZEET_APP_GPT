import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// User role types
enum UserRoleType {
  user,
  moderator,
  admin,
  superAdmin;

  /// Check if this role has admin privileges
  bool get isAdmin => this == admin || this == superAdmin;

  /// Check if this role can manage other admins
  bool get canManageAdmins => this == superAdmin;

  /// Convert from string
  static UserRoleType fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'super_admin':
      case 'superadmin':
        return UserRoleType.superAdmin;
      case 'admin':
        return UserRoleType.admin;
      case 'moderator':
        return UserRoleType.moderator;
      default:
        return UserRoleType.user;
    }
  }

  /// Convert to string for storage
  String toStorageString() {
    switch (this) {
      case UserRoleType.superAdmin:
        return 'super_admin';
      case UserRoleType.admin:
        return 'admin';
      case UserRoleType.moderator:
        return 'moderator';
      case UserRoleType.user:
        return 'user';
    }
  }
}

/// User role information
class UserRole {
  final UserRoleType roleType;
  final DateTime? roleAssignedAt;
  final String? assignedBy;

  const UserRole({
    this.roleType = UserRoleType.user,
    this.roleAssignedAt,
    this.assignedBy,
  });

  bool get isAdmin => roleType.isAdmin;
  bool get canAccessAdmin => roleType.isAdmin;
  bool get canManageAdmins => roleType.canManageAdmins;
  String get role => roleType.toStorageString();

  factory UserRole.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) return const UserRole();

    return UserRole(
      roleType: UserRoleType.fromString(data['role'] as String?),
      roleAssignedAt: (data['roleAssignedAt'] as Timestamp?)?.toDate(),
      assignedBy: data['roleAssignedBy'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'role': roleType.toStorageString(),
      'roleAssignedAt': roleAssignedAt != null
          ? Timestamp.fromDate(roleAssignedAt!)
          : FieldValue.serverTimestamp(),
      'roleAssignedBy': assignedBy,
    };
  }
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

            // Get Firestore role (primary source)
            final firestoreData = doc.data();
            final firestoreRole = firestoreData?['role'] as String?;

            // Priority: Firestore > Custom Claims > Default User
            final roleType = UserRoleType.fromString(
              firestoreRole ?? customRole,
            );

            _roleController?.add(
              UserRole(
                roleType: roleType,
                roleAssignedAt: (firestoreData?['roleAssignedAt'] as Timestamp?)
                    ?.toDate(),
                assignedBy: firestoreData?['roleAssignedBy'] as String?,
              ),
            );
          });
    });

    return _roleController!.stream;
  }

  /// Get current user role (one-time check)
  Future<UserRole> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return const UserRole();

    try {
      // Check Firestore first (primary source)
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();

      if (data != null && data['role'] != null) {
        return UserRole.fromFirestore(data);
      }

      // Fallback to custom claims
      final idTokenResult = await user.getIdTokenResult(true);
      final customRole = idTokenResult.claims?['role'] as String?;

      return UserRole(roleType: UserRoleType.fromString(customRole));
    } catch (e) {
      return const UserRole();
    }
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
    final role = await getCurrentUserRole();
    return role.isAdmin;
  }

  /// Set user role (admin only)
  /// Returns error message if operation fails, null on success
  Future<String?> setUserRole({
    required String userId,
    required UserRoleType newRole,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return 'You must be signed in to perform this action';
    }

    // Check if current user has permission
    final currentUserRole = await getCurrentUserRole();
    if (!currentUserRole.canManageAdmins && newRole.isAdmin) {
      return 'Only super admins can assign admin roles';
    }

    if (!currentUserRole.isAdmin) {
      return 'You do not have permission to modify user roles';
    }

    try {
      // Update Firestore
      await _firestore.collection('users').doc(userId).set({
        'role': newRole.toStorageString(),
        'roleAssignedAt': FieldValue.serverTimestamp(),
        'roleAssignedBy': currentUser.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Log the action
      await _logAdminAction(
        action: 'role_changed',
        targetUserId: userId,
        details: {'newRole': newRole.toStorageString()},
      );

      return null; // Success
    } catch (e) {
      return 'Failed to update role: ${e.toString()}';
    }
  }

  /// Remove admin privileges from a user
  Future<String?> revokeAdminAccess(String userId) async {
    return setUserRole(userId: userId, newRole: UserRoleType.user);
  }

  /// Get all admins (for management UI)
  Future<List<Map<String, dynamic>>> getAllAdmins() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', whereIn: ['admin', 'super_admin'])
          .orderBy('roleAssignedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {'userId': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Log admin actions for audit trail
  Future<void> _logAdminAction({
    required String action,
    required String targetUserId,
    Map<String, dynamic>? details,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      await _firestore.collection('admin_audit_log').add({
        'action': action,
        'performedBy': currentUser.uid,
        'performedByEmail': currentUser.email,
        'targetUserId': targetUserId,
        'details': details ?? {},
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silent fail - logging shouldn't break the main operation
    }
  }

  /// Dispose resources
  void dispose() {
    _authSubscription?.cancel();
    _firestoreSubscription?.cancel();
    _roleController?.close();
  }
}
