import 'package:hitbeat/src/data/models/db_album.dart';
import 'package:hitbeat/src/data/models/db_artist.dart';
import 'package:hitbeat/src/data/models/db_genre.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';

class DbTrack {
  DbTrack({
    required this.id,
    required this.name,
    required this.path,
    required this.durationInMillis,
    required this.genres,
    required this.album,
    required this.artist,
  });

  factory DbTrack.fromMap(Map<String, dynamic> map) {
    return DbTrack(
      id: map['id'] as int,
      name: map['name'] as String,
      path: map['path'] as String,
      durationInMillis: map['duration_millis'] as int,
      genres: [], // This should be loaded separately
      album: map['album'] as DbAlbum,
      artist: map['artist'] as DbArtist,
    );
  }

  factory DbTrack.fromEntity(Track track) {
    return DbTrack(
      id: 0, // This should be set when inserting into the database
      name: track.name,
      path: track.path,
      durationInMillis: track.duration.inMilliseconds,
      genres: track.genres.map(DbGenre.fromEntity).toList(),
      album: DbAlbum.fromEntity(track.album),
      artist: DbArtist.fromEntity(track.artist),
    );
  }
  final int id;
  final String name;
  final String path;
  final int durationInMillis;
  final List<DbGenre> genres;
  final DbAlbum album;
  final DbArtist artist;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'duration_millis': durationInMillis,
      'album_id': album.id,
      'artist_id': artist.id,
    };
  }

  Track toEntity() {
    return Track(
      name: name,
      path: path,
      duration: Duration(milliseconds: durationInMillis),
      genres: genres.map((g) => g.toEntity()).toList(),
      album: album.toEntity(),
      artist: artist.toEntity(),
    );
  }
}
