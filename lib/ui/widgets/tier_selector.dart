import 'package:flutter/material.dart';
import '../../models/service_tier.dart';
import 'service_tier_card.dart';

/// Shared tier selector component with Standard and Premium options
///
/// Manages selection state and provides a consistent tier selection UI
/// across all service pages.
///
/// Example usage:
/// ```dart
/// final tiers = buildTiers(
///   standardName: 'Standard',
///   premiumName: 'Premium',
///   baseMinDays: 5,
///   baseMaxDays: 7,
///   standardPrice: 2000,
///   premiumPrice: 4000,
/// );
///
/// TierSelector(
///   standardTier: tiers.standard,
///   premiumTier: tiers.premium,
///   initialTier: tiers.standard,
///   onChanged: (selectedTier) {
///     // Handle tier selection
///   },
/// )
/// ```
class TierSelector extends StatefulWidget {
  /// The standard tier option
  final ServiceTier standardTier;

  /// The premium tier option
  final ServiceTier premiumTier;

  /// Callback when tier selection changes
  final ValueChanged<ServiceTier> onChanged;

  /// Initial selected tier (defaults to standard)
  final ServiceTier? initialTier;

  const TierSelector({
    super.key,
    required this.standardTier,
    required this.premiumTier,
    required this.onChanged,
    this.initialTier,
  });

  @override
  State<TierSelector> createState() => _TierSelectorState();
}

class _TierSelectorState extends State<TierSelector> {
  late ServiceTier _selectedTier;

  @override
  void initState() {
    super.initState();
    _selectedTier = widget.initialTier ?? widget.standardTier;
  }

  @override
  void didUpdateWidget(TierSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset if initial tier changes
    if (widget.initialTier != null &&
        widget.initialTier != oldWidget.initialTier) {
      _selectedTier = widget.initialTier!;
    }
  }

  void _selectTier(ServiceTier tier) {
    if (_selectedTier != tier) {
      setState(() {
        _selectedTier = tier;
      });
      widget.onChanged(tier);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Service Tier',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ServiceTierCard(
                tier: widget.standardTier,
                selected: _selectedTier.id == 'standard',
                onTap: () => _selectTier(widget.standardTier),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ServiceTierCard(
                tier: widget.premiumTier,
                selected: _selectedTier.id == 'premium',
                onTap: () => _selectTier(widget.premiumTier),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
