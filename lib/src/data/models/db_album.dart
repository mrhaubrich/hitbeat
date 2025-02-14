import 'dart:typed_data';

import 'package:hitbeat/src/data/models/db_artist.dart';
import 'package:hitbeat/src/modules/player/models/album.dart';

class DbAlbum {
  DbAlbum({
    required this.id,
    required this.name,
    required this.artist,
    this.cover,
  });

  factory DbAlbum.fromMap(Map<String, dynamic> map) {
    return DbAlbum(
      id: map['id'] as int,
      name: map['name'] as String,
      cover: map['cover'] as Uint8List?,
      artist: map['artist'] as DbArtist,
    );
  }

  factory DbAlbum.fromEntity(Album album) {
    return DbAlbum(
      id: 0, // This should be set when inserting into the database
      name: album.name,
      cover: album.cover,
      artist: DbArtist.fromEntity(album.artist),
    );
  }
  final int id;
  final String name;
  final Uint8List? cover;
  final DbArtist artist;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cover': cover,
      'artist_id': artist.id,
    };
  }

  Album toEntity() {
    return Album(
      name: name,
      cover: cover,
      tracks: const [], // Tracks should be loaded separately
      artist: artist.toEntity(),
    );
  }
}
