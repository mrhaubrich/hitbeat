import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:hitbeat/src/data/models/db_album.dart' show DbAlbum;
import 'package:hitbeat/src/data/models/db_artist.dart' show DbArtist;
import 'package:hitbeat/src/data/models/db_genre.dart' show DbGenre;
import 'package:hitbeat/src/data/models/db_track.dart' show DbTrack;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// Table for storing artists.
class Artists extends Table {
  /// The primary key for the table.
  IntColumn get id => integer().autoIncrement()();

  /// The name of the artist.
  TextColumn get name => text().unique()();

  /// The image of the artist.
  BlobColumn get image => blob().nullable()();
}

/// Table for storing albums.
class Albums extends Table {
  /// The primary key for the table.
  IntColumn get id => integer().autoIncrement()();

  /// The name of the album.
  TextColumn get name => text()();

  /// The cover of the album.
  BlobColumn get cover => blob().nullable()();

  /// The artist of the album.
  IntColumn get artistId => integer().references(Artists, #id)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {name, artistId},
      ];
}

/// Table for storing genres.
class Genres extends Table {
  /// The primary key for the table.
  IntColumn get id => integer().autoIncrement()();

  /// The name of the genre.
  TextColumn get name => text().unique()();
}

/// Table for storing tracks.
class Tracks extends Table {
  /// The primary key for the table.
  IntColumn get id => integer().autoIncrement()();

  /// The name of the track.
  TextColumn get name => text()();

  /// The path of the track.
  TextColumn get path => text().unique()();

  /// The duration of the track in milliseconds.
  IntColumn get durationInMillis => integer()();

