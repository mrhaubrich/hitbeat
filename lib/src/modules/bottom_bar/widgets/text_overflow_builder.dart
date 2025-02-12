import 'package:flutter/material.dart';

/// {@template text_overflow_builder}
/// A widget that detects if a text is overflowing.
/// {@endtemplate}
class TextOverflowBuilder extends StatelessWidget {
  /// {@macro text_overflow_builder}
  const TextOverflowBuilder({
    required this.text,
    required this.builder,
    super.key,
    this.style,
  });

  /// The text to check for overflow.
  final String text;

  /// The style of the text.
  final TextStyle? style;

  /// The builder to call with the context and if the text is overflowing.
  // ignore: avoid_positional_boolean_parameters
  final Widget Function(BuildContext context, bool isOverflowing) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textSpan = TextSpan(text: text, style: style);
        final textPainter = TextPainter(
          text: textSpan,
          maxLines: 1,
          textDirection: TextDirection.ltr,
          textWidthBasis: TextWidthBasis.longestLine,
          strutStyle: StrutStyle.fromTextStyle(style!),
          ellipsis: '...',
        )..layout(maxWidth: constraints.maxWidth);

        // If the text fits exactly or is very close to the constraint width,
        // it will need ellipsis, so we consider it overflowing
        const threshold = 15; // Small buffer to account for rounding
        final isOverflowing =
            textPainter.width >= (constraints.maxWidth - threshold);

        return builder(context, isOverflowing);
      },
    );
  }
}
