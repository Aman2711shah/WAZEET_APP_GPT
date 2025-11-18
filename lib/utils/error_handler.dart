import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Centralized error handling with user-friendly messages
class ErrorHandler {
  /// Convert any error to a user-friendly message
  static String getUserFriendlyMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return _handleFirebaseAuthError(error);
    } else if (error is FirebaseException) {
      return _handleFirebaseError(error);
    } else if (error is String) {
      return error;
    } else if (error is Exception) {
      return _handleGenericException(error);
    }
    return 'Something went wrong. Please try again.';
  }

  /// Get actionable error message with suggested fix
  static ErrorInfo getErrorInfo(dynamic error) {
    final message = getUserFriendlyMessage(error);
    final action = _getSuggestedAction(error);
    final icon = _getErrorIcon(error);

    return ErrorInfo(message: message, suggestedAction: action, icon: icon);
  }

  /// Handle Firebase Auth errors
  static String _handleFirebaseAuthError(FirebaseAuthException error) {
    switch (error.code) {
      // Sign in errors
      case 'user-not-found':
        return 'No account found with this email. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again or reset your password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please try another method.';

      // Sign up errors
      case 'email-already-in-use':
        return 'An account already exists with this email. Please sign in instead.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 8 characters with letters and numbers.';

      // Email verification
      case 'invalid-action-code':
        return 'This verification link has expired or already been used.';
      case 'expired-action-code':
        return 'This verification link has expired. Request a new one.';

      // Password reset
      case 'invalid-credential':
        return 'Your session has expired. Please sign in again.';
      case 'requires-recent-login':
        return 'For security, please sign in again to continue.';

      // Network errors
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';

      // Google Sign-In errors
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method.';
      case 'popup-blocked':
        return 'Pop-up was blocked. Please enable pop-ups for this site.';
      case 'popup-closed-by-user':
        return 'Sign-in cancelled. Please try again.';
      case 'unauthorized-domain':
        return 'This domain is not authorized. Please contact support.';

      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }

  /// Handle Firestore errors
  static String _handleFirebaseError(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'You don\'t have permission to access this data.';
      case 'not-found':
        return 'The requested information could not be found.';
      case 'already-exists':
        return 'This information already exists.';
      case 'failed-precondition':
        return 'Operation cannot be performed at this time. Please try again.';
      case 'aborted':
        return 'Operation was cancelled. Please try again.';
      case 'out-of-range':
        return 'Invalid value provided. Please check your input.';
      case 'unimplemented':
        return 'This feature is not yet available.';
      case 'internal':
        return 'Internal error occurred. Please try again later.';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again in a moment.';
      case 'data-loss':
        return 'Data error occurred. Please contact support.';
      case 'unauthenticated':
        return 'Please sign in to continue.';
      case 'deadline-exceeded':
        return 'Operation timed out. Please check your connection and try again.';
      case 'resource-exhausted':
        return 'Service limit reached. Please try again later.';
      default:
        return error.message ?? 'An error occurred. Please try again.';
    }
  }

  /// Handle generic exceptions
  static String _handleGenericException(Exception error) {
    final message = error.toString();

    if (message.contains('SocketException') ||
        message.contains('NetworkException')) {
      return 'Network error. Please check your internet connection.';
    } else if (message.contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    } else if (message.contains('FormatException')) {
      return 'Invalid data format. Please try again.';
    } else if (message.contains('FileSystemException')) {
      return 'File access error. Please check permissions.';
    }

    return 'An unexpected error occurred. Please try again.';
  }

  /// Get suggested action for error
  static String? _getSuggestedAction(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Create a new account';
        case 'wrong-password':
          return 'Reset password';
        case 'email-already-in-use':
          return 'Sign in instead';
        case 'weak-password':
          return 'Use a stronger password';
        case 'network-request-failed':
          return 'Check connection';
        case 'requires-recent-login':
          return 'Sign in again';
        case 'too-many-requests':
          return 'Wait before retrying';
        default:
          return null;
      }
    } else if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Contact support';
        case 'unavailable':
          return 'Try again later';
        case 'unauthenticated':
          return 'Sign in';
        default:
          return 'Retry';
      }
    }
    return 'Try again';
  }

  /// Get icon for error type
  static IconData _getErrorIcon(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'network-request-failed':
          return Icons.wifi_off;
        case 'user-disabled':
          return Icons.block;
        case 'requires-recent-login':
          return Icons.lock_clock;
        case 'weak-password':
          return Icons.password;
        default:
          return Icons.error_outline;
      }
    } else if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return Icons.lock;
        case 'unavailable':
          return Icons.cloud_off;
        case 'not-found':
          return Icons.search_off;
        default:
          return Icons.error_outline;
      }
    }
    return Icons.error_outline;
  }

  /// Show error snackbar with user-friendly message
  static void showErrorSnackBar(
    BuildContext context,
    dynamic error, {
    Duration duration = const Duration(seconds: 4),
  }) {
    final errorInfo = getErrorInfo(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(errorInfo.icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    errorInfo.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (errorInfo.suggestedAction != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Suggestion: ${errorInfo.suggestedAction}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: duration,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show error dialog with detailed information
  static Future<void> showErrorDialog(
    BuildContext context,
    dynamic error, {
    String? title,
    VoidCallback? onRetry,
  }) async {
    final errorInfo = getErrorInfo(error);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(errorInfo.icon, size: 48, color: Colors.red),
        title: Text(title ?? 'Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(errorInfo.message),
            if (errorInfo.suggestedAction != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 20,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorInfo.suggestedAction!,
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (onRetry != null)
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}

/// Error information with user-friendly details
class ErrorInfo {
  final String message;
  final String? suggestedAction;
  final IconData icon;

  const ErrorInfo({
    required this.message,
    this.suggestedAction,
    required this.icon,
  });
}
