import 'package:flutter/material.dart';
import '../../theme/responsive_text.dart';

/// Service header with background image and gradient overlay
/// Displays service title with relevant imagery for visual context
class ServiceHeader extends StatelessWidget {
  final String title; // e.g., 'Visa & Immigration'
  final String? subtitle; // e.g., '5 services available'
  final String serviceKey; // canonical key for image mapping

  const ServiceHeader({
    super.key,
    required this.title,
    required this.serviceKey,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const height = 120.0; // Reduced height for more compact header
    final icon = _iconFor(serviceKey);

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background gradient (no image for cleaner look)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF6200EE), const Color(0xFF9D4EDD)],
                ),
              ),
            ),
            // Text content with icon
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Icon
                  if (icon != null)
                    Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: rFont(
                                  context,
                                  sm: 20,
                                  md: 22,
                                  lg: 24,
                                ),
                              ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white70,
                                  fontSize: rFont(
                                    context,
                                    sm: 12,
                                    md: 13,
                                    lg: 14,
                                  ),
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Maps service key to appropriate icon
IconData? _iconFor(String key) {
  switch (key.toLowerCase()) {
    case 'visa':
    case 'visa_immigration':
      return Icons.card_travel;
    case 'banking':
    case 'banking_services':
      return Icons.account_balance;
    case 'company_setup':
      return Icons.business;
    case 'community':
      return Icons.groups;
    case 'services':
      return Icons.miscellaneous_services;
    case 'issuance':
      return Icons.assignment_turned_in;
    case 'renewal':
      return Icons.refresh;
    case 'cancellation':
      return Icons.cancel;
    case 'status_change':
      return Icons.swap_horiz;
    default:
      return Icons.description;
  }
}
