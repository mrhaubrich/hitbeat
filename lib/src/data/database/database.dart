import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Artists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  BlobColumn get image => blob().nullable()();
}

class Albums extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BlobColumn get cover => blob().nullable()();
  IntColumn get artistId => integer().references(Artists, #id)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {name, artistId},
      ];
}

class Genres extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

class Tracks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get path => text().unique()();
  IntColumn get durationInMillis => integer()();
  IntColumn get albumId => integer().references(Albums, #id)();
  IntColumn get artistId => integer().references(Artists, #id)();
}

class TrackGenres extends Table {
  IntColumn get trackId => integer().references(Tracks, #id)();
  IntColumn get genreId => integer().references(Genres, #id)();

  @override
  Set<Column> get primaryKey => {trackId, genreId};
}

@DriftDatabase(
  tables: [Artists, Albums, Genres, Tracks, TrackGenres],
)
class HitBeatDatabase extends _$HitBeatDatabase {
  HitBeatDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<int> insertArtist(ArtistsCompanion artist) {
    return into(artists).insert(
      artist,
      // mode: InsertMode.insertOrReplace,
    );
  }

  Future<int> insertAlbum(AlbumsCompanion album) {
    return into(albums).insert(
      album,
      // mode: InsertMode.insertOrReplace,
    );
  }

  Future<int> insertGenre(GenresCompanion genre) {
    return into(genres).insert(
      genre,
      // mode: InsertMode.insertOrReplace,
    );
  }

  Future<int> insertTrack(TracksCompanion track) {
    return into(tracks).insert(
      track,
      // mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> insertTrackGenre(TrackGenresCompanion trackGenre) {
    return into(trackGenres).insert(
      trackGenre,
      // mode: InsertMode.insertOrReplace,
    );
  }

  Future<List<Track>> getAllTracks() {
    return (select(tracks)
          ..orderBy([
            (t) => OrderingTerm(expression: t.name),
          ]))
        .get();
  }

  Future<List<Album>> getAlbumsByArtist(int artistId) {
    return (select(albums)..where((a) => a.artistId.equals(artistId))).get();
  }

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
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'hitbeat.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
