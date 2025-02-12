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
    this.genre,
  });

  /// The name of the track
  final String name;

  /// The path to the track file
  final String path;

  /// The duration of the track
  final Duration duration;

  /// The genre of the track
  final Genre? genre;

  /// The Album of the track
  final Album album;

  /// The Artist of the track
  final Artist artist;

  @override
  List<Object?> get props => [name, path, duration, genre, album, artist];
}
