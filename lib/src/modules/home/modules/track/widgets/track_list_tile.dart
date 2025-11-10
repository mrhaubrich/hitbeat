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
class TrackListTile extends StatefulWidget {
  /// {@macro track_list_tile}
  const TrackListTile({
    required this.track,
    required this.onTap,
    required this.player,
    this.trackNumber,
    super.key,
  });

  /// The track
  final Track track;

  /// The callback when the tile is tapped
  final VoidCallback onTap;

  /// The player to interact with
  final IAudioPlayer player;

  /// The track number in the list
  final int? trackNumber;

  @override
  State<TrackListTile> createState() => _TrackListTileState();
}

class _TrackListTileState extends State<TrackListTile> {
  bool _isHovered = false;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: _isHovered ? theme.cardColor.withAlpha(230) : theme.cardColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(40),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: StreamBuilder<Track?>(
          stream: widget.player.currentTrack$,
          builder: (context, currentTrackSnapshot) {
            return StreamBuilder<TrackState>(
              stream: widget.player.trackState$,
              builder: (context, trackStateSnapshot) {
                final trackState =
                    trackStateSnapshot.data ?? TrackState.notPlaying;
                final isCurrentTrack =
                    currentTrackSnapshot.data == widget.track;
                final isPlaying =
                    isCurrentTrack && trackState == TrackState.playing;

                return InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Track number or playing indicator
                        SizedBox(
                          width: 32,
                          child: Center(
                            child: isPlaying
                                ? Icon(
                                    Icons.graphic_eq,
                                    color: theme.primaryColor,
                                    size: 20,
                                  )
                                : widget.trackNumber != null
                                ? Text(
                                    '${widget.trackNumber}',
                                    style: TextStyle(
                                      color: isCurrentTrack
                                          ? theme.primaryColor
                                          : Colors.grey[500],
                                      fontSize: 14,
                                      fontWeight: isCurrentTrack
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Album cover
                        _AlbumAvatar(track: widget.track),
                        const SizedBox(width: 16),
                        // Track info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.track.name,
                                style: TextStyle(
                                  color: isCurrentTrack
                                      ? theme.primaryColor
                                      : theme.textTheme.bodyLarge?.color,
                                  fontWeight: isCurrentTrack
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.track.artist.name,
                                      style: TextStyle(
                                        color: isCurrentTrack
                                            ? theme.primaryColor.withAlpha(179)
                                            : Colors.grey[400],
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (widget.track.album.name.isNotEmpty) ...[
                                    Text(
                                      ' • ',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        widget.track.album.name,
                                        style: TextStyle(
                                          color: isCurrentTrack
                                              ? theme.primaryColor.withAlpha(
                                                  179,
                                                )
                                              : Colors.grey[400],
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Duration
                        Text(
                          _formatDuration(widget.track.duration),
                          style: TextStyle(
                            color: isCurrentTrack
                                ? theme.primaryColor.withAlpha(179)
                                : Colors.grey[500],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Play/Pause button
                        RepaintBoundary(
                          child: AnimatedPlayPauseButton(
                            state: isCurrentTrack
                                ? trackState
                                : TrackState.notPlaying,
                            onPressed: widget.onTap,
                            color: isCurrentTrack ? theme.primaryColor : null,
                            filled: isCurrentTrack,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
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
      backgroundImage: ResizeImage(
        FileImage(file),
        width: 48,
        height: 48,
      ),
    );
  }
}
