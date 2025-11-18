import 'package:firebase_auth/firebase_auth.dart';
import '../utils/error_handler.dart';

/// Service for account-related authentication operations
class AuthAccountService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Reauthenticate user with email and password
  Future<void> reauthenticatePassword(
    String email,
    String currentPassword,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in.';
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw ErrorHandler.getUserFriendlyMessage(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Failed to verify your password. Please try again.';
    }
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in.';
      }

      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw ErrorHandler.getUserFriendlyMessage(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Failed to update password. Please try again.';
    }
  }

  /// Link email/password credential to federated account
  Future<void> linkEmailPassword(String email, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in.';
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: newPassword,
      );

      await user.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw ErrorHandler.getUserFriendlyMessage(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Failed to create password. Please try again.';
    }
  }

  /// Check if user has password provider
  bool hasPasswordProvider() {
    final user = _auth.currentUser;
    if (user == null) return false;

    return user.providerData.any((info) => info.providerId == 'password');
  }

  /// Get user's email
  String? getUserEmail() {
    return _auth.currentUser?.email;
  }
}
