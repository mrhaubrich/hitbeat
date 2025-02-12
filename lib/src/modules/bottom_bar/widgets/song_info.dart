import 'package:flutter/material.dart';

/// {@template player_song_info}
/// A widget that displays the song information.
/// {@endtemplate}
class PlayerSongInfo extends StatelessWidget {
  /// {@macro player_song_info}
  const PlayerSongInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Song Name',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Artist Name',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
