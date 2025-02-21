import 'package:audio_service/audio_service.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/player/enums/repeat.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';
import 'package:hitbeat/src/services/cover_cache_service.dart';

/// An audio handler for the Hitbeat player
class HitbeatAudioHandler extends BaseAudioHandler {
  /// Creates a new Hitbeat audio handler
  HitbeatAudioHandler(this._player) {
    _initStreams();
  }

  /// The singleton instance of the Hitbeat audio handler
  static HitbeatAudioHandler? _instance;

  /// if the instance is initialized
  static bool get isInitialized => _instance != null;

  /// Gets the singleton instance of the Hitbeat audio handler
  static HitbeatAudioHandler get instance {
    if (_instance == null) {
      throw StateError('HitbeatAudioHandler not initialized');
    }
    return _instance!;
  }

  /// Initialize the singleton instance
  static Future<void> initialize(IAudioPlayer player) async {
    _instance = await AudioService.init(
      builder: () => HitbeatAudioHandler(Modular.get<IAudioPlayer>()),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.mrhaubrich.hitbeat',
        androidNotificationChannelName: 'Hitbeat',
        androidNotificationOngoing: true,
        preloadArtwork: true,
      ),
    );
  }

  final IAudioPlayer _player;

  void _initStreams() {
    _player
      ..currentTrack$.listen(_updateMediaItem)
      ..isPlaying$.listen((playing) {
        playbackState.add(
          playbackState.value.copyWith(
            playing: playing,
            controls: [
              MediaControl.skipToPrevious,
              if (playing) MediaControl.pause else MediaControl.play,
              MediaControl.skipToNext,
            ],
          ),
        );
      })
      ..currentTime$.listen((position) {
        playbackState.add(
          playbackState.value.copyWith(updatePosition: position),
        );
      });
  }

  void _updateMediaItem(Track? track) {
    if (track == null) return;

    final coverCacheService = Modular.get<CoverCacheService>();
    final coverPath = coverCacheService.getCoverPath(track.album.coverHash);
    final coverUri = Uri.tryParse(coverPath != null ? 'file://$coverPath' : '');

    mediaItem.add(
      MediaItem(
        id: track.path,
        title: track.name,
        artist: track.artist.name,
        album: track.album.name,
        artUri: coverUri,
        duration: track.duration,
      ),
    );
  }

  @override
  Future<void> play() => _player.setIsPlaying(isPlaying: true);

  @override
  Future<void> pause() => _player.setIsPlaying(isPlaying: false);

  @override
  Future<void> skipToNext() => _player.next();

  @override
  Future<void> skipToPrevious() => _player.previous();

  @override
  Future<void> seek(Duration position) => _player.setCurrentTime(position);

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) =>
      _player.setShuffle(shuffle: shuffleMode == AudioServiceShuffleMode.all);

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        return _player.setRepeat(Repeat.none);
      case AudioServiceRepeatMode.one:
        return _player.setRepeat(Repeat.one);
      case AudioServiceRepeatMode.all:
        return _player.setRepeat(Repeat.all);
      case AudioServiceRepeatMode.group:
        return _player.setRepeat(Repeat.all);
    }
  }

  @override
  Future<void> stop() async {
    await _player.pause();
    await super.stop();
  }
}
