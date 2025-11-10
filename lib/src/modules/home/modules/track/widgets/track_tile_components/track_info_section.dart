import 'package:flutter/material.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';

/// Displays track name, artist, and album information
class TrackInfoSection extends StatelessWidget {
  /// Creates a track info section
  const TrackInfoSection({
    required this.track,
    required this.isCurrentTrack,
    super.key,
  });

  /// The track to display info for
  final Track track;

  /// Whether this is the current track
  final bool isCurrentTrack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          track.name,
          style: TextStyle(
            color: isCurrentTrack ? theme.primaryColor : Colors.white,
            fontWeight: isCurrentTrack ? FontWeight.w700 : FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 5),
        Text(
          [
            track.artist.name,
            if (track.album.name.isNotEmpty) track.album.name,
          ].join(' • '),
          style: TextStyle(
            color: isCurrentTrack
                ? theme.primaryColor.withAlpha(190)
                : Colors.grey[400],
            fontSize: 13,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
