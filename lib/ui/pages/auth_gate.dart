import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../pages/auth_page.dart';
import 'main_nav.dart';

/// Authentication gate that shows auth page if user is not signed in
/// and main navigation if user is authenticated
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show main app if user is signed in
        if (snapshot.hasData && snapshot.data != null) {
          return const MainNav();
        }

        // Show auth page if user is not signed in
        return const AuthPage();
      },
    );
  }
}
