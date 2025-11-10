import 'package:flutter/material.dart';

/// Displays track number or playing indicator (graphic equalizer icon)
class TrackNumberIndicator extends StatelessWidget {
  /// Creates a track number indicator
  const TrackNumberIndicator({
    required this.isPlaying,
    required this.isCurrentTrack,
    this.trackNumber,
    super.key,
  });

  /// Optional track number to display
  final int? trackNumber;

  /// Whether this track is currently playing
  final bool isPlaying;

  /// Whether this is the current track
  final bool isCurrentTrack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 40,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isPlaying
              ? Icon(
                  Icons.graphic_eq,
                  key: const ValueKey('playing'),
                  color: theme.primaryColor,
                  size: 22,
                )
              : trackNumber != null
              ? Text(
                  '$trackNumber',
                  key: ValueKey('number-$trackNumber'),
                  style: TextStyle(
                    color: isCurrentTrack
                        ? theme.primaryColor
                        : Colors.grey[500],
                    fontSize: 15,
                    fontWeight: isCurrentTrack
                        ? FontWeight.w700
                        : FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
      ),
    );
  }
}
