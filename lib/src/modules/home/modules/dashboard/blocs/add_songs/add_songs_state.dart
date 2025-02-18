part of 'add_songs_bloc.dart';

/// An event that is triggered when the user wants to add songs.
sealed class AddSongsState extends Equatable {
  const AddSongsState();

  @override
  List<Object?> get props => [];
}

/// {@template add_songs_initial}
/// The initial state of the [AddSongsBloc].
/// {@endtemplate}
final class AddSongsInitial extends AddSongsState {
  /// {@macro add_songs_initial}
  const AddSongsInitial();
}

/// {@template add_songs_loading}
/// The state of the [AddSongsBloc] when adding songs.
/// {@endtemplate}
final class AddSongsLoading extends AddSongsState {
  /// {@macro add_songs_loading}
  const AddSongsLoading();
}

/// {@template add_songs_error}
/// The state of the [AddSongsBloc] when an error occurs.
/// {@endtemplate}
final class AddSongsError extends AddSongsState {
  /// {@macro add_songs_error}
  const AddSongsError(this.message);

  /// The error message.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// {@template add_songs_success}
/// The state of the [AddSongsBloc] when the songs are added successfully.
/// {@endtemplate}
final class AddSongsSuccess extends AddSongsState {
  /// {@macro add_songs_success}
  const AddSongsSuccess();
}

/// {@template add_songs_loaded}
/// The state of the [AddSongsBloc] when the songs are loaded.
/// {@endtemplate}
final class AddSongsLoaded extends AddSongsState {
  /// {@macro add_songs_loaded}
  const AddSongsLoaded(this.songs);

  /// The list of [Track]s.
  final List<Track> songs;

  @override
  List<Object?> get props => [songs];
}
