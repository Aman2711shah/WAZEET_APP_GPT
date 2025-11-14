import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import '../utils/platform_helper.dart'
    if (dart.library.io) '../utils/platform_helper_io.dart';

/// Service handling all Firebase authentication operations
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream of auth state changes
  Stream<User?> get auth$ => _auth.authStateChanges();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  /// Sign up with email and password, then send verification email
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Send email verification
      await credential.user?.sendEmailVerification();

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  /// Resend email verification
  Future<void> resendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in.';
      }
      if (user.emailVerified) {
        throw 'Email is already verified.';
      }
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        throw 'Too many requests. Please wait a moment and try again.';
      }
      throw _mapFirebaseError(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Failed to send verification email. Please try again.';
    }
  }

  /// Reload current user to check email verification status
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      debugPrint('Error reloading user: $e');
    }
  }

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      debugPrint('[GoogleSignIn] Starting sign-in flow...');

      // On web, use Firebase's built-in Google auth popup
      if (kIsWeb) {
        debugPrint('[GoogleSignIn] Using web popup flow');
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        return await _auth.signInWithPopup(googleProvider);
      }

      // On mobile, use GoogleSignIn package
      // Get web client ID from google-services.json for proper token validation
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        // Web client ID is automatically read from google-services.json on Android
        // and GoogleService-Info.plist on iOS
      );

      debugPrint('[GoogleSignIn] Triggering account picker...');

      // Trigger the Google authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('[GoogleSignIn] User cancelled sign-in');
        throw FirebaseAuthException(
          code: 'aborted-by-user',
          message: 'User cancelled Google sign-in',
        );
      }

      debugPrint('[GoogleSignIn] User selected: ${googleUser.email}');
      debugPrint('[GoogleSignIn] Obtaining authentication tokens...');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      debugPrint(
        '[GoogleSignIn] ID Token present: ${googleAuth.idToken != null}',
      );
      debugPrint(
        '[GoogleSignIn] Access Token present: ${googleAuth.accessToken != null}',
      );

      if ((googleAuth.idToken == null || googleAuth.idToken!.isEmpty) &&
          (googleAuth.accessToken == null || googleAuth.accessToken!.isEmpty)) {
        debugPrint('[GoogleSignIn] ERROR: No tokens received from Google');
        throw FirebaseAuthException(
          code: 'missing-token',
          message:
              'No idToken/accessToken from Google. Check SHA fingerprints in Firebase Console.',
        );
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint(
        '[GoogleSignIn] Signing in to Firebase with Google credential...',
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      debugPrint(
        '[GoogleSignIn] SUCCESS: Signed in as ${userCredential.user?.email}',
      );
      return userCredential;
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint(
        '[GoogleSignIn][FirebaseAuthException] code=${e.code} message=${e.message}',
      );
      debugPrint('[GoogleSignIn] Stack trace: $stackTrace');

      // Provide specific error messages based on error code
      if (e.code == 'aborted-by-user') {
        throw 'Sign-in cancelled.';
      } else if (e.code == 'missing-token') {
        throw 'Invalid token from Google. Please ensure:\n'
            '1. SHA-1 and SHA-256 fingerprints are added to Firebase\n'
            '2. google-services.json is up to date\n'
            '3. Google Play Services is updated on device';
      }

      throw _mapFirebaseError(e);
    } catch (e, stackTrace) {
      debugPrint('[GoogleSignIn][UnknownError] $e');
      debugPrint('[GoogleSignIn] Stack trace: $stackTrace');

      if (e is String) rethrow;
      throw 'Google sign-in failed. Please try again or use email sign-in.\n'
          'If issue persists, check:\n'
          '- Google Play Services is updated\n'
          '- App has internet connection\n'
          '- Firebase configuration is correct';
    }
  }

  /// Sign in with Apple (iOS only)
  Future<UserCredential> signInWithApple() async {
    if (!isIOS && !kIsWeb) {
      throw 'Apple sign-in is only available on iOS.';
    }

    try {
      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an OAuth credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with the Apple credential
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Update display name if available and not already set
      if (userCredential.user != null &&
          userCredential.user!.displayName == null) {
        final fullName =
            appleCredential.givenName != null &&
                appleCredential.familyName != null
            ? '${appleCredential.givenName} ${appleCredential.familyName}'
            : null;
        if (fullName != null) {
          await userCredential.user!.updateDisplayName(fullName);
        }
      }

      return userCredential;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw 'Apple sign-in was cancelled.';
      }
      throw 'Apple sign-in failed: ${e.message}';
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Apple sign-in failed. Please try again.';
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      final signOutFutures = <Future<void>>[_auth.signOut()];

      // Also sign out from Google on mobile platforms
      if (!kIsWeb) {
        signOutFutures.add(GoogleSignIn().signOut());
      }

      await Future.wait(signOutFutures);
    } catch (e) {
      debugPrint('Error signing out: $e');
      throw 'Failed to sign out. Please try again.';
    }
  }

  /// Reauthenticate with email and password
  Future<void> reauthenticateWithPassword(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw 'No user is currently signed in.';
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Failed to verify your password. Please try again.';
    }
  }

  /// Reauthenticate with Google
  Future<void> reauthenticateWithGoogle() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in.';
      }

      // On web, use Firebase's built-in Google auth popup
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final credential = await _auth.signInWithPopup(googleProvider);
        await user.reauthenticateWithCredential(credential.credential!);
        return;
      }

      // On mobile, use GoogleSignIn package
      final googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw 'Google sign-in was cancelled.';
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Failed to verify your identity. Please try again.';
    }
  }

  /// Reauthenticate with Apple
  Future<void> reauthenticateWithApple() async {
    if (!isIOS && !kIsWeb) {
      throw 'Apple sign-in is only available on iOS.';
    }

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in.';
      }

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      await user.reauthenticateWithCredential(oauthCredential);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw 'Apple sign-in was cancelled.';
      }
      throw 'Apple sign-in failed: ${e.message}';
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Failed to verify your identity. Please try again.';
    }
  }

  /// Change password (requires recent authentication)
  Future<void> changePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in.';
      }

      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Failed to change password. Please try again.';
    }
  }

  /// Enroll SMS MFA
  Future<void> enrollSmsMfa(String phoneNumber) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in.';
      }

      // This will trigger the phone auth flow
      // Implementation depends on your phone verification setup
      throw 'SMS MFA enrollment is not yet implemented. Coming soon!';
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Failed to enroll SMS MFA. Please try again.';
    }
  }

  /// Unenroll MFA factor
  Future<void> unenrollMfa(String factorUid) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in.';
      }

      final enrolledFactors = await user.multiFactor.getEnrolledFactors();
      final factor = enrolledFactors.firstWhere(
        (f) => f.uid == factorUid,
        orElse: () => throw 'MFA factor not found.',
      );

      await user.multiFactor.unenroll(multiFactorInfo: factor);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Failed to remove MFA factor. Please try again.';
    }
  }

  /// Get enrolled MFA factors
  Future<List<MultiFactorInfo>> getEnrolledMfaFactors() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    return user.multiFactor.getEnrolledFactors();
  }

  /// Map Firebase auth errors to user-friendly messages
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      case 'weak-password':
        return 'Password should be at least 6 characters long.';
      case 'invalid-credential':
        return 'The credentials provided are invalid. Please try again.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method. Try signing in with your original method.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'aborted-by-user':
        return 'Sign-in cancelled by user.';
      case 'missing-token':
        return 'Authentication token missing. Please check Firebase configuration.';
      default:
        debugPrint('[Auth] Unmapped error code: ${e.code}');
        return e.message ??
            'An authentication error occurred (${e.code}). Please try again.';
    }
  }
}
