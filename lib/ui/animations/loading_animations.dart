import 'package:flutter/material.dart';
import '../theme.dart';

/// Shimmer loading effect widget
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? AppColors.darkCard
        : AppColors.backgroundSecondary;
    final highlightColor = isDark ? AppColors.darkCardElevated : Colors.white;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius:
                widget.borderRadius ?? BorderRadius.circular(AppRadius.md),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [0.0, 0.5 + (_animation.value * 0.25), 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Pulsing loading animation
class PulsingLoading extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const PulsingLoading({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<PulsingLoading> createState() => _PulsingLoadingState();
}

class _PulsingLoadingState extends State<PulsingLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}

/// Spinning loading indicator
class SpinningLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const SpinningLoader({
    super.key,
    this.size = 24,
    this.color,
    this.strokeWidth = 3,
  });

  @override
  State<SpinningLoader> createState() => _SpinningLoaderState();
}

class _SpinningLoaderState extends State<SpinningLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(
          strokeWidth: widget.strokeWidth,
          color: widget.color ?? AppColors.purple,
          backgroundColor: (widget.color ?? AppColors.purple).withValues(
            alpha: 0.2,
          ),
        ),
      ),
    );
  }
}

/// Skeleton loader for cards
class SkeletonCard extends StatelessWidget {
  final double? height;

  const SkeletonCard({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkBorder
              : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerLoading(
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading(
                      width: double.infinity,
                      height: 16,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    ShimmerLoading(
                      width: 120,
                      height: 12,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ],
                ),
              ),
              ShimmerLoading(
                width: 80,
                height: 28,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
