import 'package:flutter/material.dart';

/// {@template player_album_cover}
/// A widget that displays the album cover.
/// {@endtemplate}
class PlayerAlbumCover extends StatelessWidget {
  /// {@macro player_album_cover}
  const PlayerAlbumCover({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 64,
          height: 64,
          color: Colors.grey[300],
          child: const Icon(Icons.album, size: 32),
        ),
      ),
    );
  }
}
