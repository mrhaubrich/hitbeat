import 'package:equatable/equatable.dart';
import 'package:hitbeat/src/modules/player/models/album.dart';

/// {@template artist}
/// Represents an artist that has multiple albums.
/// {@endtemplate}
class Artist extends Equatable {
  /// {@macro artist}
  const Artist({
    required this.name,
    required this.image,
    required this.albums,
  });

  /// The name of the artist
  final String name;

  /// The image of the artist
  final String image;

  /// The albums of the artist
  final List<Album> albums;

  @override
  List<Object?> get props => [name, image, albums];

  /// An empty artist
  static Artist empty = const Artist(
    name: 'Select an artist',
    image: '',
    albums: [],
  );
}
