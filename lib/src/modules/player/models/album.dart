import 'package:equatable/equatable.dart';
import 'package:hitbeat/src/modules/player/models/artist.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';

/// {@template album}
/// Represents an album that contains multiple tracks.
/// {@endtemplate}
class Album extends Equatable {
  /// {@macro album}
  const Album({
    required this.name,
    required this.cover,
    required this.tracks,
    required this.artist,
  });

  /// The name of the album
  final String name;

  /// The album cover
  final String cover;

  /// The tracks in the album
  final List<Track> tracks;

  /// The artist of the album
  final Artist artist;

  @override
  List<Object?> get props => [name, cover, tracks, artist];
}
