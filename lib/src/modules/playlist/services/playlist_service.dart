import 'package:drift/drift.dart';
import 'package:hitbeat/src/data/database/database.dart';
import 'package:hitbeat/src/modules/player/models/track.dart' as player_model;
import 'package:hitbeat/src/modules/playlist/models/playlist.dart'
    as playlist_model;

/// {@template playlist_service}
/// Service for managing playlists and the current playing queue.
/// {@endtemplate}
class PlaylistService {
  /// {@macro playlist_service}
  PlaylistService({required HitBeatDatabase database}) : _database = database;

  final HitBeatDatabase _database;

  /// Creates a new playlist.
  Future<int> createPlaylist({
    required String name,
    String? description,
    String? coverHash,
  }) async {
    final now = DateTime.now();
    return _database.createPlaylist(
      PlaylistsCompanion.insert(
        name: name,
        description: Value(description),
        coverHash: Value(coverHash),
        isSpecial: const Value(false),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  /// Returns all user playlists (excludes special playlists).
  Future<List<playlist_model.Playlist>> getAllPlaylists() async {
    final dbPlaylists = await _database.getAllPlaylists();

    final result = await Future.wait(
      dbPlaylists.map((dbPlaylist) async {
        final tracks = await _database.getPlaylistDbTracks(dbPlaylist.id);
        return playlist_model.Playlist(
          id: dbPlaylist.id,
          name: dbPlaylist.name,
          description: dbPlaylist.description,
          coverHash: dbPlaylist.coverHash,
          isSpecial: dbPlaylist.isSpecial,
          createdAt: dbPlaylist.createdAt,
          updatedAt: dbPlaylist.updatedAt,
          tracks: tracks.map((t) => t.toEntity()).toList(),
        );
      }),
    );

    return result;
  }

  /// Returns a playlist by its ID with all its tracks.
  Future<playlist_model.Playlist?> getPlaylistById(int id) async {
    final dbPlaylist = await _database.getPlaylistById(id);
    if (dbPlaylist == null) return null;

    final tracks = await _database.getPlaylistDbTracks(id);
    return playlist_model.Playlist(
      id: dbPlaylist.id,
      name: dbPlaylist.name,
      description: dbPlaylist.description,
      coverHash: dbPlaylist.coverHash,
      isSpecial: dbPlaylist.isSpecial,
      createdAt: dbPlaylist.createdAt,
      updatedAt: dbPlaylist.updatedAt,
      tracks: tracks.map((t) => t.toEntity()).toList(),
    );
  }

  /// Updates a playlist's name, description, and/or cover hash.
  Future<void> updatePlaylist({
    required int id,
    String? name,
    String? description,
    String? coverHash,
  }) async {
    await _database.updatePlaylist(
      PlaylistsCompanion(
        id: Value(id),
        name: name != null ? Value(name) : const Value.absent(),
        description: Value(description),
        coverHash: coverHash != null ? Value(coverHash) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Deletes a playlist.
  Future<void> deletePlaylist(int id) async {
    await _database.deletePlaylist(id);
  }

  /// Adds a track to a playlist.
  Future<void> addTrackToPlaylist({
    required int playlistId,
    required int trackId,
    int? position,
  }) async {
    await _database.addTrackToPlaylist(
      playlistId: playlistId,
      trackId: trackId,
      position: position,
    );
  }

  /// Removes a track from a playlist.
  Future<void> removeTrackFromPlaylist({
    required int playlistId,
    required int trackId,
    required int position,
  }) async {
    await _database.removeTrackFromPlaylist(
      playlistId: playlistId,
      trackId: trackId,
      position: position,
    );
  }

  /// Clears all tracks from a playlist.
  Future<void> clearPlaylist(int playlistId) async {
    await _database.clearPlaylist(playlistId);
  }

  // ==================== Current Queue Operations ====================

  /// Gets the special current queue playlist.
  /// Creates it if it doesn't exist.
  Future<playlist_model.Playlist> getCurrentQueue() async {
    final dbPlaylist = await _database.getCurrentQueuePlaylist();
    final tracks = await _database.getPlaylistDbTracks(dbPlaylist.id);

    return playlist_model.Playlist(
      id: dbPlaylist.id,
      name: dbPlaylist.name,
      description: dbPlaylist.description,
      coverHash: dbPlaylist.coverHash,
      isSpecial: dbPlaylist.isSpecial,
      createdAt: dbPlaylist.createdAt,
      updatedAt: dbPlaylist.updatedAt,
      tracks: tracks.map((t) => t.toEntity()).toList(),
    );
  }

  /// Saves the current playing queue to the database.
  /// This allows persisting the queue across app restarts.
  Future<void> saveCurrentQueue(List<player_model.Track> tracks) async {
    final queue = await _database.getCurrentQueuePlaylist();

    // Get track IDs from database
    final trackIds = <int>[];
    for (final track in tracks) {
      final dbTrack = await _database.getTrackByPath(track.path);
      if (dbTrack != null) {
        trackIds.add(dbTrack.id);
      }
    }

    await _database.setPlaylistTracks(
      playlistId: queue.id,
      trackIds: trackIds,
    );
  }

  /// Loads the current queue from the database.
  /// Returns the tracks that were in the queue when the app was last closed.
  Future<List<player_model.Track>> loadCurrentQueue() async {
    final queue = await getCurrentQueue();
    return queue.tracks;
  }

  /// Adds a track to the end of the current queue.
  Future<void> addToCurrentQueue(int trackId) async {
    final queue = await _database.getCurrentQueuePlaylist();
    await _database.addTrackToPlaylist(
      playlistId: queue.id,
      trackId: trackId,
    );
  }

  /// Clears the current queue.
  Future<void> clearCurrentQueue() async {
    final queue = await _database.getCurrentQueuePlaylist();
    await _database.clearPlaylist(queue.id);
  }
}
