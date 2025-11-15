import 'package:flutter/material.dart';
import '../theme.dart';

/// A reusable page header with background image, gradient overlay, and customizable content
class CustomPageHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final String? backgroundImageUrl;
  final String? fallbackAssetPath;
  final double height;

  const CustomPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.backgroundImageUrl,
    this.fallbackAssetPath,
    this.height = 280,
  });

  @override
  State<CustomPageHeader> createState() => _CustomPageHeaderState();
}

class _CustomPageHeaderState extends State<CustomPageHeader> {
  bool _imageError = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(image: _buildDecorationImage()),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.3),
              AppColors.purple.withValues(alpha: 0.85),
            ],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 54, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 4,
                              color: Colors.black38,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.trailing != null) ...[
                  const SizedBox(width: 16),
                  widget.trailing!,
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  DecorationImage? _buildDecorationImage() {
    // If we've had an error, use fallback asset
    if (_imageError) {
      if (widget.fallbackAssetPath != null) {
        return DecorationImage(
          image: AssetImage(widget.fallbackAssetPath!),
          fit: BoxFit.cover,
        );
      }
      // No fallback asset, return null (will show gradient only)
      return null;
    }

    // Try to use the provided background image URL
    if (widget.backgroundImageUrl != null &&
        widget.backgroundImageUrl!.isNotEmpty) {
      return DecorationImage(
        image: NetworkImage(widget.backgroundImageUrl!),
        fit: BoxFit.cover,
        onError: (exception, stackTrace) {
          // Log the error
          debugPrint('Header image failed to load: $exception');
          debugPrint('Stack trace: $stackTrace');

          // Update state to show fallback
          if (mounted) {
            setState(() {
              _imageError = true;
            });
          }
        },
      );
    }

    // Use fallback asset if no URL provided
    if (widget.fallbackAssetPath != null) {
      return DecorationImage(
        image: AssetImage(widget.fallbackAssetPath!),
        fit: BoxFit.cover,
      );
    }

    // No image available, return null (gradient only)
    return null;
  }
}
