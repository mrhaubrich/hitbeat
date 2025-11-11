import 'package:hitbeat/src/modules/playlist/models/playlist.dart';

/// {@template db_playlist}
/// A playlist stored in the database.
/// {@endtemplate}
class DbPlaylist {
  /// {@macro db_playlist}
  DbPlaylist({
    required this.id,
    required this.name,
    required this.description,
    required this.coverHash,
    required this.isSpecial,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [DbPlaylist] from a [Playlist].
  factory DbPlaylist.fromEntity(Playlist playlist) {
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

  /// Creates a [DbPlaylist] from a map.
  factory DbPlaylist.fromMap(Map<String, dynamic> map) {
    return DbPlaylist(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String?,
      coverHash: map['cover_hash'] as String?,
      isSpecial: map['is_special'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// The unique identifier for the playlist.
  final int id;

  /// The name of the playlist.
  final String name;

  /// The description of the playlist.
  final String? description;

  /// The cover art hash for the playlist.
  final String? coverHash;

  /// Whether this is a special system playlist (e.g., current queue).
  final bool isSpecial;

  /// When the playlist was created.
  final DateTime createdAt;

  /// When the playlist was last updated.
  final DateTime updatedAt;

  /// Converts the [DbPlaylist] to a map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cover_hash': coverHash,
      'is_special': isSpecial,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Converts the [DbPlaylist] to a [Playlist].
  Playlist toEntity() {
    return Playlist(
      id: id,
      name: name,
      description: description,
      coverHash: coverHash,
      isSpecial: isSpecial,
      createdAt: createdAt,
      updatedAt: updatedAt,
      tracks: const [], // Tracks should be loaded separately
    );
  }
}
