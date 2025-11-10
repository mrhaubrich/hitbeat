import 'package:flutter/material.dart';

/// {@template animated_logo}
/// A widget that displays a Flutter logo that rotates and scales.
/// {@endtemplate}
class AnimatedLogo extends StatelessWidget {
  /// {@macro animated_logo}
  const AnimatedLogo({
    required this.extended,
    super.key,
  });

  /// Whether the logo is extended.
  final bool extended;

  static const _asset = AssetImage('assets/logo/hitbeat-icon.png');

  @override
  Widget build(BuildContext context) {
    // Lighter animation: scale-only (remove rotation) and shorter duration.
    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        tween: Tween<double>(
          begin: 0,
          end: extended ? 1 : 0,
        ),
        child: const Image(
          image: _asset,
          width: 48,
          height: 48,
          filterQuality: FilterQuality.low,
        ),
        builder: (context, value, child) {
          final scale = 1 + (value * 0.12);
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
      ),
    );
  }
}
