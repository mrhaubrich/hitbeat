import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:hitbeat/src/data/models/db_album.dart' show DbAlbum;
import 'package:hitbeat/src/data/models/db_artist.dart' show DbArtist;
import 'package:hitbeat/src/data/models/db_genre.dart' show DbGenre;
import 'package:hitbeat/src/data/models/db_playlist.dart' show DbPlaylist;
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

  /// The cover hash of the album.
  TextColumn get coverHash => text().nullable()();

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

/// Table for storing playlists.
class Playlists extends Table {
  /// The primary key for the table.
  IntColumn get id => integer().autoIncrement()();

  /// The name of the playlist.
  TextColumn get name => text()();

  /// The description of the playlist.
  TextColumn get description => text().nullable()();

  /// The cover art hash for the playlist (similar to album covers).
  TextColumn get coverHash => text().nullable()();

  /// Whether this is a special system playlist (e.g., current queue).
  BoolColumn get isSpecial => boolean().withDefault(const Constant(false))();

  /// The current track index for playback (used by queue playlist).
  IntColumn get currentTrackIndex => integer().nullable()();

  /// The current playback position in milliseconds (used by queue playlist).
  IntColumn get currentPositionMs => integer().nullable()();

  /// When the playlist was created.
  DateTimeColumn get createdAt => dateTime()();

  /// When the playlist was last updated.
  DateTimeColumn get updatedAt => dateTime()();
}

