import 'package:flutter/material.dart';
import '../../theme/responsive_text.dart';

/// A responsive hero header widget that prevents text-avatar overlap
/// Uses Row + Expanded layout with SafeArea for proper positioning
class HeroHeader extends StatelessWidget {
  final String title; // e.g., 'Welcome Back! 👋'
  final String? brand; // e.g., 'WAZEET'
  final String? subtitle; // e.g., 'Your Business Journey Starts Here'
  final Widget? trailing; // avatar or action buttons
  final EdgeInsets? padding;

  const HeroHeader({
    super.key,
    required this.title,
    this.brand,
    this.subtitle,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: padding ?? const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: rFont(context, sm: 22, md: 26, lg: 30),
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  if (brand != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      brand!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontSize: rFont(context, sm: 18, md: 20, lg: 22),
                            fontWeight: FontWeight.w700,
                            letterSpacing: .4,
                            height: 1.1,
                          ),
                    ),
                  ],
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: rFont(context, sm: 12, md: 13, lg: 14),
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              Align(alignment: Alignment.centerRight, child: trailing!),
            ],
          ],
        ),
      ),
    );
  }
}
