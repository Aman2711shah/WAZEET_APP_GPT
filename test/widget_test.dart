// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wazeet/pages/auth_page.dart';

void main() {
  testWidgets('Auth page UI test', (WidgetTester tester) async {
    // Test the AuthPage widget directly
    await tester.pumpWidget(const MaterialApp(home: AuthPage()));

    // Verify that the auth page elements are displayed.
    expect(find.text('WAZEET'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
