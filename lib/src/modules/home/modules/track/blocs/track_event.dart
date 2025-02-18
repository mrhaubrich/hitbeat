part of 'track_bloc.dart';

/// Base class for all track-related events
abstract class TrackEvent extends Equatable {
  /// Base class for all track-related events
  const TrackEvent();

  @override
  List<Object?> get props => [];
}

/// {@template track_subscription_requested}
/// Event to request subscription to track updates.
///
/// This event is fired when the track list needs to be loaded or refreshed.
/// {@endtemplate}
class TrackSubscriptionRequested extends TrackEvent {
  /// {@macro track_subscription_requested}
  const TrackSubscriptionRequested();
}

/// Event to request playing or pausing a track.
///
/// {@template track_play_pause_requested}
/// This event handles both playing a new track and toggling play/pause state
/// of the current track.
///
/// Parameters:
/// - [track]: The track to be played or paused
/// - [tracklist]: The current list of tracks
/// - [isCurrentTrack]: Whether the track is currently selected
/// - [shouldPlay]: Whether the track should be played or paused
/// {@endtemplate}
class TrackPlayPauseRequested extends TrackEvent {
  /// {@macro track_play_pause_requested}
  const TrackPlayPauseRequested({
    required this.track,
    required this.tracklist,
    required this.isCurrentTrack,
    required this.shouldPlay,
  });

  /// The track to be played or paused
  final Track track;

  /// The current list of tracks
  final List<Track> tracklist;

  /// Whether the track is currently selected
  final bool isCurrentTrack;

  /// Whether the track should be played or paused
  final bool shouldPlay;

  @override
  List<Object?> get props => [track, tracklist, isCurrentTrack, shouldPlay];
}
