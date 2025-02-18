part of 'track_bloc.dart';

abstract class TrackEvent extends Equatable {
  const TrackEvent();

  @override
  List<Object?> get props => [];
}

class TrackSubscriptionRequested extends TrackEvent {
  const TrackSubscriptionRequested();
}

class TrackPlayPauseRequested extends TrackEvent {
  const TrackPlayPauseRequested({
    required this.track,
    required this.tracklist,
    required this.isCurrentTrack,
    required this.shouldPlay,
  });

  final Track track;
  final List<Track> tracklist;
  final bool isCurrentTrack;
  final bool shouldPlay;

  @override
  List<Object?> get props => [track, tracklist, isCurrentTrack, shouldPlay];
}
