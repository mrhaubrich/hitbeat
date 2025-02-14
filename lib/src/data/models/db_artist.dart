import 'dart:typed_data';

import 'package:hitbeat/src/modules/player/models/artist.dart';

class DbArtist {
  DbArtist({
    required this.id,
    required this.name,
    this.image,
  });

  factory DbArtist.fromMap(Map<String, dynamic> map) {
    return DbArtist(
      id: map['id'] as int,
      name: map['name'] as String,
      image: map['image'] as Uint8List?,
    );
  }

  factory DbArtist.fromEntity(Artist artist) {
    return DbArtist(
      id: 0, // This should be set when inserting into the database
      name: artist.name,
      image: artist.image,
    );
  }
  final int id;
  final String name;
  final Uint8List? image;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }

  Artist toEntity() {
    return Artist(
      name: name,
      image: image,
      albums: const [], // Albums should be loaded separately
    );
  }
}
