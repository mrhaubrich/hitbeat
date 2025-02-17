import 'package:flutter/material.dart';
import 'package:hitbeat/src/modules/player/enums/track_state.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';

/// {@template track_list_tile}
/// A list tile for a track.
/// {@endtemplate}
class TrackListTile extends StatelessWidget {
  /// {@macro track_list_tile}
  const TrackListTile({
    required this.track,
    required this.trackState,
    required this.onTap,
    super.key,
  });

  /// The track
  final Track track;

  /// The state of the track
  final TrackState trackState;

  /// The callback when the tile is tapped
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = trackState != TrackState.notPlaying;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundImage: track.album.cover != null
              ? MemoryImage(track.album.cover!)
              : null,
          radius: 24,
          child: track.album.cover == null ? const Icon(Icons.album) : null,
        ),
        title: Text(
          track.name,
          style: TextStyle(
            color: isSelected ? Theme.of(context).primaryColor : null,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          track.artist.name,
          style: TextStyle(
            color:
                isSelected ? theme.primaryColor.withValues(alpha: 0.7) : null,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            _getIconForState(trackState),
            color: isSelected ? Theme.of(context).primaryColor : null,
            size: 32,
          ),
          onPressed: onTap,
        ),
      ),
    );
  }

  IconData _getIconForState(TrackState state) {
    switch (state) {
      case TrackState.playing:
        return Icons.pause_circle_filled;
      case TrackState.paused:
        return Icons.play_circle_filled;
      case TrackState.notPlaying:
        return Icons.play_circle_outline;
    }
  }
}
