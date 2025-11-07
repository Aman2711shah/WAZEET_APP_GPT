# Service Tier System - Quick Reference

## 🎯 What Was Built

A unified tier pricing system for all WAZEET services with:
- **Standard tier**: Slower processing, lower price
- **Premium tier**: Faster processing, higher price, FAST badge

## 📁 Files Created

1. `lib/models/service_tier.dart` - Data model
2. `lib/services/tier_rules.dart` - Timeline calculation logic
3. `lib/ui/widgets/service_tier_card.dart` - Reusable card component
4. `lib/ui/widgets/tier_selector.dart` - Tier selection widget
5. `test/service_tier_test.dart` - Unit tests (13 tests)
6. `test/tier_selector_widget_test.dart` - Widget tests (7 tests)

## 📝 Files Updated

1. `lib/ui/pages/sub_service_detail_page.dart` - Uses new tier system

## ⚙️ How It Works

### Timeline Calculation

Given base timeline (e.g., 5-7 days):

| Tier | Calculation | Result | Badge |
|------|------------|--------|-------|
| **Standard** | Base + 2/3 days | 7-10 days | None |
| **Premium** | Base - 2/2 days | 3-5 days | ⚡ FAST |

### Tunable Constants

```dart
// lib/services/tier_rules.dart
const kStandardAddMin = 2;    // Standard adds 2 days to min
const kStandardAddMax = 3;    // Standard adds 3 days to max
const kPremiumMinusMin = 2;   // Premium subtracts 2 from min
const kPremiumMinusMax = 2;   // Premium subtracts 2 from max
const kMinFloor = 1;          // Never below 1 day
```

## 🚀 Quick Start

### 1. Import
```dart
import '../../models/service_tier.dart';
import '../../services/tier_rules.dart';
import '../widgets/tier_selector.dart';
```

### 2. Create Tiers
```dart
late TierPair _tiers;
late ServiceTier _selectedTier;

@override
void initState() {
  super.initState();
  _tiers = buildTiers(
    standardName: 'Standard',
    premiumName: 'Premium',
    baseMinDays: 5,
    baseMaxDays: 7,
    standardPrice: 2000,
    premiumPrice: 4000,
  );
  _selectedTier = _tiers.standard;
}
```

### 3. Add Widget
```dart
TierSelector(
  standardTier: _tiers.standard,
  premiumTier: _tiers.premium,
  initialTier: _selectedTier,
  onChanged: (tier) => setState(() => _selectedTier = tier),
)
```

### 4. Use Selection
```dart
// In details section
Text(_selectedTier.priceLabel),    // "AED 2000"
Text(_selectedTier.daysLabel),     // "7–10 days"

// In CTA button
Text(ctaLabel(_selectedTier)),     // "Proceed with Standard Tier"

// In Firestore
{
  'tier': _selectedTier.id,                  // 'standard' | 'premium'
  'processing_min_days': _selectedTier.minDays,
  'processing_max_days': _selectedTier.maxDays,
  'price_aed': _selectedTier.price,
}
```

## ✅ Testing

Run tests:
```bash
flutter test test/service_tier_test.dart
flutter test test/tier_selector_widget_test.dart
```

All 20 tests pass ✅

## 🎨 UI Features

- **Standard card**: White, purple outline when selected
- **Premium card**: FAST badge (amber with ⚡ bolt icon)
- **Accessibility**: 120px height, semantic labels
- **Responsive**: Side-by-side layout on all screens

## 📋 Migration Steps

For each service page (`*_service_page.dart`):

1. Remove old `_buildTierCard` method
2. Add imports (models, rules, widget)
3. Create `_tiers` and `_selectedTier` in `initState`
4. Replace tier cards with `TierSelector` widget
5. Update details section to use `_selectedTier`
6. Update CTA button with `ctaLabel(_selectedTier)`
7. Update Firestore payload with tier structure

## 🔍 Finding Service Pages

Search for files to update:
```bash
grep -r "isPremiumSelected" lib/ui/pages/
grep -r "_buildTierCard" lib/ui/pages/
find lib/ui/pages -name "*service*.dart"
```

## 📊 What Gets Saved

Old format:
```dart
{
  'tier': 'Premium',
  'premium': true,
  'cost': '4000',
  'timeline': '3-5 days',
}
```

New format (consistent):
```dart
{
  'tier': 'premium',              // Machine-readable ID
  'processing_min_days': 3,       // Structured data
  'processing_max_days': 5,
  'price_aed': 4000,              // Integer, not string
}
```

## 🎯 Benefits

1. **Consistency**: Same UI across all services
2. **Maintainability**: One component to update
3. **Flexibility**: Tune timelines globally via constants
4. **Testability**: Comprehensive test coverage
5. **Accessibility**: Proper semantics and tap targets
6. **Data Quality**: Structured tier data in Firestore

## 📚 Full Documentation

See `docs/SERVICE_TIER_SYSTEM.md` for:
- Detailed component specifications
- Complete API reference
- Advanced usage patterns
- Migration checklist
- Troubleshooting guide

---

**Status**: ✅ Ready to use  
**Tests**: ✅ 20/20 passing  
**Applied to**: SubServiceDetailPage  
**Remaining**: Other service pages
