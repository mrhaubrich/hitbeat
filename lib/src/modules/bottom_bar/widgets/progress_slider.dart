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
  final void Function(Duration position) onSeek;

  @override
  State<ProgressSlider> createState() => _ProgressSliderState();
}

class _ProgressSliderState extends State<ProgressSlider> {
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Duration? hoverPosition;

  @override
  Widget build(BuildContext context) {
    final progress =
        widget.position.inMilliseconds / widget.duration.inMilliseconds;

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
      centerIcon: hoverPosition == null
          ? null
          : Text(
              _formatDuration(hoverPosition ?? widget.position),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
      initialProgress: progress.clamp(0, 1),
      onProgressUpdated: (value) {
        final newPosition = Duration(
          milliseconds: (value * widget.duration.inMilliseconds).round(),
        );
        widget.onSeek(newPosition);
        setState(() {
          hoverPosition = null;
        });
      },
      onFocused: (value) {
        final newPosition = Duration(
          milliseconds: (value * widget.duration.inMilliseconds).round(),
        );
        setState(() {
          hoverPosition = newPosition;
        });
      },
      onChanged: (value) {
        setState(() {
          hoverPosition = Duration(
            milliseconds: (value * widget.duration.inMilliseconds).round(),
          );
        });
      },
    );
  }
}
