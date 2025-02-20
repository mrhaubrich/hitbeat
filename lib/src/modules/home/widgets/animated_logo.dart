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

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(
        begin: 0,
        end: extended ? 1 : 0,
      ),
      builder: (context, double value, child) {
        return Transform.rotate(
          angle: value * 2 * 3.14159,
          child: Transform.scale(
            scale: 1 + (value * 0.2),
            child: Image.asset(
              'assets/logo/hitbeat-icon.png',
              width: 48,
              height: 48,
            ),
          ),
        );
      },
    );
  }
}
