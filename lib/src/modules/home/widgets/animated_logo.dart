import 'package:flutter/material.dart';

class AnimatedLogo extends StatelessWidget {
  const AnimatedLogo({
    required this.extended,
    super.key,
  });

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
            child: const FlutterLogo(size: 48),
          ),
        );
      },
    );
  }
}
