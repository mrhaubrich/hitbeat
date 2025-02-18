part of 'track_bloc.dart';

abstract class TrackBlocState extends Equatable {
  const TrackBlocState();

  @override
  List<Object?> get props => [];
}

class TrackInitial extends TrackBlocState {
  const TrackInitial();
}

class TrackLoaded extends TrackBlocState {
  const TrackLoaded({required this.tracks});

  final List<Track> tracks;

  @override
  List<Object?> get props => [tracks];
}

class TrackError extends TrackBlocState {
  const TrackError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
