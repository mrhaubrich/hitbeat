import 'package:flutter/material.dart';
import 'package:hitbeat/src/modules/home/modules/track/widgets/animated_play_pause_button.dart';
import 'package:hitbeat/src/modules/player/enums/track_state.dart';

/// Play/Pause action button with hover animation
class TrackActionButton extends StatelessWidget {
  /// Creates a track action button
  const TrackActionButton({
    required this.trackState,
    required this.isCurrentTrack,
    required this.isHovered,
    required this.onPressed,
    super.key,
  });

  /// Current track state
  final TrackState trackState;

  /// Whether this is the current track
  final bool isCurrentTrack;

  /// Whether the parent widget is hovered
  final bool isHovered;

  /// Callback when button is pressed
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RepaintBoundary(
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: isHovered ? 1.1 : 1.0,
        child: AnimatedPlayPauseButton(
          state: isCurrentTrack ? trackState : TrackState.notPlaying,
          onPressed: onPressed,
          color: isCurrentTrack ? theme.primaryColor : null,
          filled: isCurrentTrack,
        ),
      ),
    );
  }
}
