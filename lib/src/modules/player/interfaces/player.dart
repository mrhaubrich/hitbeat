import 'package:hitbeat/src/modules/player/enums/repeat.dart';
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

  /// Load a new track
  void setTrack(Track newSong);

  /// Clear the tracklist
  void clearTracklist();

  /// Concat a list of tracks to the tracklist
  void concatTracks(List<Track> songs);

  /// Skip to the next track
  void next();

  /// Go back to the previous track
  void previous();

  /// Shuffle the tracklist
  bool get shuffle;
  set shuffle(bool shuffle);

  /// Repeat mode
  Repeat get repeat;
  set repeat(Repeat repeat);

  /// If the player is currently playing
  bool get isPlaying;
  set isPlaying(bool isPlaying);

  /// The current volume of the player
  double get volume;
  set volume(double volume);

  /// If the player is muted
  bool get muted;
  set muted(bool isMuted);

  /// The current time of the player
  Duration get currentTime;
  set currentTime(Duration currentTime);
}
