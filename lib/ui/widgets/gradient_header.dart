import 'package:flutter/material.dart';
import '../responsive.dart';

class GradientHeader extends StatelessWidget {
  final String title;
  final Widget? leading;
  final Widget? trailing;
  final double? height;
  final bool showBackButton;

  const GradientHeader({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.height,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? Responsive.heroHeight(context);
    final titleSize = Responsive.clampFont(
      context,
      min: 18,
      vw: 4,
      max: 24,
    ); // Reduced font sizes
    final icon = _getIconForTitle(title);

    return Container(
      height: effectiveHeight,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 12), // Reduced padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            Color(0xFF6200EE),
            Color(0xFF7E3FF2),
            Color(0xFF9D4EDD),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: const Color(0xFF6200EE).withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Overlay pattern for depth with enhanced gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.25),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Shine effect overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4],
                ),
              ),
            ),
          ),
          // Content
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (showBackButton)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
              // Icon for the service with 3D effect
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
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(-3, -3),
                      ),
                      BoxShadow(
                        color: const Color(0xFF6200EE).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
              if (leading != null) leading!,
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: titleSize,
                    height: 1.2,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ],
      ),
    );
  }

  IconData? _getIconForTitle(String title) {
    final lowerTitle = title.toLowerCase();

    // Specific sub-service icons (more detailed matching)
    if (lowerTitle.contains('issuance') || lowerTitle.contains('issue')) {
      return Icons.assignment_turned_in;
    }
    if (lowerTitle.contains('renewal') || lowerTitle.contains('renew')) {
      return Icons.autorenew;
    }
    if (lowerTitle.contains('cancellation') || lowerTitle.contains('cancel')) {
      return Icons.cancel_presentation;
    }
    if (lowerTitle.contains('open account') || lowerTitle == 'open account') {
      return Icons.account_balance_wallet;
    }
    if (lowerTitle.contains('status change') ||
        lowerTitle.contains('change status')) {
      return Icons.swap_horiz;
    }
    if (lowerTitle.contains('amendment') || lowerTitle.contains('modify')) {
      return Icons.edit_note;
    }
    if (lowerTitle.contains('transfer')) return Icons.sync_alt;
    if (lowerTitle.contains('extension') || lowerTitle.contains('extend')) {
      return Icons.schedule;
    }
    if (lowerTitle.contains('replacement') || lowerTitle.contains('replace')) {
      return Icons.find_replace;
    }

    // Service-specific icons
    if (lowerTitle.contains('application')) return Icons.assignment;
    if (lowerTitle.contains('import') || lowerTitle.contains('export')) {
      return Icons.import_export;
    }
    if (lowerTitle.contains('investor')) return Icons.business_center;
    if (lowerTitle.contains('pitch') || lowerTitle.contains('deck')) {
      return Icons.bar_chart;
    }
    if (lowerTitle.contains('government') || lowerTitle.contains('freezone')) {
      return Icons.account_balance;
    }
    if (lowerTitle.contains('incentive')) return Icons.stars;
    if (lowerTitle.contains('tender') || lowerTitle.contains('qualification')) {
      return Icons.gavel;
    }
    if (lowerTitle.contains('license') || lowerTitle.contains('licensing')) {
      return Icons.card_membership;
    }
    if (lowerTitle.contains('registration')) return Icons.app_registration;
    if (lowerTitle.contains('document')) return Icons.description;
    if (lowerTitle.contains('visa') || lowerTitle.contains('immigration')) {
      return Icons.card_travel;
    }
    if (lowerTitle.contains('employment')) return Icons.work;
    if (lowerTitle.contains('bank')) return Icons.account_balance;
    if (lowerTitle.contains('tax') || lowerTitle.contains('vat')) {
      return Icons.receipt_long;
    }
    if (lowerTitle.contains('audit')) return Icons.assessment;
    if (lowerTitle.contains('legal')) return Icons.balance;
    if (lowerTitle.contains('compliance')) return Icons.verified;
    if (lowerTitle.contains('insurance')) return Icons.shield;
    if (lowerTitle.contains('property') || lowerTitle.contains('real estate')) {
      return Icons.home;
    }
    if (lowerTitle.contains('contract')) return Icons.handshake;

    return Icons.description; // Default icon instead of null
  }
}
