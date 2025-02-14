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
      key: ValueKey(text),
      builder: (context, constraints) {
        return _MemoizedTextOverflow(
          text: text,
          style: style,
          width: constraints.maxWidth,
          builder: builder,
        );
      },
    );
  }
}

class _MemoizedTextOverflow extends StatefulWidget {
  const _MemoizedTextOverflow({
    required this.text,
    required this.style,
    required this.width,
    required this.builder,
  });

  final String text;
  final TextStyle? style;
  final double width;
  final Widget Function(BuildContext, bool) builder;

  @override
  State<_MemoizedTextOverflow> createState() => _MemoizedTextOverflowState();
}

class _MemoizedTextOverflowState extends State<_MemoizedTextOverflow> {
  late bool _isOverflowing;

  @override
  void initState() {
    super.initState();
    _isOverflowing = _calculateOverflow(
      text: widget.text,
      width: widget.width,
      style: widget.style,
    );
  }

  @override
  void didUpdateWidget(_MemoizedTextOverflow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.width != widget.width ||
        oldWidget.text != widget.text ||
        oldWidget.style != widget.style) {
      _isOverflowing = _calculateOverflow(
        text: widget.text,
        width: widget.width,
        style: widget.style,
      );
    }
  }

  bool _calculateOverflow({
    required String text,
    required double width,
    TextStyle? style,
  }) {
    final textSpan = TextSpan(text: widget.text, style: widget.style);
    final textPainter = TextPainter(
      text: textSpan,
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textWidthBasis: TextWidthBasis.longestLine,
      strutStyle: StrutStyle.fromTextStyle(widget.style!),
      ellipsis: '...',
    )..layout(maxWidth: widget.width);

    const threshold = 15;
    return textPainter.width >= (widget.width - threshold);
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _isOverflowing);
}
