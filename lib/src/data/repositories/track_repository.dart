import 'package:drift/drift.dart';
import 'package:hitbeat/src/data/database/database.dart' hide Track;
import 'package:hitbeat/src/data/models/db_track.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';

class TrackRepository {
  TrackRepository(this._database);

  final HitBeatDatabase _database;

  Future<void> insertTrack(Track track) async {
    final dbTrack = DbTrack.fromEntity(track);

    // Insert artist first
    final artistId = await _database.insertArtist(
      ArtistsCompanion.insert(
        name: dbTrack.artist.name,
        image: Value(dbTrack.artist.image),
      ),
    );

    // Insert album
    final albumId = await _database.insertAlbum(
      AlbumsCompanion.insert(
        name: dbTrack.album.name,
        cover: Value(dbTrack.album.cover),
        artistId: artistId,
      ),
    );

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

    // Insert genres
    for (final genre in dbTrack.genres) {
      final genreId = await _database.insertGenre(
        GenresCompanion.insert(name: genre.name),
      );

      await _database.insertTrackGenre(
        TrackGenresCompanion.insert(
          trackId: trackId,
          genreId: genreId,
        ),
      );
    }
  }

  Future<List<Track>> getAllTracks() async {
    final tracks = await _database.getAllTracks();
    // Convert database tracks to domain tracks
    // You'll need to implement the conversion logic here
    return [];
  }
}
