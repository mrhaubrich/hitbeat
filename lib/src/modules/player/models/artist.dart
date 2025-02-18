import 'dart:typed_data' show Uint8List;

import 'package:equatable/equatable.dart';
import 'package:hitbeat/src/modules/player/models/album.dart';

/// {@template artist}
/// Represents an artist that has multiple albums.
/// {@endtemplate}
class Artist extends Equatable {
  /// {@macro artist}
  const Artist({
    required this.name,
    required this.albums,
    this.image,
  });

  /// The name of the artist
  final String name;

  /// The image of the artist
  final Uint8List? image;

  /// The albums of the artist
  final List<Album> albums;

  @override
  List<Object?> get props => [name, image, albums];

  /// An empty artist
  static Artist empty = const Artist(
    name: 'Select an artist',
    albums: [],
  );

  /// Creates a copy of the [Artist] with the given fields replaced by
  /// the new values.
  Artist copyWith({
    String? name,
    Uint8List? image,
    List<Album>? albums,
  }) {
    return Artist(
      name: name ?? this.name,
      image: image ?? this.image,
      albums: albums ?? this.albums,
    );
  }
}
