import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/home/modules/track/widgets/animated_play_pause_button.dart';
import 'package:hitbeat/src/modules/player/enums/track_state.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';
import 'package:hitbeat/src/services/cover_cache_service.dart';

/// {@template track_list_tile}
/// A list tile for a track.
/// {@endtemplate}
class TrackListTile extends StatelessWidget {
  /// {@macro track_list_tile}
  const TrackListTile({
    required this.track,
    required this.onTap,
    required this.player,
    super.key,
  });

  /// The track
  final Track track;

  /// The callback when the tile is tapped
  final VoidCallback onTap;

  /// The player to interact with
  final IAudioPlayer player;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        key: ValueKey(track.path),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _AlbumAvatar(track: track),
        title: StreamBuilder<TrackState>(
          stream: player.trackState$,
          builder: (context, snapshot) {
            final isSelected = snapshot.data != TrackState.notPlaying;
            final isCurrentTrack = player.currentTrack == track;
            return Text(
              track.name,
              style: TextStyle(
                color: isSelected && isCurrentTrack
                    ? Theme.of(context).primaryColor
                    : null,
                fontWeight: isSelected && isCurrentTrack
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            );
          },
        ),
        subtitle: StreamBuilder<TrackState>(
          stream: player.trackState$,
          builder: (context, snapshot) {
            final isSelected = snapshot.data != TrackState.notPlaying;
            final isCurrentTrack = player.currentTrack == track;

            return Text(
              track.artist.name,
              style: TextStyle(
                color: isSelected && isCurrentTrack
                    ? theme.primaryColor.withAlpha(179)
                    : null,
              ),
            );
          },
        ),
        trailing: RepaintBoundary(
          child: StreamBuilder<TrackState>(
            stream: player.trackState$,
            builder: (context, snapshot) {
              final isSelected = snapshot.data != TrackState.notPlaying;
              final isCurrentTrack = player.currentTrack == track;
              return AnimatedPlayPauseButton(
                state: isCurrentTrack
                    ? snapshot.data ?? TrackState.notPlaying
                    : TrackState.notPlaying,
                onPressed: onTap,
                color: isSelected && isCurrentTrack
                    ? Theme.of(context).primaryColor
                    : null,
                filled: isSelected && isCurrentTrack,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AlbumAvatar extends StatelessWidget {
  const _AlbumAvatar({required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    final coverHash = track.album.coverHash;
    if (coverHash == null) {
      return const CircleAvatar(
        radius: 24,
        child: Icon(Icons.album),
      );
    }
    final cache = Modular.get<CoverCacheService>();
    final path = cache.getCoverPath(coverHash);
    if (path == null) {
      return const CircleAvatar(
        radius: 24,
        child: Icon(Icons.album),
      );
    }
    final file = File(path);
    return CircleAvatar(
      radius: 24,
      backgroundImage: FileImage(
        file,
      ),
    );
  }
}
