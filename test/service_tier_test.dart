import 'package:flutter_test/flutter_test.dart';
import 'package:wazeet/models/service_tier.dart';
import 'package:wazeet/services/tier_rules.dart';

void main() {
  group('ServiceTier Model', () {
    test('should create tier with correct properties', () {
      const tier = ServiceTier(
        id: 'standard',
        name: 'Standard',
        price: 2000,
        minDays: 7,
        maxDays: 10,
      );

      expect(tier.id, 'standard');
      expect(tier.name, 'Standard');
      expect(tier.price, 2000);
      expect(tier.minDays, 7);
      expect(tier.maxDays, 10);
      expect(tier.fastBadge, false);
    });

    test('should format days label correctly for range', () {
      const tier = ServiceTier(
        id: 'standard',
        name: 'Standard',
        price: 2000,
        minDays: 5,
        maxDays: 7,
      );

      expect(tier.daysLabel, '5–7 days');
    });

    test('should format days label correctly for single day', () {
      const tier = ServiceTier(
        id: 'premium',
        name: 'Premium',
        price: 4000,
        minDays: 1,
        maxDays: 1,
      );

      expect(tier.daysLabel, '1 day');
    });

    test('should format price label correctly', () {
      const tier = ServiceTier(
        id: 'standard',
        name: 'Standard',
        price: 2500,
        minDays: 5,
        maxDays: 7,
      );

      expect(tier.priceLabel, 'AED 2500');
    });
  });

  group('Tier Rules', () {
    test('adjustedForStandard should add processing days', () {
      final adjusted = adjustedForStandard(5, 7);

      expect(adjusted.min, 7); // 5 + 2
      expect(adjusted.max, 10); // 7 + 3
    });

    test('adjustedForPremium should reduce processing days', () {
      final adjusted = adjustedForPremium(5, 7);

      expect(adjusted.min, 3); // 5 - 2
      expect(adjusted.max, 5); // 7 - 2
    });

    test('adjustedForPremium should enforce minimum floor', () {
      final adjusted = adjustedForPremium(1, 2);

      expect(adjusted.min, 1); // Cannot go below 1
      expect(adjusted.max, 1); // Max clamped to min
    });

    test('daysRangeLabel should format range correctly', () {
      expect(daysRangeLabel(5, 7), '5–7 days');
    });

    test('daysRangeLabel should format single day correctly', () {
      expect(daysRangeLabel(1, 1), '1 day');
      expect(daysRangeLabel(5, 5), '5 days');
    });

    test('buildTiers should create both tiers with adjusted timelines', () {
      final tiers = buildTiers(
        standardName: 'Standard',
        premiumName: 'Premium',
        baseMinDays: 5,
        baseMaxDays: 7,
        standardPrice: 2000,
        premiumPrice: 4000,
      );

      // Standard tier (slower)
      expect(tiers.standard.id, 'standard');
      expect(tiers.standard.name, 'Standard');
      expect(tiers.standard.price, 2000);
      expect(tiers.standard.minDays, 7); // 5 + 2
      expect(tiers.standard.maxDays, 10); // 7 + 3
      expect(tiers.standard.fastBadge, false);

      // Premium tier (faster)
      expect(tiers.premium.id, 'premium');
      expect(tiers.premium.name, 'Premium');
      expect(tiers.premium.price, 4000);
      expect(tiers.premium.minDays, 3); // 5 - 2
      expect(tiers.premium.maxDays, 5); // 7 - 2
      expect(tiers.premium.fastBadge, true);
    });

    test('ctaLabel should generate correct CTA text', () {
      const standard = ServiceTier(
        id: 'standard',
        name: 'Standard',
        price: 2000,
        minDays: 7,
        maxDays: 10,
      );

      const premium = ServiceTier(
        id: 'premium',
        name: 'Premium',
        price: 4000,
        minDays: 3,
        maxDays: 5,
        fastBadge: true,
      );

      expect(ctaLabel(standard), 'Proceed');
      expect(ctaLabel(premium), 'Proceed');
    });
  });

  group('Timeline Consistency', () {
    test('premium should always be faster than standard', () {
      final baseMinDays = 5;
      final baseMaxDays = 7;

      final standard = adjustedForStandard(baseMinDays, baseMaxDays);
      final premium = adjustedForPremium(baseMinDays, baseMaxDays);

      expect(premium.min, lessThan(standard.min));
      expect(premium.max, lessThan(standard.max));
    });

    test('tier adjustments should be symmetric around base', () {
      final baseMinDays = 5;
      final baseMaxDays = 7;

      final standard = adjustedForStandard(baseMinDays, baseMaxDays);
      final premium = adjustedForPremium(baseMinDays, baseMaxDays);

      // Standard adds 2/3, Premium subtracts 2/2
      expect(standard.min - baseMinDays, 2);
      expect(standard.max - baseMaxDays, 3);
      expect(baseMinDays - premium.min, 2);
      expect(baseMaxDays - premium.max, 2);
    });
  });
}
