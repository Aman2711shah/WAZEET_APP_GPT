import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';
import 'ui/pages/auth/auth_welcome_page.dart';
import 'ui/pages/auth/verify_email_page.dart';
import 'ui/pages/main_nav.dart';

/// App router that manages navigation based on authentication state
class AppRouter extends StatelessWidget {
  final AuthService authService;

  const AppRouter({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.auth$,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        // No user - show welcome page
        if (user == null) {
          return const AuthWelcomePage();
        }

        // User signed in with email but not verified
        final isEmailProvider = user.providerData.any(
          (info) => info.providerId == 'password',
        );

        if (isEmailProvider && !user.emailVerified) {
          return const VerifyEmailPage();
        }

        // User is authenticated and verified (or using SSO) - show main app
        return const MainNav();
      },
    );
  }
}
