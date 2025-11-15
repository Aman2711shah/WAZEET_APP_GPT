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
            // Background gradient with 3D depth
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6200EE),
                    const Color(0xFF7E3FF2),
                    const Color(0xFF9D4EDD),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
            // Overlay pattern for depth
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
            // Text content with icon
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Icon with 3D effect
                  if (icon != null)
                    Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(-2, -2),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                  // Text with shadow for 3D depth
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
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    offset: const Offset(2, 3),
                                  ),
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
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
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(1, 2),
                                    ),
                                  ],
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
