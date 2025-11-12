const Set<String> hardcodedAdminEmails = {'shah9210722786@gmail.com'};

/// Returns true when the provided email is part of the admin whitelist.
bool isHardcodedAdminEmail(String? email) {
  if (email == null) return false;
  return hardcodedAdminEmails.contains(email.toLowerCase());
}
