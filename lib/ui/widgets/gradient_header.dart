import 'package:flutter/material.dart';
import '../theme.dart';
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
      decoration: const BoxDecoration(gradient: AppColors.gradientHeader),
      clipBehavior: Clip.hardEdge,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showBackButton)
            Padding(
              padding: const EdgeInsets.only(right: 8),
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
          // Icon for the service
          if (icon != null)
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          if (leading != null) leading!,
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ).copyWith(fontSize: titleSize, height: 1.2),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }

  IconData? _getIconForTitle(String title) {
    final lowerTitle = title.toLowerCase();

    // Service-specific icons
    if (lowerTitle.contains('application')) return Icons.assignment;
    if (lowerTitle.contains('import') || lowerTitle.contains('export'))
      return Icons.import_export;
    if (lowerTitle.contains('investor')) return Icons.business_center;
    if (lowerTitle.contains('pitch') || lowerTitle.contains('deck'))
      return Icons.bar_chart;
    if (lowerTitle.contains('government') || lowerTitle.contains('freezone'))
      return Icons.account_balance;
    if (lowerTitle.contains('incentive')) return Icons.stars;
    if (lowerTitle.contains('tender') || lowerTitle.contains('qualification'))
      return Icons.gavel;
    if (lowerTitle.contains('license') || lowerTitle.contains('licensing'))
      return Icons.card_membership;
    if (lowerTitle.contains('registration')) return Icons.app_registration;
    if (lowerTitle.contains('document')) return Icons.description;
    if (lowerTitle.contains('visa') || lowerTitle.contains('immigration'))
      return Icons.card_travel;
    if (lowerTitle.contains('employment')) return Icons.work;
    if (lowerTitle.contains('bank')) return Icons.account_balance;
    if (lowerTitle.contains('tax') || lowerTitle.contains('vat'))
      return Icons.receipt_long;
    if (lowerTitle.contains('audit')) return Icons.assessment;
    if (lowerTitle.contains('legal')) return Icons.balance;
    if (lowerTitle.contains('compliance')) return Icons.verified;
    if (lowerTitle.contains('insurance')) return Icons.shield;
    if (lowerTitle.contains('property') || lowerTitle.contains('real estate'))
      return Icons.home;
    if (lowerTitle.contains('contract')) return Icons.handshake;

    return null; // No icon if no match
  }
}
