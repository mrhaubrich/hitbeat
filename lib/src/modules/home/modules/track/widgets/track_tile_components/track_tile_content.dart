import 'package:flutter/material.dart';
import 'package:hitbeat/src/modules/home/modules/track/widgets/track_tile_components/track_action_button.dart';
import 'package:hitbeat/src/modules/home/modules/track/widgets/track_tile_components/track_album_avatar.dart';
import 'package:hitbeat/src/modules/home/modules/track/widgets/track_tile_components/track_duration.dart';
import 'package:hitbeat/src/modules/home/modules/track/widgets/track_tile_components/track_info_section.dart';
import 'package:hitbeat/src/modules/home/modules/track/widgets/track_tile_components/track_number_indicator.dart';
import 'package:hitbeat/src/modules/player/enums/track_state.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';

/// Content layout for the track tile with all interactive elements
class TrackTileContent extends StatelessWidget {
  /// Creates the track tile content
  const TrackTileContent({
    required this.track,
    required this.isCurrentTrack,
    required this.isPlaying,
    required this.trackState,
    required this.isHovered,
    required this.onTap,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
    this.trackNumber,
    super.key,
  });

  /// The track to display
  final Track track;

  /// Optional track number
  final int? trackNumber;

  /// Whether this is the currently selected track
  final bool isCurrentTrack;

  /// Whether this track is currently playing
  final bool isPlaying;

  /// Current playback state
  final TrackState trackState;

  /// Whether the tile is being hovered
  final bool isHovered;

  /// Callback when tile is tapped
  final VoidCallback onTap;

  /// Callback when tap starts
  final VoidCallback onTapDown;

  /// Callback when tap ends
  final VoidCallback onTapUp;

  /// Callback when tap is cancelled
  final VoidCallback onTapCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: isCurrentTrack ? theme.primaryColor : Colors.transparent,
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
          onTap: onTap,
          onTapDown: (_) => onTapDown(),
          onTapUp: (_) => onTapUp(),
          onTapCancel: onTapCancel,
          borderRadius: BorderRadius.circular(8),
          hoverColor: theme.primaryColor.withAlpha(10),
          splashColor: theme.primaryColor.withAlpha(40),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                TrackNumberIndicator(
                  trackNumber: trackNumber,
                  isPlaying: isPlaying,
                  isCurrentTrack: isCurrentTrack,
                ),
                const SizedBox(width: 14),
                AnimatedScale(
                  duration: const Duration(milliseconds: 150),
                  scale: isHovered ? 1.05 : 1.0,
                  child: TrackAlbumAvatar(track: track, isPlaying: isPlaying),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: TrackInfoSection(
                    track: track,
                    isCurrentTrack: isCurrentTrack,
                  ),
                ),
                const SizedBox(width: 18),
                TrackDuration(
                  duration: track.duration,
                  isCurrentTrack: isCurrentTrack,
                ),
                const SizedBox(width: 18),
                TrackActionButton(
                  trackState: trackState,
                  isCurrentTrack: isCurrentTrack,
                  isHovered: isHovered,
                  onPressed: onTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
