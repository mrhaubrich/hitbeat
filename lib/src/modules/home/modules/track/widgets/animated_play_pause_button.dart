import 'package:flutter/material.dart';
import 'package:hitbeat/src/modules/player/enums/track_state.dart';

/// {@template animated_play_pause_button}
/// An animated play/pause button.
/// {@endtemplate}
class AnimatedPlayPauseButton extends StatefulWidget {
  /// {@macro animated_play_pause_button}
  const AnimatedPlayPauseButton({
    required this.state,
    required this.onPressed,
    this.color,
    this.size = 32,
    this.filled = false,
    super.key,
  });

  /// The state of the track
  final TrackState state;

  /// The callback when the button is pressed
  final VoidCallback onPressed;

  /// The color of the button
  final Color? color;

  /// The size of the button
  final double size;

  /// Whether the button should be filled
  final bool filled;

  @override
  State<AnimatedPlayPauseButton> createState() =>
      _AnimatedPlayPauseButtonState();
}

class _AnimatedPlayPauseButtonState extends State<AnimatedPlayPauseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _updateControllerValue();
  }

  @override
  void didUpdateWidget(AnimatedPlayPauseButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateControllerValue();
  }

  void _updateControllerValue() {
    if (widget.state == TrackState.playing) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).iconTheme.color!;

    return GestureDetector(
      onTap: widget.onPressed,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: color,
              width: 2,
            ),
            shape: BoxShape.circle,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              border: Border.all(
                color: color,
                width: 2,
              ),
              shape: BoxShape.circle,
              color: widget.filled ? color : Theme.of(context).cardColor,
            ),
            child: Center(
              child: AnimatedIcon(
                icon: AnimatedIcons.play_pause,
                progress: _controller,
                color: widget.filled ? Theme.of(context).cardColor : color,
                size: widget.size * 0.6,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
