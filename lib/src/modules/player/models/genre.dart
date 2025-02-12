import 'package:equatable/equatable.dart';

/// {@template genre}
/// Represents a genre that contains multiple albums.
/// {@endtemplate}
class Genre extends Equatable {
  /// {@macro genre}
  const Genre({
    required this.name,
  });

  /// The name of the genre
  final String name;

  @override
  List<Object?> get props => [name];
}
