part of 'track_bloc.dart';

/// Base class for all track-related states
abstract class TrackBlocState extends Equatable {
  /// Base class for all track-related states
  const TrackBlocState();

  @override
  List<Object?> get props => [];
}

/// {@template track_initial}
/// The initial state of the track bloc.
/// This state is used before any tracks are loaded.
/// {@endtemplate}
class TrackInitial extends TrackBlocState {
  /// {@macro track_initial}
  const TrackInitial();
}

/// {@template track_loading}
/// State indicating that tracks are currently being loaded.
/// {@endtemplate}
class TrackLoading extends TrackBlocState {
  /// {@macro track_loading}
  const TrackLoading();

  @override
  List<Object?> get props => [];
}

/// {@template track_loaded}
/// State indicating that tracks have been successfully loaded.
/// {@endtemplate}
class TrackLoaded extends TrackBlocState {
  /// {@macro track_loaded}
  const TrackLoaded({required this.tracks});

  /// The list of loaded tracks
  final List<Track> tracks;

  @override
  List<Object?> get props => [tracks];
}

/// {@template track_error}
/// State indicating that an error occurred while loading tracks.
/// {@endtemplate}
class TrackError extends TrackBlocState {
  /// {@macro track_error}
  const TrackError(this.message);

  /// The error message describing what went wrong
  final String message;

  @override
  List<Object?> get props => [message];
}
