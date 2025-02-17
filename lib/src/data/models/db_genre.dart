import 'package:hitbeat/src/modules/player/models/genre.dart';

/// {@template db_genre}
/// A class that represents a genre in the database.
/// {@endtemplate}
class DbGenre {
  /// {@macro db_genre}
  DbGenre({
    required this.id,
    required this.name,
  });

  /// Creates a [DbGenre] from a map.
  factory DbGenre.fromMap(Map<String, dynamic> map) {
    return DbGenre(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }

  /// Creates a [DbGenre] from a [Genre].
  factory DbGenre.fromEntity(Genre genre) {
    return DbGenre(
      id: 0, // This should be set when inserting into the database
      name: genre.name,
    );
  }

  /// The id of the genre.
  final int id;

  /// The name of the genre.
  final String name;

  /// Converts the [DbGenre] to a map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  /// Converts the [DbGenre] to a [Genre].
  Genre toEntity() {
    return Genre(name: name);
  }
}
