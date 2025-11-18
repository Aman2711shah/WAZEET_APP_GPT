# Error Handling Guide

This guide shows how to use the centralized `ErrorHandler` utility for user-friendly error messages across the WAZEET app.

## Quick Start

### Import the utility
```dart
import 'package:wazeet_app_gpt/utils/error_handler.dart';
```

### Basic Usage

#### Show Error Snackbar (Recommended)
```dart
try {
  await someFirebaseOperation();
} catch (e) {
  if (mounted) {
    ErrorHandler.showErrorSnackBar(context, e);
  }
}
```

#### Show Error Dialog
```dart
try {
  await criticalOperation();
} catch (e) {
  if (mounted) {
    await ErrorHandler.showErrorDialog(
      context,
      e,
      title: 'Operation Failed',
      onRetry: () => criticalOperation(),
    );
  }
}
```

#### Get User-Friendly Message Only
```dart
try {
  await someOperation();
} catch (e) {
  final message = ErrorHandler.getUserFriendlyMessage(e);
  debugPrint(message); // For logging
}
```

#### Get Detailed Error Info
```dart
try {
  await someOperation();
} catch (e) {
  final errorInfo = ErrorHandler.getErrorInfo(e);
  // errorInfo.message - User-friendly message
  // errorInfo.suggestedAction - Actionable suggestion
  // errorInfo.icon - Appropriate icon for error type
}
```

## Supported Error Types

### Firebase Auth Errors
- ✅ `user-not-found` → "No account found with this email..."
- ✅ `wrong-password` → "Incorrect password..."
- ✅ `email-already-in-use` → "An account already exists..."
- ✅ `weak-password` → "Password is too weak..."
- ✅ `network-request-failed` → "Network error. Check connection..."
- ✅ `requires-recent-login` → "For security, please sign in again..."
- And 15+ more Firebase Auth error codes

### Firestore Errors
- ✅ `permission-denied` → "You don't have permission..."
- ✅ `not-found` → "The requested information could not be found..."
- ✅ `unavailable` → "Service temporarily unavailable..."
- ✅ `unauthenticated` → "Please sign in to continue..."
- And 10+ more Firestore error codes

### Generic Errors
- ✅ `SocketException` → "Network error. Check connection..."
- ✅ `TimeoutException` → "Request timed out..."
- ✅ `FormatException` → "Invalid data format..."

## Examples from Codebase

### Auth Welcome Page
```dart
// Before
try {
  await _authService.signInWithGoogle();
} catch (e) {
  setState(() {
    _errorMessage = e.toString(); // Raw error
  });
}

// After
try {
  await _authService.signInWithGoogle();
} catch (e) {
  if (mounted) {
    ErrorHandler.showErrorSnackBar(context, e); // User-friendly
  }
}
```

### Profile Image Upload
```dart
// Before
catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Failed to upload image: ${e.toString()}'),
      backgroundColor: Colors.red,
    ),
  );
}

// After
catch (e) {
  if (mounted) {
    ErrorHandler.showErrorSnackBar(
      context,
      e,
      duration: const Duration(seconds: 6),
    );
  }
}
```

### Password Change Service
```dart
// Before
on FirebaseAuthException catch (e) {
  throw _mapFirebaseError(e); // Custom mapping
}

// After
on FirebaseAuthException catch (e) {
  throw ErrorHandler.getUserFriendlyMessage(e); // Centralized
}
```

## Features

### Automatic Icons
Error messages display context-appropriate icons:
- 🔒 `Icons.lock` - Permission denied
- 📡 `Icons.wifi_off` - Network errors
- 🚫 `Icons.block` - Account disabled
- 🔍 `Icons.search_off` - Not found
- ⚠️ `Icons.error_outline` - General errors

### Suggested Actions
Many errors include actionable suggestions:
- "Wrong password" → **Suggestion: Reset password**
- "User not found" → **Suggestion: Create a new account**
- "Network error" → **Suggestion: Check connection**
- "Requires recent login" → **Suggestion: Sign in again**

### Customization
```dart
// Custom duration
ErrorHandler.showErrorSnackBar(
  context,
  error,
  duration: const Duration(seconds: 10),
);

// Custom dialog title
ErrorHandler.showErrorDialog(
  context,
  error,
  title: 'Upload Failed',
);

// With retry action
ErrorHandler.showErrorDialog(
  context,
  error,
  onRetry: () async {
    await retryOperation();
  },
);
```

## Best Practices

### ✅ DO
- Always check `if (mounted)` before showing UI
- Use `showErrorSnackBar` for non-critical errors
- Use `showErrorDialog` for critical failures that need attention
- Include retry callbacks for recoverable operations
- Let ErrorHandler translate error codes automatically

### ❌ DON'T
- Don't use `e.toString()` directly in UI
- Don't create custom error message mappings (use ErrorHandler)
- Don't show errors without checking `mounted`
- Don't ignore network/timeout errors
- Don't show generic "Something went wrong" when ErrorHandler provides specifics

## Migration Checklist

When refactoring existing error handling:

1. ✅ Add import: `import '../utils/error_handler.dart';`
2. ✅ Replace raw `e.toString()` with `ErrorHandler.getUserFriendlyMessage(e)`
3. ✅ Replace custom SnackBars with `ErrorHandler.showErrorSnackBar()`
4. ✅ Replace custom Dialogs with `ErrorHandler.showErrorDialog()`
5. ✅ Remove custom error mapping functions
6. ✅ Add `mounted` checks for async operations
7. ✅ Test with actual Firebase errors (wrong password, network issues, etc.)

## Testing

```dart
// Test user-friendly messages
test('Firebase auth errors show friendly messages', () {
  final authError = FirebaseAuthException(code: 'user-not-found');
  final message = ErrorHandler.getUserFriendlyMessage(authError);
  
  expect(message, contains('No account found'));
  expect(message, isNot(contains('user-not-found'))); // No error codes
});

// Test error info
test('Error info includes suggestions', () {
  final authError = FirebaseAuthException(code: 'wrong-password');
  final info = ErrorHandler.getErrorInfo(authError);
  
  expect(info.suggestedAction, 'Reset password');
  expect(info.icon, Icons.error_outline);
});
```

## File Locations

- **Error Handler**: `lib/utils/error_handler.dart`
- **Examples**: 
  - `lib/ui/pages/auth/auth_welcome_page.dart`
  - `lib/services/auth_account_service.dart`
  - `lib/ui/pages/edit_profile_page.dart`

## Future Enhancements

Potential improvements:
- [ ] Localization support (i18n)
- [ ] Error analytics tracking
- [ ] Offline error queuing
- [ ] Custom error types for business logic
- [ ] Sentry/Crashlytics integration
