import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wazeet/models/service_tier.dart';
import 'package:wazeet/ui/widgets/tier_selector.dart';
import 'package:wazeet/services/tier_rules.dart';

void main() {
  group('TierSelector Widget', () {
    late ServiceTier standardTier;
    late ServiceTier premiumTier;

    setUp(() {
      final tiers = buildTiers(
        standardName: 'Standard',
        premiumName: 'Premium',
        baseMinDays: 5,
        baseMaxDays: 7,
        standardPrice: 2000,
        premiumPrice: 4000,
      );
      standardTier = tiers.standard;
      premiumTier = tiers.premium;
    });

    testWidgets('should render both tier cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TierSelector(
              standardTier: standardTier,
              premiumTier: premiumTier,
              onChanged: (tier) {},
            ),
          ),
        ),
      );

      expect(find.text('Select Service Tier'), findsOneWidget);
      expect(find.text('Standard'), findsOneWidget);
      expect(find.text('Premium'), findsOneWidget);
      expect(find.text('AED 2000'), findsOneWidget);
      expect(find.text('AED 4000'), findsOneWidget);
    });

    testWidgets('should start with standard tier selected by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TierSelector(
              standardTier: standardTier,
              premiumTier: premiumTier,
              onChanged: (tier) {},
            ),
          ),
        ),
      );

      // Standard should be selected (has check icon)
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should call onChanged when premium tier is tapped', (
      WidgetTester tester,
    ) async {
      ServiceTier? selectedTier;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TierSelector(
              standardTier: standardTier,
              premiumTier: premiumTier,
              onChanged: (tier) {
                selectedTier = tier;
              },
            ),
          ),
        ),
      );

      // Tap on premium tier
      await tester.tap(find.text('Premium'));
      await tester.pump();

      expect(selectedTier, isNotNull);
      expect(selectedTier!.id, 'premium');
      expect(selectedTier!.price, 4000);
    });

    testWidgets('should update selection when tier is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TierSelector(
              standardTier: standardTier,
              premiumTier: premiumTier,
              onChanged: (tier) {},
            ),
          ),
        ),
      );

      // Initially standard is selected
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Tap premium
      await tester.tap(find.text('Premium'));
      await tester.pump();

      // Premium should now be selected
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should show FAST badge on premium tier', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TierSelector(
              standardTier: standardTier,
              premiumTier: premiumTier,
              onChanged: (tier) {},
            ),
          ),
        ),
      );

      expect(find.text('FAST'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.bolt), findsAtLeastNWidgets(1));
    });

    testWidgets('should respect initialTier parameter', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TierSelector(
              standardTier: standardTier,
              premiumTier: premiumTier,
              initialTier: premiumTier,
              onChanged: (tier) {},
            ),
          ),
        ),
      );

      // Premium should be selected initially
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should have accessible semantics', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TierSelector(
              standardTier: standardTier,
              premiumTier: premiumTier,
              onChanged: (tier) {},
            ),
          ),
        ),
      );

      // Check for semantic labels
      expect(
        find.bySemanticsLabel(RegExp('Standard.*AED 2000.*7–10 days')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('Premium.*AED 4000.*3–5 days.*fast')),
        findsOneWidget,
      );
    });
  });
}
