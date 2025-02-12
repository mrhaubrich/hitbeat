import 'package:flutter/material.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/text_overflow_builder.dart';
import 'package:marquee/marquee.dart';

/// {@template player_song_info}
/// A widget that displays the song information.
/// {@endtemplate}
class PlayerSongInfo extends StatelessWidget {
  /// {@macro player_song_info}
  const PlayerSongInfo({
    required this.songName,
    required this.artistName,
    super.key,
  });

  /// The name of the song.
  final String songName;

  /// The name of the artist.
  final String artistName;

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
            text: songName,
            style: _songTextStyle,
            builder: (context, isOverflowing) {
              if (!isOverflowing) {
                return Text(songName, style: _songTextStyle);
              }
              return Marquee(
                text: songName,
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
            text: artistName,
            style: _artistTextStyle,
            builder: (context, isOverflowing) {
              if (!isOverflowing) {
                return Text(artistName, style: _artistTextStyle);
              }
              return Marquee(
                text: artistName,
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
