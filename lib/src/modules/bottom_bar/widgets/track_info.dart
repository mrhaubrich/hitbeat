import 'package:flutter/material.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/text_overflow_builder.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';
import 'package:marquee/marquee.dart';

/// {@template player_track_info}
/// A widget that displays the track information.
/// {@endtemplate}
class TrackInfo extends StatelessWidget {
  /// {@macro player_track_info}
  const TrackInfo({
    required this.track,
    super.key,
  });

  /// The name of the track.
  final Track track;

  static const _songTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 16,
    overflow: TextOverflow.ellipsis,
  );

  static const _artistTextStyle = TextStyle(
    color: Colors.white70,
    fontSize: 14,
    overflow: TextOverflow.ellipsis,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
          child: TextOverflowBuilder(
            text: track.name,
            style: _songTextStyle,
            builder: (context, isOverflowing) {
              if (!isOverflowing) {
                return Text(track.name, style: _songTextStyle);
              }
              return Marquee(
                text: track.name,
                style: _songTextStyle,
                blankSpace: 100,
                startAfter: const Duration(seconds: 2),
                pauseAfterRound: const Duration(seconds: 15),
                numberOfRounds: 3,
              );
            },
          ),
        ),
        SizedBox(
          height: 20,
          child: TextOverflowBuilder(
            text: track.artist.name,
            style: _artistTextStyle,
            builder: (context, isOverflowing) {
              if (!isOverflowing) {
                return Text(track.artist.name, style: _artistTextStyle);
              }
              return Marquee(
                text: track.artist.name,
                style: _artistTextStyle,
                blankSpace: 100,
                startAfter: const Duration(seconds: 2),
                pauseAfterRound: const Duration(seconds: 15),
                numberOfRounds: 3,
              );
            },
          ),
        ),
      ],
    );
  }
}
