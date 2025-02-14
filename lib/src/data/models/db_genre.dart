import 'package:hitbeat/src/modules/player/models/genre.dart';

class DbGenre {
  DbGenre({
    required this.id,
    required this.name,
  });

  factory DbGenre.fromMap(Map<String, dynamic> map) {
    return DbGenre(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }

  factory DbGenre.fromEntity(Genre genre) {
    return DbGenre(
      id: 0, // This should be set when inserting into the database
      name: genre.name,
    );
  }
  final int id;
  final String name;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  Genre toEntity() {
    return Genre(name: name);
  }
}
