part of 'add_songs_bloc.dart';

sealed class AddSongsEvent extends Equatable {
  const AddSongsEvent();

  @override
  List<Object?> get props => [];
}

final class AddSongsPickFiles extends AddSongsEvent {
  const AddSongsPickFiles();
}

final class AddSongsDropFiles extends AddSongsEvent {
  const AddSongsDropFiles(this.uris);

  final List<Uri?> uris;

  @override
  List<Object?> get props => [uris];
}

final class AddSongsSave extends AddSongsEvent {
  const AddSongsSave(this.songs);

  final List<Track> songs;

  @override
  List<Object?> get props => [songs];
}

final class AddSongsClear extends AddSongsEvent {
  const AddSongsClear();
}
