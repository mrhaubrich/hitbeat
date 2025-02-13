import 'dart:async';

import 'package:flutter/material.dart';
import 'package:interactive_slider/interactive_slider.dart';

/// {@template progress_slider}
/// A widget that displays the song progress slider.
/// {@endtemplate}
class ProgressSlider extends StatefulWidget {
  /// {@macro progress_slider}
  const ProgressSlider({
    required this.duration,
    required this.position,
    required this.onSeek,
    super.key,
  });

  /// Total duration of the song
  final Duration duration;

  /// Current position in the song
  final Duration position;

  /// Callback when user seeks to a new position
  final FutureOr<void> Function(Duration position) onSeek;

  @override
  State<ProgressSlider> createState() => _ProgressSliderState();
}

class _ProgressSliderState extends State<ProgressSlider> {
  late final InteractiveSliderController _controller;
  bool _isHovering = false;
  Duration? hoverPosition;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    _controller = InteractiveSliderController(
      widget.position.inMilliseconds / widget.duration.inMilliseconds,
    );
  }

  @override
  void didUpdateWidget(covariant ProgressSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (hoverPosition == null && oldWidget.position != widget.position) {
      _controller.value =
          widget.position.inMilliseconds / widget.duration.inMilliseconds;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveSlider(
      padding: EdgeInsets.zero,
      startIcon: Text(
        _formatDuration(widget.position),
        style: const TextStyle(color: Colors.white60, fontSize: 12),
      ),
      endIcon: Text(
        _formatDuration(widget.duration),
        style: const TextStyle(color: Colors.white60, fontSize: 12),
      ),
      centerIcon: _isHovering
          ? Text(
              _formatDuration(hoverPosition ?? widget.position),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            )
          : null,
      controller: _controller,
      onProgressUpdated: (value) async {
        setState(() {
          _isHovering = false;
        });
        final newPosition = Duration(
          milliseconds: (value * widget.duration.inMilliseconds).round(),
        );
        await widget.onSeek(newPosition);
        setState(() {
          hoverPosition = null;
        });
      },
      onFocused: (value) {
        final newPosition = Duration(
          milliseconds: (value * widget.duration.inMilliseconds).round(),
        );
        setState(() {
          _isHovering = true;
          hoverPosition = newPosition;
        });
      },
      onChanged: (value) {
        if (!_isHovering) return;
        final newDuration = Duration(
          milliseconds: (value * widget.duration.inMilliseconds).round(),
        );
        setState(() {
          hoverPosition = newDuration;
        });
      },
    );
  }
}
