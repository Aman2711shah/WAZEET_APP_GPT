import '../models/service_tier.dart';

/// Global tier adjustment constants - easy to tune for all services
const kStandardAddMin = 2; // Add +2 days to standard minimum
const kStandardAddMax = 3; // Add +3 days to standard maximum
const kPremiumMinusMin = 2; // Premium is faster by -2 min days
const kPremiumMinusMax = 2; // Premium is faster by -2 max days
const kMinFloor = 1; // Never go below 1 day

/// Timeline adjustment record type
typedef TimelineAdjustment = ({int min, int max});

/// Adjusts base timeline for Standard tier (slower processing)
///
/// Standard tier adds processing time to the base:
/// - Adds [kStandardAddMin] days to minimum
/// - Adds [kStandardAddMax] days to maximum
///
/// Example:
/// ```dart
/// final adjusted = adjustedForStandard(5, 7);
/// // Returns: (min: 7, max: 10) - Standard is slower
/// ```
TimelineAdjustment adjustedForStandard(int baseMin, int baseMax) {
  return (min: baseMin + kStandardAddMin, max: baseMax + kStandardAddMax);
}

/// Adjusts base timeline for Premium tier (faster processing)
///
/// Premium tier reduces processing time from the base:
/// - Subtracts [kPremiumMinusMin] days from minimum
/// - Subtracts [kPremiumMinusMax] days from maximum
/// - Enforces [kMinFloor] minimum (never below 1 day)
///
/// Example:
/// ```dart
/// final adjusted = adjustedForPremium(5, 7);
/// // Returns: (min: 3, max: 5) - Premium is faster
/// ```
TimelineAdjustment adjustedForPremium(int baseMin, int baseMax) {
  final min = (baseMin - kPremiumMinusMin).clamp(kMinFloor, 999);
  final max = (baseMax - kPremiumMinusMax).clamp(min, 999);
  return (min: min, max: max);
}

/// Formats a day range into a human-readable label
///
/// Examples:
/// - daysRangeLabel(5, 5) => "5 days"
/// - daysRangeLabel(3, 7) => "3–7 days"
/// - daysRangeLabel(1, 1) => "1 day"
String daysRangeLabel(int min, int max) {
  if (min == max) {
    return '$min ${min == 1 ? 'day' : 'days'}';
  }
  return '$min–$max days';
}

/// Record type for tier pair
typedef TierPair = ({ServiceTier standard, ServiceTier premium});

/// Builds both Standard and Premium tiers with adjusted timelines
///
/// Given a base timeline and pricing, this computes:
/// - Standard tier: slower (base + additions)
/// - Premium tier: faster (base - reductions) with FAST badge
///
/// Example:
/// ```dart
/// final tiers = buildTiers(
///   standardName: 'Standard',
///   premiumName: 'Premium',
///   baseMinDays: 5,
///   baseMaxDays: 7,
///   standardPrice: 2000,
///   premiumPrice: 4000,
/// );
/// // Standard: 7-10 days, AED 2000
/// // Premium: 3-5 days, AED 4000, FAST badge
/// ```
TierPair buildTiers({
  required String standardName,
  required String premiumName,
  required int baseMinDays,
  required int baseMaxDays,
  required int standardPrice,
  required int premiumPrice,
}) {
  final standardTimeline = adjustedForStandard(baseMinDays, baseMaxDays);
  final premiumTimeline = adjustedForPremium(baseMinDays, baseMaxDays);

  final standard = ServiceTier(
    id: 'standard',
    name: standardName,
    price: standardPrice,
    minDays: standardTimeline.min,
    maxDays: standardTimeline.max,
    fastBadge: false,
  );

  final premium = ServiceTier(
    id: 'premium',
    name: premiumName,
    price: premiumPrice,
    minDays: premiumTimeline.min,
    maxDays: premiumTimeline.max,
    fastBadge: true,
  );

  return (standard: standard, premium: premium);
}

/// Helper to generate CTA button text
///
/// Example:
/// ```dart
/// ctaLabel(premiumTier) => "Proceed"
/// ```
String ctaLabel(ServiceTier tier) => 'Proceed';
