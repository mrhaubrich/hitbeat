part of 'add_songs_bloc.dart';

sealed class AddSongsState extends Equatable {
  const AddSongsState();

  @override
  List<Object?> get props => [];
}

final class AddSongsInitial extends AddSongsState {
  const AddSongsInitial();
}

final class AddSongsLoading extends AddSongsState {
  const AddSongsLoading();
}

final class AddSongsError extends AddSongsState {
  const AddSongsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class AddSongsSuccess extends AddSongsState {
  const AddSongsSuccess();
}

final class AddSongsLoaded extends AddSongsState {
  const AddSongsLoaded(this.songs);

  final List<Track> songs;

  @override
  List<Object?> get props => [songs];
}
