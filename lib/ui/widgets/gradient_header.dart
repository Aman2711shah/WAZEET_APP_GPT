import 'package:flutter/material.dart';
import '../theme.dart';

class GradientHeader extends StatelessWidget {
  final String title;
  final Widget? leading;
  final Widget? trailing;
  final double height;
  final bool showBackButton;

  const GradientHeader({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.height = 160,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 54, 16, 16), // iOS-like top inset
      decoration: const BoxDecoration(gradient: AppColors.gradientHeader),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showBackButton)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          if (leading != null) leading!,
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
