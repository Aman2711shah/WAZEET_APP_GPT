/// ⚠️ DEPRECATED - DO NOT USE
/// This file is deprecated and will be removed in the next release.
///
/// Admin roles are now managed through Firestore.
/// See lib/services/role_service.dart for the new implementation.
///
/// MIGRATION INSTRUCTIONS:
/// 1. Open Firebase Console
/// 2. Go to Firestore Database
/// 3. Navigate to users collection
/// 4. For each admin user, add/update their document:
///    {
///      "role": "admin"  // or "super_admin"
///      "roleAssignedAt": <current timestamp>
///      "roleAssignedBy": "system_migration"
///    }
///
/// OR use the RoleService programmatically:
/// ```dart
/// final roleService = RoleService();
/// await roleService.setUserRole(
///   userId: 'user_id_here',
///   newRole: UserRoleType.admin,
/// );
/// ```

@Deprecated('Use RoleService from lib/services/role_service.dart instead')
const Set<String> hardcodedAdminEmails = {};

/// ⚠️ DEPRECATED - Use RoleService.getCurrentUserRole() instead
@Deprecated('Use RoleService.getCurrentUserRole() instead')
bool isHardcodedAdminEmail(String? email) {
  return false; // Always returns false - admin roles now in Firestore
}
