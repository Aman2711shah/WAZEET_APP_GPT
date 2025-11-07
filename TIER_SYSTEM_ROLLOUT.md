# Service Tier System - Implementation Summary

## ✅ COMPLETED

### Core System (100% Complete)
- [x] **ServiceTier Model** (`lib/models/service_tier.dart`)
  - Data structure for tier information
  - Properties: id, name, price, minDays, maxDays, fastBadge
  - Helper methods: daysLabel, priceLabel
  
- [x] **Tier Rules Engine** (`lib/services/tier_rules.dart`)
  - Global tunable constants for timeline adjustments
  - `adjustedForStandard()` - adds processing time
  - `adjustedForPremium()` - reduces processing time (faster)
  - `buildTiers()` - creates both tiers from base timeline
  - `ctaLabel()` - generates button text
  - `daysRangeLabel()` - formats day ranges

- [x] **ServiceTierCard Component** (`lib/ui/widgets/service_tier_card.dart`)
  - Reusable tier card with purple theme
  - FAST badge for premium (amber with bolt icon)
  - Accessibility support (120px min height, semantic labels)
  - Selection state visual feedback

- [x] **TierSelector Widget** (`lib/ui/widgets/tier_selector.dart`)
  - Manages Standard/Premium selection
  - Side-by-side layout
  - State management
  - onChanged callback

- [x] **Comprehensive Tests** (20 tests, all passing ✅)
  - Unit tests: `test/service_tier_test.dart` (13 tests)
  - Widget tests: `test/tier_selector_widget_test.dart` (7 tests)

- [x] **Documentation**
  - `docs/SERVICE_TIER_SYSTEM.md` - Complete implementation guide
  - `SERVICE_TIER_QUICK_REF.md` - Quick reference

### Applied To
- [x] **SubServiceDetailPage** (`lib/ui/pages/sub_service_detail_page.dart`)
  - Replaced hardcoded tier cards with TierSelector
  - Dynamic timeline calculation from existing data
  - Updated details section to use selected tier
  - CTA button uses ctaLabel()
  - Firestore payload includes structured tier data

## 📋 TODO: Apply to Remaining Service Pages

### Step 1: Find All Service Pages
Run these commands to locate service pages:

```bash
# Find all service-related pages
find lib/ui/pages -name "*service*.dart" -o -name "*issuance*.dart" -o -name "*renewal*.dart" -o -name "*amendment*.dart" -o -name "*cancellation*.dart"

# Search for old tier implementation patterns
grep -r "isPremiumSelected" lib/ui/pages/
grep -r "_buildTierCard" lib/ui/pages/
grep -r "Select.*Tier" lib/ui/pages/
```

### Step 2: Identify Service Pages to Update

Based on typical service structures, look for:
- `lib/ui/pages/services/issuance_page.dart`
- `lib/ui/pages/services/renewal_page.dart`
- `lib/ui/pages/services/amendment_page.dart`
- `lib/ui/pages/services/cancellation_page.dart`
- `lib/ui/pages/visa/visa_issuance_page.dart`
- `lib/ui/pages/license/license_renewal_page.dart`
- Any other `*_service_page.dart` files

### Step 3: Migration Template

For each service page found:

#### A. Add Imports
```dart
import '../../models/service_tier.dart';
import '../../services/tier_rules.dart';
import '../widgets/tier_selector.dart';
```

#### B. Replace State Variables
```dart
// OLD
bool isPremiumSelected = false;
final selectedTier = isPremiumSelected ? premium : standard;

// NEW
late TierPair _tiers;
late ServiceTier _selectedTier;
```

#### C. Update initState
```dart
@override
void initState() {
  super.initState();
  
  // Determine base timeline (service-specific)
  // Option 1: From constants
  const baseMinDays = 5;
  const baseMaxDays = 7;
  
  // Option 2: From Firestore/config
  // final baseMinDays = widget.service.baseMinDays;
  // final baseMaxDays = widget.service.baseMaxDays;
  
  _tiers = buildTiers(
    standardName: 'Standard',
    premiumName: 'Premium',
    baseMinDays: baseMinDays,
    baseMaxDays: baseMaxDays,
    standardPrice: 2000,  // Service-specific
    premiumPrice: 4000,   // Service-specific
  );
  
  _selectedTier = _tiers.standard;
}
```

#### D. Replace Tier Selection UI
```dart
// OLD
Row(
  children: [
    Expanded(child: _buildTierCard(/* standard */)),
    Expanded(child: _buildTierCard(/* premium */)),
  ],
)

// NEW
TierSelector(
  standardTier: _tiers.standard,
  premiumTier: _tiers.premium,
  initialTier: _selectedTier,
  onChanged: (tier) {
    setState(() {
      _selectedTier = tier;
    });
  },
)
```

#### E. Update Details Section
```dart
// OLD
_buildDetailRow(
  label: 'Price',
  value: isPremiumSelected ? 'AED 4000' : 'AED 2000',
)
_buildDetailRow(
  label: 'Processing Time',
  value: isPremiumSelected ? '3-5 days' : '7-10 days',
)

// NEW
_buildDetailRow(
  label: 'Price',
  value: _selectedTier.priceLabel,
)
_buildDetailRow(
  label: 'Processing Time',
  value: _selectedTier.daysLabel,
)
```

