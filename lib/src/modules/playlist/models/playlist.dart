import 'package:hitbeat/src/modules/player/models/track.dart';

/// {@template playlist}
/// Represents a playlist containing tracks.
/// {@endtemplate}
class Playlist {
  /// {@macro playlist}
  const Playlist({
    required this.id,
    required this.name,
    required this.isSpecial,
    required this.createdAt,
    required this.updatedAt,
    required this.tracks,
    this.description,
    this.coverHash,
  });

  /// The unique identifier for the playlist.
  final int id;

  /// The name of the playlist.
  final String name;

  /// The description of the playlist.
  final String? description;

  /// The cover art hash for the playlist.
  final String? coverHash;

  /// Whether this is a special system playlist (e.g., current queue).
  /// Special playlists cannot be deleted and have special behaviors.
  final bool isSpecial;

  /// When the playlist was created.
  final DateTime createdAt;

  /// When the playlist was last updated.
  final DateTime updatedAt;

  /// The tracks in this playlist.
  final List<Track> tracks;

  /// The special playlist name for the current playing queue.
  static const String currentQueueName = '__CURRENT_QUEUE__';

  /// Creates a copy of this playlist with the given fields replaced.
  Playlist copyWith({
    int? id,
    String? name,
    String? description,
    String? coverHash,
    bool? isSpecial,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Track>? tracks,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverHash: coverHash ?? this.coverHash,
      isSpecial: isSpecial ?? this.isSpecial,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tracks: tracks ?? this.tracks,
    );
  }

  /// Creates an empty playlist template for new playlists.
  static Playlist createNew({
    required String name,
    String? description,
    String? coverHash,
    bool isSpecial = false,
  }) {
    final now = DateTime.now();
    return Playlist(
      id: 0, // Will be set by database
      name: name,
      description: description,
      coverHash: coverHash,
      isSpecial: isSpecial,
      createdAt: now,
      updatedAt: now,
      tracks: [],
    );
  }

  /// Creates the special current queue playlist.
  static Playlist createCurrentQueue() {
    return createNew(
      name: currentQueueName,
      description: 'Current playing queue',
      isSpecial: true,
    );
  }
}
