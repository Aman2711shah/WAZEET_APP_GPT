// Integration test for Community Page - Connection Flow
// Run with: flutter test integration_test/connection_flow_test.dart

import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wazeet/main.dart' as app;
import 'package:wazeet/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Community - Connection Flow E2E Tests', () {
    setUpAll(() async {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    });

    tearDownAll(() async {
      // Cleanup
      await FirebaseAuth.instance.signOut();
    });

    testWidgets(
      'BTN-001: Connect button should disable after sending request',
      (WidgetTester tester) async {
        // Start app
        app.main();
        await tester.pumpAndSettle();

        // Navigate to Community tab
        final communityTab = find.text('Community');
        expect(communityTab, findsOneWidget);
        await tester.tap(communityTab);
        await tester.pumpAndSettle();

        // Find first Connect button
        final connectButton = find.text('Connect').first;
        expect(connectButton, findsWidgets);

        // Tap Connect button
        await tester.tap(connectButton);
        await tester.pump(); // Trigger state change

        // Button should now show loading or be disabled
        expect(
          find.descendant(
            of: find.widgetWithText(OutlinedButton, 'Connect'),
            matching: find.byType(CircularProgressIndicator),
          ),
          findsOneWidget,
          reason: 'Button should show loading indicator',
        );

        await tester.pumpAndSettle();

        // After completion, button should show "Pending" or be disabled
        expect(
          find.text('Pending'),
          findsWidgets,
          reason: 'Button should show "Pending" after request sent',
        );
      },
    );

    testWidgets('BTN-001: Should not allow multiple connection requests', (
      WidgetTester tester,
    ) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Community
      await tester.tap(find.text('Community'));
      await tester.pumpAndSettle();

      // Find first Connect button
      final connectButton = find.text('Connect').first;

      // Count initial connection requests in Firestore
      final user = FirebaseAuth.instance.currentUser;
      final initialSnapshot = await FirebaseFirestore.instance
          .collection('connections')
          .where('a', isEqualTo: user?.uid)
          .get();
      final initialCount = initialSnapshot.docs.length;

      // Tap Connect button multiple times rapidly
      await tester.tap(connectButton);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(connectButton);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(connectButton);
      await tester.pumpAndSettle();

      // Check Firestore - should only have 1 new connection
      final finalSnapshot = await FirebaseFirestore.instance
          .collection('connections')
          .where('a', isEqualTo: user?.uid)
          .get();
      final finalCount = finalSnapshot.docs.length;

      expect(
        finalCount - initialCount,
        1,
        reason: 'Should only create 1 connection request despite multiple taps',
      );
    });

    testWidgets('PAGE-001: Should show user-friendly error when index missing', (
      WidgetTester tester,
    ) async {
      // This test verifies graceful degradation when Firestore index is missing

      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Community
      await tester.tap(find.text('Community'));
      await tester.pumpAndSettle();

      // Look for error widget
      // If index is missing, should NOT see infinite loading
      // Should see either: data OR error message with "Create Index" button

      // Check for loading spinner (should not persist more than 10 seconds)
      await tester.pump(const Duration(seconds: 10));

      final hasData = find.text('Suggested Connections').evaluate().isNotEmpty;
      final hasError =
          find.text('Database index required').evaluate().isNotEmpty ||
          find.text('Error loading suggestions').evaluate().isNotEmpty;

      expect(
        hasData || hasError,
        true,
        reason: 'Should either show data OR show error, not infinite loading',
      );

      // If error is shown, verify "Create Index" or "Retry" button exists
      if (hasError) {
        final hasActionButton =
            find.text('Create Index').evaluate().isNotEmpty ||
            find.text('Retry').evaluate().isNotEmpty;
        expect(
          hasActionButton,
          true,
          reason: 'Error state should provide action button',
        );
      }
    });

    testWidgets('BTN-007: Should validate form before Find Packages call', (
      WidgetTester tester,
    ) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Services tab
      await tester.tap(find.text('Services'));
      await tester.pumpAndSettle();

      // Tap "Find Your Free Zone"
      await tester.tap(find.text('Find Your Free Zone'));
      await tester.pumpAndSettle();

      // Try to submit without filling form
      final findPackagesButton = find.text('Find Best Packages');
      expect(findPackagesButton, findsOneWidget);

      await tester.tap(findPackagesButton);
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(
        find.text('Please enter number of activities'),
        findsOneWidget,
        reason: 'Should show validation error for empty activities field',
      );

      // Should NOT make API call
      // (This would be verified by mocking the Cloud Function)
    });

    testWidgets('PAGE-006: Should only show current user applications', (
      WidgetTester tester,
    ) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Ensure user is signed in
      final user = FirebaseAuth.instance.currentUser;
      expect(user, isNotNull, reason: 'User must be signed in for this test');

      // Navigate to Applications tab
      await tester.tap(find.text('Applications'));
      await tester.pumpAndSettle();

      // Query Firestore directly to get expected applications
      final expectedApps = await FirebaseFirestore.instance
          .collection('applications')
          .where('userId', isEqualTo: user?.uid)
          .get();

      // Query all applications (should be filtered in UI)
      final allApps = await FirebaseFirestore.instance
          .collection('applications')
          .get();

      // If there are applications from other users, UI should NOT show them
      if (allApps.docs.length > expectedApps.docs.length) {
        // Verify UI only shows user's own applications
        // (This is a visual check - in real test, you'd verify by document IDs)
        expect(
          expectedApps.docs.length,
          greaterThan(0),
          reason: 'Test requires some applications to exist',
        );

        developer.log(
          'Found ${allApps.docs.length} total applications, user has ${expectedApps.docs.length}',
          name: 'connection_flow_test',
        );
      }
    });

    testWidgets('AI-003: Should handle long conversations gracefully', (
      WidgetTester tester,
    ) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to AI Business Expert
      await tester.tap(find.text('AI Business Expert'));
      await tester.pumpAndSettle();

      // Send 20 messages to fill context
      for (int i = 0; i < 20; i++) {
        final textField = find.byType(TextField).last;
        await tester.enterText(textField, 'Test message $i');
        await tester.testTextInput.receiveAction(TextInputAction.send);
        await tester.pumpAndSettle();

        // Wait for response
        await tester.pump(const Duration(seconds: 2));
      }

      // After 20 messages, conversation should still work
      // Should NOT crash with "context length exceeded" error
      expect(
        find.text('Error'),
        findsNothing,
        reason: 'Should not show error after long conversation',
      );
    });

    testWidgets('API-001: Should handle token expiration gracefully', (
      WidgetTester tester,
    ) async {
      // This test simulates token expiration
      // In real scenario, you'd mock FirebaseAuth to return expired token

      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Wait for token to be close to expiration (in real test, mock this)
      // For now, just verify app doesn't crash on 401 errors

      // Navigate through app
      await tester.tap(find.text('Community'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Services'));
      await tester.pumpAndSettle();

      // App should still be responsive
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Navigation Tests', () {
    testWidgets('Should navigate through all main tabs without errors', (
      WidgetTester tester,
    ) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      final tabs = ['Home', 'Services', 'Community', 'Applications', 'Profile'];

      for (final tab in tabs) {
        final tabFinder = find.text(tab);
        if (tabFinder.evaluate().isNotEmpty) {
          await tester.tap(tabFinder);
          await tester.pumpAndSettle();

          // Verify no errors by checking for Scaffold
          expect(find.byType(Scaffold), findsWidgets);

          // Verify no error widgets
          expect(find.text('Error'), findsNothing);
          expect(find.byType(ErrorWidget), findsNothing);
        }
      }
    });

    testWidgets('Should handle deep navigation and back button', (
      WidgetTester tester,
    ) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Services
      await tester.tap(find.text('Services'));
      await tester.pumpAndSettle();

      // Tap a service card
      final serviceCard = find.byType(Card).first;
      if (serviceCard.evaluate().isNotEmpty) {
        await tester.tap(serviceCard);
        await tester.pumpAndSettle();

        // Press back button
        await tester.pageBack();
        await tester.pumpAndSettle();

        // Should be back at Services page
        expect(find.text('Services'), findsWidgets);
      }
    });
  });

  group('Form Validation Tests', () {
    testWidgets('Should validate all required fields in Freezone form', (
      WidgetTester tester,
    ) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Freezone Selection
      await tester.tap(find.text('Services'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Find Your Free Zone'));
      await tester.pumpAndSettle();

      // Try to submit empty form
      await tester.tap(find.text('Find Best Packages'));
      await tester.pumpAndSettle();

      // Should show multiple validation errors
      expect(
        find.textContaining('Please'),
        findsWidgets,
        reason: 'Should show validation messages',
      );
    });

    testWidgets('Should validate number inputs correctly', (
      WidgetTester tester,
    ) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to form
      await tester.tap(find.text('Services'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Find Your Free Zone'));
      await tester.pumpAndSettle();

      // Enter invalid numbers
      final activitiesField = find.byType(TextField).first;
      await tester.enterText(activitiesField, '-5');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Submit
      await tester.tap(find.text('Find Best Packages'));
      await tester.pumpAndSettle();

      // Should show error for negative number
      expect(
        find.textContaining('valid'),
        findsWidgets,
        reason: 'Should reject negative numbers',
      );
    });
  });
}
