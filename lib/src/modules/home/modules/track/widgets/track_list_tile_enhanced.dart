import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/home/modules/track/widgets/animated_play_pause_button.dart';
import 'package:hitbeat/src/modules/player/enums/track_state.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';
import 'package:hitbeat/src/services/cover_cache_service.dart';

/// {@template track_list_tile}
/// An enhanced list tile for a track with desktop-optimized UX.
/// {@endtemplate}
class TrackListTileEnhanced extends StatefulWidget {
  /// {@macro track_list_tile}
  const TrackListTileEnhanced({
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
  State<TrackListTileEnhanced> createState() => _TrackListTileEnhancedState();
}

class _TrackListTileEnhancedState extends State<TrackListTileEnhanced>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 1.008).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHoverChanged(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      unawaited(_animationController.forward());
    } else {
      unawaited(_animationController.reverse());
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => _onHoverChanged(true),
      onExit: (_) => _onHoverChanged(false),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, _) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
            decoration: BoxDecoration(
              color: _isHovered
                  ? theme.cardColor.withAlpha(245)
                  : theme.cardColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(_isHovered ? 55 : 28),
                  blurRadius: _isHovered ? 18 : 8,
                  offset: Offset(0, _isHovered ? 8 : 3),
                  spreadRadius: _isHovered ? 1 : 0,
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

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                          left: BorderSide(
                            color: isCurrentTrack
                                ? theme.primaryColor
                                : Colors.transparent,
                            width: 4,
                          ),
                        ),
                        gradient: isCurrentTrack
                            ? LinearGradient(
                                colors: [
                                  theme.primaryColor.withAlpha(30),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.6],
                              )
                            : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onTap,
                          borderRadius: BorderRadius.circular(8),
                          hoverColor: theme.primaryColor.withAlpha(12),
                          splashColor: theme.primaryColor.withAlpha(35),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                // Track number or playing indicator
                                SizedBox(
                                  width: 40,
                                  child: Center(
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: isPlaying
                                          ? Icon(
                                              Icons.graphic_eq,
                                              key: const ValueKey('playing'),
                                              color: theme.primaryColor,
                                              size: 22,
                                            )
                                          : widget.trackNumber != null
                                          ? Text(
                                              '${widget.trackNumber}',
                                              key: ValueKey(
                                                'number-${widget.trackNumber}',
                                              ),
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
                                          : const SizedBox.shrink(
                                              key: ValueKey('empty'),
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Album cover with hover animation
                                AnimatedScale(
                                  duration: const Duration(milliseconds: 150),
                                  scale: _isHovered ? 1.05 : 1.0,
                                  child: _AlbumAvatar(
                                    track: widget.track,
                                    isPlaying: isPlaying,
                                  ),
                                ),
                                const SizedBox(width: 18),
                                // Track info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.track.name,
                                        style: TextStyle(
                                          color: isCurrentTrack
                                              ? theme.primaryColor
                                              : Colors.white,
                                          fontWeight: isCurrentTrack
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                          fontSize: 15,
                                          letterSpacing: 0.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        [
                                          widget.track.artist.name,
                                          if (widget
                                              .track
                                              .album
                                              .name
                                              .isNotEmpty)
                                            widget.track.album.name,
                                        ].join(' • '),
                                        style: TextStyle(
                                          color: isCurrentTrack
                                              ? theme.primaryColor.withAlpha(
                                                  190,
                                                )
                                              : Colors.grey[400],
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 0.1,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 18),
                                // Duration
                                Text(
                                  _formatDuration(widget.track.duration),
                                  style: TextStyle(
                                    color: isCurrentTrack
                                        ? theme.primaryColor.withAlpha(190)
                                        : Colors.grey[500],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 18),
                                // Play/Pause button with animation
                                RepaintBoundary(
                                  child: AnimatedScale(
                                    duration: const Duration(milliseconds: 150),
                                    scale: _isHovered ? 1.1 : 1.0,
                                    child: AnimatedPlayPauseButton(
                                      state: isCurrentTrack
                                          ? trackState
                                          : TrackState.notPlaying,
                                      onPressed: widget.onTap,
                                      color: isCurrentTrack
                                          ? theme.primaryColor
                                          : null,
                                      filled: isCurrentTrack,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AlbumAvatar extends StatelessWidget {
  const _AlbumAvatar({
    required this.track,
    this.isPlaying = false,
  });

  final Track track;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coverHash = track.album.coverHash;

    Widget avatarContent;
    if (coverHash == null) {
      avatarContent = Icon(Icons.album, color: Colors.grey[600]);
    } else {
      final cache = Modular.get<CoverCacheService>();
      final path = cache.getCoverPath(coverHash);
      if (path == null) {
        avatarContent = Icon(Icons.album, color: Colors.grey[600]);
      } else {
        final file = File(path);
        avatarContent = Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: ResizeImage(
                FileImage(file),
                width: 56,
                height: 56,
              ),
              fit: BoxFit.cover,
            ),
          ),
        );
      }
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: isPlaying
            ? [
                BoxShadow(
                  color: theme.primaryColor.withAlpha(102),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(77),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ClipOval(child: avatarContent),
    );
  }
}
