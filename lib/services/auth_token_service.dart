import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service to monitor and refresh Firebase Auth tokens
/// Prevents 401 errors from expired tokens by proactively refreshing
class AuthTokenService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static StreamSubscription<User?>? _authSubscription;
  static Timer? _tokenRefreshTimer;

  // Refresh token 5 minutes before expiry (Firebase tokens last 1 hour)
  static const Duration _refreshInterval = Duration(minutes: 55);

  /// Initialize auth token monitoring
  static void initialize() {
    debugPrint('AuthTokenService: Initializing token refresh monitoring');

    // Listen to auth state changes
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        debugPrint(
          'AuthTokenService: User signed in, starting token refresh timer',
        );
        _startTokenRefreshTimer();
      } else {
        debugPrint(
          'AuthTokenService: User signed out, stopping token refresh timer',
        );
        _stopTokenRefreshTimer();
      }
    });

    // If user is already signed in, start the timer
    if (_auth.currentUser != null) {
      _startTokenRefreshTimer();
    }
  }

  /// Start periodic token refresh timer
  static void _startTokenRefreshTimer() {
    // Cancel existing timer if any
    _stopTokenRefreshTimer();

    // Create new periodic timer
    _tokenRefreshTimer = Timer.periodic(_refreshInterval, (timer) async {
      await _refreshToken();
    });

    // Also refresh immediately to get fresh token
    _refreshToken();
  }

  /// Stop token refresh timer
  static void _stopTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
  }

  /// Manually refresh the auth token
  static Future<void> _refreshToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint(
          'AuthTokenService: No user signed in, skipping token refresh',
        );
        return;
      }

      debugPrint('AuthTokenService: Refreshing auth token...');

      // Force token refresh
      final token = await user.getIdToken(true);

      if (token != null) {
        debugPrint('AuthTokenService: Token refreshed successfully');
      } else {
        debugPrint('AuthTokenService: Token refresh returned null');
      }
    } catch (e) {
      debugPrint('AuthTokenService: Error refreshing token: $e');

      // If token refresh fails, the user might need to re-authenticate
      // You could show a notification or dialog here
    }
  }

  /// Manually trigger a token refresh (useful before critical operations)
  static Future<String?> getValidToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      // Get token with force refresh
      final token = await user.getIdToken(true);
      return token;
    } catch (e) {
      debugPrint('AuthTokenService: Error getting valid token: $e');
      return null;
    }
  }

  /// Check if token is still valid
  static Future<bool> isTokenValid() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Get token result to check expiration
      final tokenResult = await user.getIdTokenResult();
      final expirationTime = tokenResult.expirationTime;

      if (expirationTime == null) return false;

      // Check if token expires in less than 5 minutes
      final now = DateTime.now();
      final timeUntilExpiry = expirationTime.difference(now);

      return timeUntilExpiry.inMinutes > 5;
    } catch (e) {
      debugPrint('AuthTokenService: Error checking token validity: $e');
      return false;
    }
  }

  /// Dispose of resources
  static void dispose() {
    debugPrint('AuthTokenService: Disposing token refresh service');
    _authSubscription?.cancel();
    _stopTokenRefreshTimer();
  }
}
