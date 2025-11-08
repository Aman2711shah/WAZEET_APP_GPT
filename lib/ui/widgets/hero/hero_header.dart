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
    final theme = Theme.of(context);
    return SafeArea(
      bottom: false,
      child: Container(
        decoration: BoxDecoration(
          // Multi-layer glow / depth effect using radial gradients & blur
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6D28D9), // deep purple
              Color(0xFF7C3AED), // vivid purple
              Color(0xFFA78BFA), // light purple
            ],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Larger soft glow circle
            Positioned(
              left: -40,
              top: -60,
              child: _GlowCircle(size: 220, color: const Color(0xFFB794F4)),
            ),
            Positioned(
              right: -30,
              top: -40,
              child: _GlowCircle(size: 160, color: const Color(0xFFA78BFA)),
            ),
            Positioned(right: 40, bottom: -30, child: _GlassOrb(size: 120)),
            // Content with subtle inner glow card
            Padding(
              padding: padding ?? const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShaderMask(
                          shaderCallback: (rect) => const LinearGradient(
                            colors: [
                              Colors.white,
                              Color(0xFFE3D9FF),
                              Colors.white,
                            ],
                          ).createShader(rect),
                          blendMode: BlendMode.srcIn,
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: rFont(context, sm: 26, md: 30, lg: 34),
                              fontWeight: FontWeight.w800,
                              letterSpacing: .6,
                              height: 1.05,
                            ),
                          ),
                        ),
                        if (brand != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            brand!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontSize: rFont(context, sm: 20, md: 22, lg: 24),
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withOpacity(.92),
                              shadows: [
                                const Shadow(
                                  color: Color(0x55FFFFFF),
                                  blurRadius: 12,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (subtitle != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withOpacity(.25),
                                width: 0.7,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF7C3AED,
                                  ).withOpacity(.35),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.rocket_launch_rounded,
                                  size: rFont(context, sm: 14, md: 16, lg: 18),
                                  color: Colors.white.withOpacity(.9),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    subtitle!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: rFont(
                                        context,
                                        sm: 13,
                                        md: 14,
                                        lg: 15,
                                      ),
                                      fontWeight: FontWeight.w600,
                                      height: 1.25,
                                      color: Colors.white.withOpacity(.9),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 20),
                    AnimatedScale(
                      scale: 1,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutBack,
                      child: _ElevatedAvatar(child: trailing!),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowCircle({required this.size, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(.55),
            color.withOpacity(.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}

class _GlassOrb extends StatelessWidget {
  final double size;
  const _GlassOrb({required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x66FFFFFF), Color(0x22FFFFFF), Color(0x11FFFFFF)],
        ),
        border: Border.all(color: Colors.white.withOpacity(.35), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(.35),
            blurRadius: 40,
            spreadRadius: 6,
            offset: const Offset(0, 18),
          ),
        ],
      ),
    );
  }
}

class _ElevatedAvatar extends StatelessWidget {
  final Widget child;
  const _ElevatedAvatar({required this.child});
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFFA78BFA).withOpacity(.5),
            blurRadius: 32,
            spreadRadius: -4,
          ),
        ],
      ),
      child: child,
    );
  }
}
