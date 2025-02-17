import 'package:drift/drift.dart';
import 'package:hitbeat/src/data/database/database.dart' hide Track;
import 'package:hitbeat/src/data/models/db_track.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';

/// {@template track_repository}
/// Repository for managing tracks.
/// {@endtemplate}
class TrackRepository {
  /// {@macro track_repository}
  TrackRepository(this._database);

  final HitBeatDatabase _database;

  Future<int> _getOrCreateArtist(String name, Uint8List? image) async {
    final existingArtist = await _database.getArtistByName(name);
    if (existingArtist != null) return existingArtist.id;

    return _database.insertArtist(
      ArtistsCompanion.insert(
        name: name,
        image: Value(image),
      ),
    );
  }

  Future<int> _getOrCreateAlbum(
    String name,
    Uint8List? cover,
    int artistId,
  ) async {
    final existingAlbum =
        await _database.getAlbumByNameAndArtist(name, artistId);
    if (existingAlbum != null) return existingAlbum.id;

    return _database.insertAlbum(
      AlbumsCompanion.insert(
        name: name,
        cover: Value(cover),
        artistId: artistId,
      ),
    );
  }

  Future<int> _getOrCreateGenre(String name) async {
    final existingGenre = await _database.getGenreByName(name);
    if (existingGenre != null) return existingGenre.id;

    return _database.insertGenre(
      GenresCompanion.insert(name: name),
    );
  }

  /// Inserts a track into the database.
  Future<void> insertTrack(Track track) async {
    final dbTrack = DbTrack.fromEntity(track);

    // Get or create artist
    final artistId = await _getOrCreateArtist(
      dbTrack.artist.name,
      dbTrack.artist.image,
    );

    // Get or create album
    final albumId = await _getOrCreateAlbum(
      dbTrack.album.name,
      dbTrack.album.cover,
      artistId,
    );

    // Check if track exists
    final existingTrack = await _database.getTrackByPath(dbTrack.path);
    if (existingTrack != null) return;

    // Insert track
    final trackId = await _database.insertTrack(
      TracksCompanion.insert(
        name: dbTrack.name,
        path: dbTrack.path,
        durationInMillis: dbTrack.durationInMillis,
        albumId: albumId,
        artistId: artistId,
      ),
    );

    // Get or create genres
    for (final genre in dbTrack.genres) {
      final genreId = await _getOrCreateGenre(genre.name);
      await _database.insertTrackGenre(
        TrackGenresCompanion.insert(
          trackId: trackId,
          genreId: genreId,
        ),
      );
    }
  }

  /// Retrieves all tracks from the database.
  Future<List<Track>> getAllTracks() async {
    final tracks = await _database.getAllTracks();
    // Convert database tracks to domain tracks
    // You'll need to implement the conversion logic here
    return [];
  }
}