#### F. Update CTA Button
```dart
// OLD
Text('Proceed with ${isPremiumSelected ? "Premium" : "Standard"} Tier')

// NEW
Text(ctaLabel(_selectedTier))
```

#### G. Update Firestore Payload
```dart
// OLD
{
  'tier': isPremiumSelected ? 'Premium' : 'Standard',
  'premium': isPremiumSelected,
  'cost': isPremiumSelected ? '4000' : '2000',
  'timeline': isPremiumSelected ? '3-5 days' : '7-10 days',
}

// NEW
{
  'tier': _selectedTier.id,                    // 'standard' | 'premium'
  'processing_min_days': _selectedTier.minDays,
  'processing_max_days': _selectedTier.maxDays,
  'price_aed': _selectedTier.price,
}
```

#### H. Remove Old Method
```dart
// DELETE the entire _buildTierCard method
```

### Step 4: Testing Checklist

For each migrated page:

- [ ] Page loads without errors
- [ ] Both tier cards display correctly
- [ ] Standard tier selected by default
- [ ] Tapping Premium selects it (shows check icon)
- [ ] Tapping Standard selects it back
- [ ] FAST badge shows on Premium tier
- [ ] Details section updates with selected tier
- [ ] CTA button text updates: "Proceed with {Tier} Tier"
- [ ] Firestore submission includes correct tier data
- [ ] Timeline values are logical (Premium faster than Standard)
- [ ] Prices match service pricing
- [ ] Accessibility: Cards have 45px+ tap target
- [ ] Visual: Matches WAZEET purple theme

### Step 5: Validation Commands

After migrating each page:

```bash
# Analyze for errors
flutter analyze lib/ui/pages/services/your_page.dart

# Run app and test
flutter run -d chrome

# Check for remaining old patterns
grep -n "isPremiumSelected" lib/ui/pages/services/your_page.dart
grep -n "_buildTierCard" lib/ui/pages/services/your_page.dart
```

## 🎯 Configuration Per Service

### Base Timeline Examples

Different services have different base processing times:

```dart
// Visa Issuance
baseMinDays: 7, baseMaxDays: 10
// → Standard: 9-13 days, Premium: 5-8 days

// License Renewal
baseMinDays: 3, baseMaxDays: 5
// → Standard: 5-8 days, Premium: 1-3 days

// Document Amendment
baseMinDays: 2, baseMaxDays: 3
// → Standard: 4-6 days, Premium: 1-1 day

// Cancellation
baseMinDays: 5, baseMaxDays: 7
// → Standard: 7-10 days, Premium: 3-5 days
```

### Pricing Examples

Set appropriate prices per service:

```dart
// Budget services
standardPrice: 500, premiumPrice: 1000

// Standard services
standardPrice: 2000, premiumPrice: 4000

// Premium services
standardPrice: 5000, premiumPrice: 8000
```

## 🔧 Tuning Global Settings

To adjust timeline calculations for ALL services:

Edit `lib/services/tier_rules.dart`:

```dart
// Make Standard slower
const kStandardAddMin = 3;  // was 2
const kStandardAddMax = 5;  // was 3

// Make Premium faster
const kPremiumMinusMin = 3;  // was 2
const kPremiumMinusMax = 3;  // was 2

// Or make changes smaller
const kStandardAddMin = 1;  // less difference
const kStandardAddMax = 2;
```

## 📊 Expected Results

After migrating all service pages:

### Consistency
- ✅ Every service uses same tier UI
- ✅ FAST badge appears consistently on Premium
- ✅ Purple theme throughout
- ✅ Same selection behavior

### Data Quality
- ✅ Structured tier data in Firestore
- ✅ Integer prices (not strings)
- ✅ Separate min/max days (not string ranges)
- ✅ Machine-readable tier IDs

### Maintainability
- ✅ One component to update for UI changes
- ✅ Global timeline adjustments via constants
- ✅ Type-safe tier data
- ✅ Comprehensive test coverage

## 🐛 Troubleshooting

### Issue: Timeline calculations seem wrong
**Solution**: Check base timeline values. Premium should have lower numbers than Standard after calculation.

### Issue: FAST badge not showing
**Solution**: Ensure `fastBadge: true` is set on premium tier (automatic with `buildTiers()`).

### Issue: Tier selection not updating UI
**Solution**: Verify `setState()` is called in `onChanged` callback.

### Issue: Old tier cards still showing
**Solution**: Remove old `_buildTierCard` method and replace with `TierSelector` widget.

## 📞 Support

- Documentation: `docs/SERVICE_TIER_SYSTEM.md`
- Quick Reference: `SERVICE_TIER_QUICK_REF.md`
- Tests: `test/service_tier_test.dart`, `test/tier_selector_widget_test.dart`

## 🎉 Success Criteria

✅ **You're done when:**
1. All service pages use `TierSelector` widget
2. No references to `isPremiumSelected` in service pages
3. No `_buildTierCard` methods in service pages
4. `flutter analyze` shows no errors
5. Manual testing confirms all tiers work
6. Firestore payloads have structured tier data

---

**Status**: Core system complete, ready for rollout  
**Next Step**: Find and migrate remaining service pages  
**Priority**: High - Ensures consistent UX across app  
**Estimated Time**: 15-30 min per service page
