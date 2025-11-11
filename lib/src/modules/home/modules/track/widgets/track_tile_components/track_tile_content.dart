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
    final listTileTheme = theme.listTileTheme;

    // Get theme values with fallbacks
    final contentPadding =
        listTileTheme.contentPadding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    final horizontalGap = listTileTheme.horizontalTitleGap ?? 14.0;
    final shape =
        listTileTheme.shape ??
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));
    final borderRadius = shape is RoundedRectangleBorder
        ? shape.borderRadius.resolve(Directionality.of(context))
        : BorderRadius.circular(8);

    // Get color values from theme
    final tileColor = listTileTheme.tileColor ?? Colors.transparent;
    final backgroundColor = tileColor;

    final hoverColor = listTileTheme.tileColor != null
        ? Color.alphaBlend(
            theme.primaryColor.withAlpha(10),
            listTileTheme.tileColor!,
          )
        : theme.primaryColor.withAlpha(10);
    final splashColor = theme.primaryColor.withAlpha(40);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          left: BorderSide(
            color: theme.primaryColor,
            width: 4,
          ),
        ),
        gradient: isCurrentTrack
            ? LinearGradient(
                colors: [
                  theme.primaryColor.withAlpha(20),
                  backgroundColor,
                  backgroundColor.withAlpha(200),
                ],
                stops: const [0.0, 0.45, 0.9],
                transform: const GradientRotation(1.2),
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
          borderRadius: borderRadius,
          hoverColor: hoverColor,
          splashColor: splashColor,
          child: Padding(
            padding: contentPadding,
            child: Row(
              children: [
                TrackNumberIndicator(
                  trackNumber: trackNumber,
                  isPlaying: isPlaying,
                  isCurrentTrack: isCurrentTrack,
                ),
                SizedBox(width: horizontalGap),
                AnimatedScale(
                  duration: const Duration(milliseconds: 150),
                  scale: isHovered ? 1.05 : 1.0,
                  child: TrackAlbumAvatar(track: track, isPlaying: isPlaying),
                ),
                SizedBox(width: horizontalGap),
                Expanded(
                  child: TrackInfoSection(
                    track: track,
                    isCurrentTrack: isCurrentTrack,
                  ),
                ),
                SizedBox(width: horizontalGap),
                TrackDuration(
                  duration: track.duration,
                  isCurrentTrack: isCurrentTrack,
                ),
                SizedBox(width: horizontalGap),
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
