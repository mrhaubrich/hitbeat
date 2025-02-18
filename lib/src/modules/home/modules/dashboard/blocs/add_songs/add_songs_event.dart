part of 'add_songs_bloc.dart';

/// An event that is triggered when the user wants to add songs.
sealed class AddSongsEvent extends Equatable {
  const AddSongsEvent();

  @override
  List<Object?> get props => [];
}

/// {@template add_songs_pick_files}
/// An event that is triggered when the user wants to pick files.
/// {@endtemplate}
final class AddSongsPickFiles extends AddSongsEvent {
  /// {@macro add_songs_pick_files}
  const AddSongsPickFiles();
}

/// {@template add_songs_drop_files}
/// An event that is triggered when the user drops files.
/// {@endtemplate}
final class AddSongsDropFiles extends AddSongsEvent {
  /// {@macro add_songs_drop_files}
  const AddSongsDropFiles(this.uris);

  /// The list of [Uri]s of the files to be added.
  final List<Uri?> uris;

  @override
  List<Object?> get props => [uris];
}

/// {@template add_songs_save}
/// An event that is triggered when the user wants to save the songs.
/// {@endtemplate}
final class AddSongsSave extends AddSongsEvent {
  /// {@macro add_songs_save}
  const AddSongsSave(this.songs);

  /// The list of [Track]s to be saved.
  final List<Track> songs;

  @override
  List<Object?> get props => [songs];
}

/// {@template add_songs_clear}
/// An event that is triggered when the user wants to clear the songs.
/// {@endtemplate}
final class AddSongsClear extends AddSongsEvent {
  /// {@macro add_songs_clear}
  const AddSongsClear();
}
