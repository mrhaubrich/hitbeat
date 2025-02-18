import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/player/models/artist.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';
import 'package:hitbeat/src/services/cover_cache_service.dart';

/// {@template album}
/// Represents an album that contains multiple tracks.
/// {@endtemplate}
class Album extends Equatable {
  /// {@macro album}
  const Album({
    required this.name,
    required this.tracks,
    required this.artist,
    this.coverHash,
  });

  /// The name of the album
  final String name;

  /// The hash reference to the album cover
  final String? coverHash;

  /// The tracks in the album
  final List<Track> tracks;

  /// The artist of the album
  final Artist artist;

  @override
  List<Object?> get props => [name, coverHash, tracks, artist];

  /// The cover art of the album
  Uint8List? get cover {
    final coverCache = Modular.get<CoverCacheService>();

    return coverCache.getCover(coverHash);
  }

  /// An empty album
  static Album empty = Album(
    name: 'Select an album',
    tracks: const [],
    artist: Artist.empty,
  );

  /// Creates a copy of the [Album] with the given fields replaced by
  /// the new values.
  Album copyWith({
    String? name,
    String? coverHash,
    List<Track>? tracks,
    Artist? artist,
  }) {
    return Album(
      name: name ?? this.name,
      coverHash: coverHash ?? this.coverHash,
      tracks: tracks ?? this.tracks,
      artist: artist ?? this.artist,
    );
  }
}
