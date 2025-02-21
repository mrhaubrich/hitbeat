import 'package:hitbeat/src/data/models/db_artist.dart';
import 'package:hitbeat/src/modules/player/models/album.dart';

/// {@template db_album}
/// A class that represents an album in the database.
/// {@endtemplate}
class DbAlbum {
  /// {@macro db_album}
  DbAlbum({
    required this.id,
    required this.name,
    required this.artist,
    this.coverHash,
  });

  /// Creates a [DbAlbum] from a map.
  factory DbAlbum.fromMap(Map<String, dynamic> map) {
    return DbAlbum(
      id: map['id'] as int,
      name: map['name'] as String,
      coverHash: map['coverHash'] as String?,
      artist: map['artist'] as DbArtist,
    );
  }

  /// Creates a [DbAlbum] from an [Album].
  factory DbAlbum.fromEntity(Album album) {
    return DbAlbum(
      id: 0, // This should be set when inserting into the database
      name: album.name,
      coverHash: album.coverHash,
      artist: DbArtist.fromEntity(album.artist),
    );
  }

  /// The id of the album.
  final int id;

  /// The name of the album.
  final String name;

  /// The cover of the album.
  final String? coverHash;

  /// The artist of the album.
  final DbArtist artist;

  /// Converts the [DbAlbum] to a map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'coverHash': coverHash,
      'artist_id': artist.id,
    };
  }

  /// Converts the [DbAlbum] to an [Album].
  Album toEntity() {
    return Album(
      name: name,
      coverHash: coverHash,
      tracks: const [], // Tracks should be loaded separately
      artist: artist.toEntity(),
    );
  }
}
