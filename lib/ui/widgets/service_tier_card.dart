import 'package:flutter/material.dart';
import '../../models/service_tier.dart';
import '../theme.dart';

/// Reusable service tier card component
///
/// Displays a tier option (Standard or Premium) with:
/// - Title and price
/// - Processing timeline with clock icon
/// - Selection state (purple outline when selected)
/// - FAST badge for premium tiers
/// - Accessibility support
class ServiceTierCard extends StatelessWidget {
  /// The tier to display
  final ServiceTier tier;

  /// Whether this tier is currently selected
  final bool selected;

  /// Callback when the card is tapped
  final VoidCallback onTap;

  const ServiceTierCard({
    super.key,
    required this.tier,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPremium = tier.fastBadge;

    return Semantics(
      button: true,
      selected: selected,
      label:
          '${tier.name}, ${tier.priceLabel}, ${tier.daysLabel}${isPremium ? ', fast' : ''}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.purple.withValues(alpha: 0.1)
                : Colors.white,
            border: Border.all(
              color: selected ? AppColors.purple : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.purple.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title row with badge (always for premium) and checkmark
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tier.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: selected ? AppColors.purple : Colors.black,
                      ),
                    ),
                  ),
                  if (isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt,
                            size: 12,
                            color: Colors.amber.shade800,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'FAST',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (selected) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.check_circle, color: AppColors.purple, size: 24),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Price
              Text(
                tier.priceLabel,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: selected ? AppColors.purple : Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              // Timeline with clock icon
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: selected ? AppColors.purple : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      tier.daysLabel,
                      style: TextStyle(
                        fontSize: 14,
                        color: selected
                            ? AppColors.purple
                            : Colors.grey.shade600,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),

              // Note: FAST badge is now always shown in header for premium,
              // so no extra widget here to keep heights consistent.
            ],
          ),
        ),
      ),
    );
  }
}
