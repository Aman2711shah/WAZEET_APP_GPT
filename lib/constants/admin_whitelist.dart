/// Admin email whitelist for temporary admin access control
///
/// ⚠️ WARNING: This is a temporary solution for development/MVP phase
/// TODO: Migrate to Firestore-based role management system for production
///
/// Production recommendations:
/// 1. Store user roles in Firestore: users/{userId}/role = 'admin'
/// 2. Use Firebase Admin SDK to set custom claims
/// 3. Implement proper role hierarchy (admin, super_admin, moderator, etc.)
/// 4. Add audit logging for admin actions
/// 5. Remove this hardcoded whitelist entirely
///
/// Current behavior:
/// - Users in this set bypass role checks in RoleService
/// - Should only be used during initial setup
/// - MUST be removed before production deployment
const Set<String> hardcodedAdminEmails = {
  'shah9210722786@gmail.com', // TODO: Remove before production
};

/// Returns true when the provided email is part of the admin whitelist.
/// This is a temporary development feature and should not be used in production.
bool isHardcodedAdminEmail(String? email) {
  if (email == null) return false;
  return hardcodedAdminEmails.contains(email.toLowerCase());
}
