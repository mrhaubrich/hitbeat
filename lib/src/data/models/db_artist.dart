import 'dart:typed_data';

import 'package:hitbeat/src/modules/player/models/artist.dart';

/// {@template db_artist}
/// A class that represents an artist in the database.
/// {@endtemplate}
class DbArtist {
  /// {@macro db_artist}
  DbArtist({
    required this.id,
    required this.name,
    this.image,
  });

  /// Creates a [DbArtist] from a map.
  factory DbArtist.fromMap(Map<String, dynamic> map) {
    return DbArtist(
      id: map['id'] as int,
      name: map['name'] as String,
      image: map['image'] as Uint8List?,
    );
  }

  /// Creates a [DbArtist] from an [Artist].
  factory DbArtist.fromEntity(Artist artist) {
    return DbArtist(
      id: 0, // This should be set when inserting into the database
      name: artist.name,
      image: artist.image,
    );
  }

  /// The id of the artist.
  final int id;

  /// The name of the artist.
  final String name;

  /// The image of the artist.
  final Uint8List? image;

  /// Converts the [DbArtist] to a map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }

  /// Converts the [DbArtist] to an [Artist].
  Artist toEntity() {
    return Artist(
      name: name,
      image: image,
      albums: const [], // Albums should be loaded separately
    );
  }
}
