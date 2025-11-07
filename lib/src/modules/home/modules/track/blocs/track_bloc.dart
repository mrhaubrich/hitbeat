import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitbeat/src/modules/home/modules/track/controllers/track_controller.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';

part 'track_event.dart';
part 'track_state.dart';

/// {@template track_bloc}
/// A BLoC to manage the track state.
/// {@endtemplate}
class TrackBloc extends Bloc<TrackEvent, TrackBlocState> {
  /// {@macro track_bloc}
  TrackBloc({
    required TrackController controller,
    required IAudioPlayer player,
  }) : _controller = controller,
       _player = player,
       super(const TrackInitial()) {
    on<TrackSubscriptionRequested>(_onSubscriptionRequested);
    on<TrackPlayPauseRequested>(_onPlayPauseRequested);
  }

  final TrackController _controller;
  final IAudioPlayer _player;

  Future<void> _onSubscriptionRequested(
    TrackSubscriptionRequested event,
    Emitter<TrackBlocState> emit,
  ) async {
    await emit.forEach(
      _controller.tracks$,
      onData: (tracks) => TrackLoaded(tracks: tracks),
      onError: (error, stackTrace) => const TrackError('Failed to load tracks'),
    );
  }

  Future<void> _onPlayPauseRequested(
    TrackPlayPauseRequested event,
    Emitter<TrackBlocState> emit,
  ) async {
    if (event.isCurrentTrack) {
      await _player.setIsPlaying(isPlaying: event.shouldPlay);
    } else {
      await _player.play(event.track, tracklist: event.tracklist);
    }
  }
}
