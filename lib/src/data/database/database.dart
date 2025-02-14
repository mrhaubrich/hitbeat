import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Artists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BlobColumn get image => blob().nullable()();
}

class Albums extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BlobColumn get cover => blob().nullable()();
  IntColumn get artistId => integer().references(Artists, #id)();
}

class Genres extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

class Tracks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get path => text()();
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
    return into(artists).insertOnConflictUpdate(artist);
  }

  Future<int> insertAlbum(AlbumsCompanion album) {
    return into(albums).insertOnConflictUpdate(album);
  }

  Future<int> insertGenre(GenresCompanion genre) {
    return into(genres).insertOnConflictUpdate(genre);
  }

  Future<int> insertTrack(TracksCompanion track) {
    return into(tracks).insertOnConflictUpdate(track);
  }

  Future<void> insertTrackGenre(TrackGenresCompanion trackGenre) {
    return into(trackGenres).insertOnConflictUpdate(trackGenre);
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
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'hitbeat.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