  /// The album of the track.
  IntColumn get albumId => integer().references(Albums, #id)();

  /// The artist of the track.
  IntColumn get artistId => integer().references(Artists, #id)();
}

/// Table for storing the genres of tracks.
class TrackGenres extends Table {
  /// The track ID.
  IntColumn get trackId => integer().references(Tracks, #id)();

  /// The genre ID.
  IntColumn get genreId => integer().references(Genres, #id)();

  @override
  Set<Column> get primaryKey => {trackId, genreId};
}

/// {@template hitbeat_database}
/// The database for the HitBeat application.
/// {@endtemplate}
@DriftDatabase(
  tables: [Artists, Albums, Genres, Tracks, TrackGenres],
)
class HitBeatDatabase extends _$HitBeatDatabase {
  /// {@macro hitbeat_database}
  HitBeatDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  /// Inserts the given [artist] into the database.
  Future<int> insertArtist(ArtistsCompanion artist) {
    return into(artists).insert(
      artist,
      // mode: InsertMode.insertOrReplace,
    );
  }

  /// Inserts the given [album] into the database.
  Future<int> insertAlbum(AlbumsCompanion album) {
    return into(albums).insert(
      album,
      // mode: InsertMode.insertOrReplace,
    );
  }

  /// Inserts the given [genre] into the database.
  Future<int> insertGenre(GenresCompanion genre) {
    return into(genres).insert(
      genre,
      // mode: InsertMode.insertOrReplace,
    );
  }

  /// Inserts the given [track] into the database.
  Future<int> insertTrack(TracksCompanion track) {
    return into(tracks).insert(
      track,
      // mode: InsertMode.insertOrReplace,
    );
  }

  /// Inserts the given [trackGenre] into the database.
  Future<void> insertTrackGenre(TrackGenresCompanion trackGenre) {
    return into(trackGenres).insert(
      trackGenre,
      // mode: InsertMode.insertOrReplace,
    );
  }

  /// Returns all tracks in the database.
  Future<List<Track>> getAllTracks() {
    return (select(tracks)
          ..orderBy([
            (t) => OrderingTerm(expression: t.name),
          ]))
        .get();
  }

  /// Returns all DbTracks in the database.
  Future<List<DbTrack>> getAllDbTracks() async {
    final tracks = await getAllTracks();

    final results = await Future.wait(
      tracks.map((track) async {
        final dbAlbum = await getDbAlbumById(track.albumId);
        final dbArtist = await getDbArtistById(track.artistId);
        final dbGenres = await getDbGenresForTrack(track.id);

        if (dbAlbum == null || dbArtist == null) return null;

        return DbTrack(
          id: track.id,
          name: track.name,
          path: track.path,
          album: dbAlbum,
          artist: dbArtist,
          durationInMillis: track.durationInMillis,
          genres: dbGenres,
        );
      }),
    );
    return results.whereType<DbTrack>().toList();
  }

  /// Returns all artists in the database.
  Future<List<Album>> getAlbumsByArtist(int artistId) {
    return (select(albums)..where((a) => a.artistId.equals(artistId))).get();
  }

  /// Returns all genres in the database.
  Future<List<Genre>> getGenresForTrack(int trackId) {
    final query = select(genres).join([
      innerJoin(
        trackGenres,
        trackGenres.genreId.equalsExp(genres.id),
        useColumns: false,
      ),
    ])
      ..where(trackGenres.trackId.equals(trackId));

    return query.map((row) => row.readTable(genres)).get();
  }

  /// Returns the artist with the given [name], or `null` if no artist with that
  Future<Artist?> getArtistByName(String name) {
    return (select(artists)..where((a) => a.name.equals(name)))
        .getSingleOrNull();
  }

  /// Returns the album with the given [name] and [artistId], or `null`
  /// if no album with that
  /// name and artistId exists.
  Future<Album?> getAlbumByNameAndArtist(String name, int artistId) {
    return (select(albums)
          ..where((a) {
            return a.name.equals(name) & a.artistId.equals(artistId);
          }))
        .getSingleOrNull();
  }

  /// Returns the genre with the given [name], or `null` if no genre with that
  /// name exists.
  Future<Genre?> getGenreByName(String name) {
    return (select(genres)..where((g) => g.name.equals(name)))
        .getSingleOrNull();
  }

  /// Returns the track with the given [path], or `null` if no track with that
  /// path exists.
  Future<Track?> getTrackByPath(String path) {
    return (select(tracks)..where((t) => t.path.equals(path)))
        .getSingleOrNull();
  }

  /// Returns the Album with the given [id], or `null` if no album with that
  /// id exists.
  Future<Album?> getAlbumById(int id) {
    return (select(albums)..where((a) => a.id.equals(id))).getSingleOrNull();
  }

  /// Returns the DbAlbum with the given [id], or `null` if no album with that
  /// id exists.
  Future<DbAlbum?> getDbAlbumById(int id) async {
    final album = await getAlbumById(id);

    if (album == null) return null;

    final dbArtist = await getDbArtistById(album.artistId);

    if (dbArtist == null) return null;

    return DbAlbum(
      id: album.id,
      name: album.name,
      cover: album.cover,
      artist: dbArtist,
    );
  }

  /// Returns the DbTrack with the given [path], or `null` if no track with that
  /// path exists.
  Future<DbTrack?> getDbTrackByPath(String path) async {
    final track = await getTrackByPath(path);

    if (track == null) return null;

    final dbAlbum = await getDbAlbumById(track.albumId);
    final dbArtist = await getDbArtistById(track.artistId);

    if (dbAlbum == null || dbArtist == null) return null;

    return DbTrack(
      id: track.id,
      name: track.name,
      path: track.path,
      album: dbAlbum,
      artist: dbArtist,
      durationInMillis: track.durationInMillis,
      genres: await getDbGenresForTrack(track.id),
    );
  }

  /// Returns the DbArtist with the given [id], or `null` if no artist with that
  /// id exists.
  Future<DbArtist?> getDbArtistById(int id) async {
    final artist = await getArtistById(id);

    if (artist == null) return null;

    return DbArtist(
      id: artist.id,
      name: artist.name,
      image: artist.image,
    );
  }

  /// Returns the genres for the track with the given [trackId].
  Future<List<DbGenre>> getDbGenresForTrack(int trackId) async {
    final genres = await getGenresForTrack(trackId);

    return genres
        .map((genre) => DbGenre(id: genre.id, name: genre.name))
        .toList();
  }

  /// Returns the artist with the given [id], or `null` if no artist with that
  /// id exists.
  Future<Artist?> getArtistById(int id) {
    return (select(artists)..where((a) => a.id.equals(id))).getSingleOrNull();
  }

  /// Returns the genre with the given [id], or `null` if no genre with that
  /// id exists.
  Future<Genre?> getGenreById(int id) {
    return (select(genres)..where((g) => g.id.equals(id))).getSingleOrNull();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'hitbeat.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
