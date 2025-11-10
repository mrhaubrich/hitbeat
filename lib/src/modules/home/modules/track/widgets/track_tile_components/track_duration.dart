import 'package:flutter/material.dart';

/// Displays formatted track duration
class TrackDuration extends StatelessWidget {
  /// Creates a track duration display
  const TrackDuration({
    required this.duration,
    required this.isCurrentTrack,
    super.key,
  });

  /// The duration to display
  final Duration duration;

  /// Whether this is the current track
  final bool isCurrentTrack;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      _formatDuration(duration),
      style: TextStyle(
        color: isCurrentTrack
            ? theme.primaryColor.withAlpha(190)
            : Colors.grey[500],
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
