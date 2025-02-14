import 'package:equatable/equatable.dart';
import 'package:hitbeat/src/modules/player/models/album.dart';
import 'package:hitbeat/src/modules/player/models/artist.dart';
import 'package:hitbeat/src/modules/player/models/genre.dart';

/// {@template track}
/// Represents a track that can be played by the player.
/// {@endtemplate}
class Track extends Equatable {
  /// {@macro track}
  const Track({
    required this.name,
    required this.path,
    required this.album,
    required this.artist,
    required this.duration,
    this.genres = const [],
  });

  /// The name of the track
  final String name;

  /// The path to the track file
  final String path;

  /// The duration of the track
  final Duration duration;

  /// The genre of the track
  final List<Genre> genres;

  /// The Album of the track
  final Album album;

  /// The Artist of the track
  final Artist artist;

  @override
  List<Object?> get props => [name, path, duration, genres, album, artist];

  /// An empty track
  static Track empty = Track(
    name: 'Select a track',
    album: Album.empty,
    artist: Artist.empty,
    duration: Duration.zero,
    path: '',
  );

  /// Creates a copy of the [Track] with the given fields replaced by
  /// the new values.
  Track copyWith({
    String? name,
    String? path,
    Album? album,
    Artist? artist,
    Duration? duration,
    List<Genre>? genres,
  }) {
    return Track(
      name: name ?? this.name,
      path: path ?? this.path,
      album: album ?? this.album,
      artist: artist ?? this.artist,
      duration: duration ?? this.duration,
      genres: genres ?? this.genres,
    );
  }
}