/// Table for storing the tracks in playlists.
class PlaylistTracks extends Table {
  /// The playlist ID.
  IntColumn get playlistId => integer().references(Playlists, #id)();

  /// The track ID.
  IntColumn get trackId => integer().references(Tracks, #id)();

  /// The position of the track in the playlist (0-based).
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {playlistId, trackId, position};
}

/// {@template hitbeat_database}
/// The database for the HitBeat application.
/// {@endtemplate}
@DriftDatabase(
  tables: [
    Artists,
    Albums,
    Genres,
    Tracks,
    TrackGenres,
    Playlists,
    PlaylistTracks,
  ],
)
class HitBeatDatabase extends _$HitBeatDatabase {
  /// {@macro hitbeat_database}
  HitBeatDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Migration from schema version 1 to 2: add playlists
          await m.createTable(playlists);
          await m.createTable(playlistTracks);
        }
        if (from < 3) {
          // Migration from schema version 2 to 3: add coverHash to playlists
          await m.addColumn(playlists, playlists.coverHash);
        }
        if (from < 4) {
          // Migration from schema version 3 to 4: add playback state fields
          await m.addColumn(playlists, playlists.currentTrackIndex);
          await m.addColumn(playlists, playlists.currentPositionMs);
        }
      },
    );
  }

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
    return (select(tracks)..orderBy([
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
    ])..where(trackGenres.trackId.equals(trackId));

    return query.map((row) => row.readTable(genres)).get();
  }

  /// Returns the artist with the given [name], or `null` if no artist with that
  Future<Artist?> getArtistByName(String name) {
    return (select(
      artists,
    )..where((a) => a.name.equals(name))).getSingleOrNull();
  }

  /// Returns the album with the given [name] and [artistId], or `null`
  /// if no album with that
  /// name and artistId exists.
  Future<Album?> getAlbumByNameAndArtist(String name, int artistId) {
    return (select(albums)..where((a) {
          return a.name.equals(name) & a.artistId.equals(artistId);
        }))
        .getSingleOrNull();
  }

  /// Returns the genre with the given [name], or `null` if no genre with that
  /// name exists.
  Future<Genre?> getGenreByName(String name) {
    return (select(
      genres,
    )..where((g) => g.name.equals(name))).getSingleOrNull();
  }

  /// Returns the track with the given [path], or `null` if no track with that
  /// path exists.
  Future<Track?> getTrackByPath(String path) {
    return (select(
      tracks,
    )..where((t) => t.path.equals(path))).getSingleOrNull();
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
      coverHash: album.coverHash,
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

  // ==================== Playlist Operations ====================

  /// Creates a new playlist.
  Future<int> createPlaylist(PlaylistsCompanion playlist) {
    return into(playlists).insert(playlist);
  }

  /// Returns all playlists.
  Future<List<Playlist>> getAllPlaylists({bool includeSpecial = false}) {
    final query = select(playlists);
    if (!includeSpecial) {
      query.where((p) => p.isSpecial.equals(false));
    }
    return (query..orderBy([(p) => OrderingTerm(expression: p.name)])).get();
  }

  /// Returns a playlist by its ID.
  Future<Playlist?> getPlaylistById(int id) {
    return (select(playlists)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  /// Returns a playlist by its name.
  Future<Playlist?> getPlaylistByName(String name) {
    return (select(
      playlists,
    )..where((p) => p.name.equals(name))).getSingleOrNull();
  }

  /// Returns the special current queue playlist, creating it if it doesn't exist.
  Future<Playlist> getCurrentQueuePlaylist() async {
    const queueName = '__CURRENT_QUEUE__';
    var playlist = await getPlaylistByName(queueName);

    if (playlist == null) {
      final now = DateTime.now();
      final id = await createPlaylist(
        PlaylistsCompanion.insert(
          name: queueName,
          description: const Value('Current playing queue'),
          isSpecial: const Value(true),
          createdAt: now,
          updatedAt: now,
        ),
      );
      playlist = await getPlaylistById(id);
    }

    return playlist!;
  }

  /// Updates a playlist.
  Future<int> updatePlaylist(PlaylistsCompanion playlist) {
    return (update(
      playlists,
    )..where((p) => p.id.equals(playlist.id.value))).write(playlist);
  }

  /// Deletes a playlist by its ID.
  Future<int> deletePlaylist(int id) async {
    // First delete all track associations
    await (delete(
      playlistTracks,
    )..where((pt) => pt.playlistId.equals(id))).go();
    // Then delete the playlist
    return (delete(playlists)..where((p) => p.id.equals(id))).go();
  }

  /// Adds a track to a playlist at the specified position.
  Future<void> addTrackToPlaylist({
    required int playlistId,
    required int trackId,
    int? position,
  }) async {
    // If position is not specified, add to the end
    final pos =
        position ??
        await playlistTracks
            .count(where: (pt) => pt.playlistId.equals(playlistId))
            .getSingle();

    await into(playlistTracks).insert(
      PlaylistTracksCompanion.insert(
        playlistId: playlistId,
        trackId: trackId,
        position: pos,
      ),
    );

    // Update the playlist's updatedAt timestamp
    await (update(playlists)..where((p) => p.id.equals(playlistId))).write(
      PlaylistsCompanion(updatedAt: Value(DateTime.now())),
    );
  }

  /// Removes a track from a playlist.
  Future<void> removeTrackFromPlaylist({
    required int playlistId,
    required int trackId,
    required int position,
  }) async {
    await (delete(playlistTracks)..where(
          (pt) =>
              pt.playlistId.equals(playlistId) &
              pt.trackId.equals(trackId) &
              pt.position.equals(position),
        ))
        .go();

    // Reorder remaining tracks
    final tracks = await getPlaylistTracks(playlistId);
    for (var i = 0; i < tracks.length; i++) {
      await (update(playlistTracks)..where(
            (pt) =>
                pt.playlistId.equals(playlistId) &
                pt.trackId.equals(tracks[i].id),
          ))
          .write(PlaylistTracksCompanion(position: Value(i)));
    }

    // Update the playlist's updatedAt timestamp
    await (update(playlists)..where((p) => p.id.equals(playlistId))).write(
      PlaylistsCompanion(updatedAt: Value(DateTime.now())),
    );
  }

  /// Returns all tracks in a playlist.
  Future<List<Track>> getPlaylistTracks(int playlistId) async {
    final query =
        select(tracks).join([
            innerJoin(
              playlistTracks,
              playlistTracks.trackId.equalsExp(tracks.id),
            ),
          ])
          ..where(playlistTracks.playlistId.equals(playlistId))
          ..orderBy([OrderingTerm.asc(playlistTracks.position)]);

    final results = await query.get();
    return results.map((row) => row.readTable(tracks)).toList();
  }

  /// Returns all DbTracks in a playlist.
  Future<List<DbTrack>> getPlaylistDbTracks(int playlistId) async {
    final tracks = await getPlaylistTracks(playlistId);

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

  /// Returns a DbPlaylist with all its tracks.
  Future<DbPlaylist?> getDbPlaylistById(int id) async {
    final playlist = await getPlaylistById(id);
    if (playlist == null) return null;

    return DbPlaylist(
      id: playlist.id,
      name: playlist.name,
      description: playlist.description,
      coverHash: playlist.coverHash,
      isSpecial: playlist.isSpecial,
      createdAt: playlist.createdAt,
      updatedAt: playlist.updatedAt,
    );
  }

  /// Clears all tracks from a playlist.
  Future<void> clearPlaylist(int playlistId) async {
    await (delete(
      playlistTracks,
    )..where((pt) => pt.playlistId.equals(playlistId))).go();

    // Update the playlist's updatedAt timestamp
    await (update(playlists)..where((p) => p.id.equals(playlistId))).write(
      PlaylistsCompanion(updatedAt: Value(DateTime.now())),
    );
  }

  /// Sets the entire tracklist for a playlist, replacing existing tracks.
  Future<void> setPlaylistTracks({
    required int playlistId,
    required List<int> trackIds,
  }) async {
    // Clear existing tracks
    await clearPlaylist(playlistId);

    // Add new tracks
    for (var i = 0; i < trackIds.length; i++) {
      await into(playlistTracks).insert(
        PlaylistTracksCompanion.insert(
          playlistId: playlistId,
          trackId: trackIds[i],
          position: i,
        ),
      );
    }

    // Update the playlist's updatedAt timestamp
    await (update(playlists)..where((p) => p.id.equals(playlistId))).write(
      PlaylistsCompanion(updatedAt: Value(DateTime.now())),
    );
  }

  /// Saves the current playback state (track index and position) for the queue.
  Future<void> saveQueuePlaybackState({
    required int currentTrackIndex,
    required Duration currentPosition,
  }) async {
    final queue = await getCurrentQueuePlaylist();
    await (update(playlists)..where((p) => p.id.equals(queue.id))).write(
      PlaylistsCompanion(
        currentTrackIndex: Value(currentTrackIndex),
        currentPositionMs: Value(currentPosition.inMilliseconds),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Loads the saved playback state for the queue.
  /// Returns null if no state is saved.
  Future<({int trackIndex, Duration position})?>
  loadQueuePlaybackState() async {
    final queue = await getCurrentQueuePlaylist();
    final trackIndex = queue.currentTrackIndex;
    final positionMs = queue.currentPositionMs;

    if (trackIndex == null || positionMs == null) {
      return null;
    }

    return (
      trackIndex: trackIndex,
      position: Duration(milliseconds: positionMs),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'hitbeat.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
