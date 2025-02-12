import 'package:flutter/material.dart';

/// {@template text_overflow_builder}
/// A widget that detects if a text is overflowing.
/// {@endtemplate}
class TextOverflowBuilder extends StatefulWidget {
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
  State<TextOverflowBuilder> createState() => _TextOverflowBuilderState();
}

class _FifoCache {
  _FifoCache();

  final int maxSize = 50;
  final Map<int, bool> _cache = {};
  final List<int> _accessOrder = [];

  void put(int key, {required bool value}) {
    if (_cache.length >= maxSize) {
      final oldestKey = _accessOrder.removeAt(0);
      _cache.remove(oldestKey);
    }
    _cache[key] = value;
    _accessOrder.add(key);
  }

  bool? get(int key) {
    final value = _cache[key];
    if (value != null) {
      // Move to end of access order
      _accessOrder
        ..remove(key)
        ..add(key);
    }
    return value;
  }

  void clear() {
    _cache.clear();
    _accessOrder.clear();
  }

  void trim() {
    if (_cache.length > maxSize ~/ 2) {
      while (_cache.length > maxSize ~/ 2) {
        final oldestKey = _accessOrder.removeAt(0);
        _cache.remove(oldestKey);
      }
    }
  }
}

class _TextOverflowBuilderState extends State<TextOverflowBuilder>
    with WidgetsBindingObserver {
  TextPainter? _textPainter;
  String? _lastText;
  TextStyle? _lastStyle;
  final _FifoCache _overflowCache = _FifoCache();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _textPainter?.dispose();
    super.dispose();
  }

  @override
  void didHaveMemoryPressure() {
    print('Memory pressure detected. Clearing overflow cache.');
    _overflowCache.trim();
  }

  bool _calculateIsOverflowing(double maxWidth) {
    final widthKey = maxWidth.round();

    // Reset cache if text or style changed
    if (_lastText != widget.text || _lastStyle != widget.style) {
      _lastText = widget.text;
      _lastStyle = widget.style;
      _overflowCache.clear();
    }

    // Check cache first
    final cachedValue = _overflowCache.get(widthKey);
    if (cachedValue != null) {
      return cachedValue;
    }

    _textPainter ??= TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 1,
      textWidthBasis: TextWidthBasis.longestLine,
      ellipsis: '...',
    );

    final textSpan = TextSpan(text: widget.text, style: widget.style);
    _textPainter!
      ..text = textSpan
      ..strutStyle =
          widget.style != null ? StrutStyle.fromTextStyle(widget.style!) : null
      ..layout();

    const threshold = 15.0;
    final textWidth = _textPainter!.size.width;
    final isOverflowing = textWidth >= (maxWidth - threshold);

    // Cache the result
    _overflowCache.put(widthKey, value: isOverflowing);

    return isOverflowing;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isOverflowing = _calculateIsOverflowing(constraints.maxWidth);
        return widget.builder(context, isOverflowing);
      },
    );
  }
}
