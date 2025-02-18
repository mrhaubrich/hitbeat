import 'dart:async';

import 'package:hitbeat/src/modules/player/enums/repeat.dart';
import 'package:hitbeat/src/modules/player/enums/track_state.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';

// typedef TimeUpdateCallback = void Function();
// typedef ErrorCallback = void Function(Error error);

// typedef OnLoadedMetadata = void Function();
// typedef OnEnded = void Function();

// typedef IAudioPlayerEvents = {
//   TimeUpdateCallback? onTimeUpdate,
//   OnLoadedMetadata? onLoadedMetadata,
//   OnEnded? onEnded,
//   ErrorCallback? onError,
// };

/// {@template audio_player}
/// An interface for an audio player.
/// {@endtemplate}
abstract class IAudioPlayer {
  /// The current track
  List<Track> get tracklist;

  /// Must call when disposing the player
  void dispose();

  /// Play a track
  Future<void> play(Track track, {List<Track>? tracklist});

  /// Pause the player
  Future<void> pause();

  /// Add a new track to the tracklist
  Future<void> addTrack(Track newSong);

  /// Load a new track
  Future<void> setTrack(Track newSong);

  /// Clear the tracklist
  void clearTracklist();

  /// Concat a list of tracks to the tracklist
  void concatTracks(List<Track> songs);

  /// Skip to the next track
  Future<void> next();

  /// Go back to the previous track
  Future<void> previous();

  /// The current track
  Track? get currentTrack;

  /// Shuffle the tracklist
  bool get shuffle;

  /// Set the shuffle mode
  FutureOr<void> setShuffle({required bool shuffle});

  /// Repeat mode
  Repeat get repeat;

  /// Set the repeat mode
  Future<void> setRepeat(Repeat repeat);

  /// If the player is currently playing
  bool get isPlaying;

  /// Set the player to be playing
  Future<void> setIsPlaying({required bool isPlaying});

  /// The current volume of the player
  double get volume;

  /// Set the volume of the player
  Future<void> setVolume(double volume);

  /// If the player is muted
  bool get muted;

  /// Set the player to be muted
  Future<void> setMuted({required bool isMuted});

  /// The current time of the player
  Duration get currentTime;

  /// Set the current time of the player
  Future<void> setCurrentTime(Duration currentTime);

  /// Stream of the current time of the player
  Stream<Duration> get currentTime$;

  /// Stream of the current track
  Stream<Track?> get currentTrack$;

  /// Stream of the current volume
  Stream<double> get volume$;

  /// Stream of the current mute state
  Stream<bool> get muted$;

  /// Stream of the current playing state
  Stream<bool> get isPlaying$;

  /// Stream of the current repeat state
  Stream<Repeat> get repeat$;

  /// Stream of the current shuffle state
  Stream<bool> get shuffle$;

  /// Stream of the current tracklist
  Stream<List<Track>> get tracklist$;

  /// Stream of the current track state
  Stream<TrackState> get trackState$;

  /// Stream of the current track duration
  TrackState get trackState;
}
