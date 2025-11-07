import 'dart:async';

import 'package:hitbeat/src/modules/player/enums/repeat.dart';
import 'package:hitbeat/src/modules/player/enums/track_state.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:rxdart/rxdart.dart';

/// {@template audio_player}
/// An audio player that plays audio files.
/// {@endtemplate}
class AudioPlayerJustAudio implements IAudioPlayer {
  /// {@macro audio_player}
  AudioPlayerJustAudio() {
    // ignore
    // ignore: discarded_futures
    _player = just_audio.AudioPlayer()..setVolume(1);
    _repeat = Repeat.none;
    _trackController = BehaviorSubject<Track?>();
    _timeController = BehaviorSubject<Duration>();
    _trackStateController = BehaviorSubject<TrackState>();
    unawaited(_initializePlayer());

    // Add listener for playback completion
    _playerStateController = _player.playerStateStream.listen((state) async {
      if (state.processingState == just_audio.ProcessingState.completed) {
        final firstTrack = _player.sequence.firstOrNull?.tag as Track?;
        Future.delayed(const Duration(milliseconds: 500), () {
          _trackController.add(firstTrack);
          _timeController.add(Duration.zero);
        });
        _trackStateController.add(TrackState.notPlaying);
      } else if (state.playing) {
        _trackStateController.add(TrackState.playing);
      } else {
        _trackStateController.add(TrackState.paused);
      }
    });
  }

  late final just_audio.AudioPlayer _player;
  late final BehaviorSubject<Track?> _trackController;
  late final BehaviorSubject<Duration> _timeController;
  late final BehaviorSubject<TrackState> _trackStateController;
  late final StreamSubscription<just_audio.PlayerState> _playerStateController;
  late Repeat _repeat;

  Future<void> _initializePlayer() async {
    await _player.setAudioSources([]);
    await _player.pause();
  }

  @override
  List<Track> get tracklist {
    return _player.sequence.map((source) => source.tag as Track).toList();
  }

  @override
  Future<void> dispose() async {
    await _playerStateController.cancel();
    await _player.dispose();
    await _trackController.close();
    await _timeController.close();
    await _trackStateController.close();
  }

  @override
  Future<void> addTrack(Track newSong) {
    _trackController.add(newSong);
    return _player.addAudioSource(
      just_audio.AudioSource.uri(
        Uri.parse(newSong.path),
        tag: newSong,
      ),
    );
  }

  @override
  Future<void> setTrack(Track newSong) async {
    _trackController.add(newSong);
    await _player.clearAudioSources();
    await _player.addAudioSource(
      just_audio.AudioSource.uri(
        Uri.parse(newSong.path),
        tag: newSong,
      ),
    );
    await _player.seek(Duration.zero, index: 0);
  }

  @override
  Future<void> clearTracklist() async {
    await _player.clearAudioSources();
    await _player.stop();
  }

  @override
  Future<void> concatTracks(List<Track> songs) {
    if (_player.sequence.isEmpty) {
      _trackController.add(songs.firstOrNull);
    }
    return _player.addAudioSources(
      songs
          .map(
            (song) => just_audio.AudioSource.uri(
              Uri.parse(song.path),
              tag: song,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<void> next() async {
    await _player.seekToNext();
  }

  @override
  Future<void> previous() async {
    if (_player.position.inSeconds > 5) {
      await _player.seek(Duration.zero, index: _player.currentIndex);
      return;
    }
    await _player.seekToPrevious();
  }

  @override
  bool get shuffle => _player.shuffleModeEnabled;

  @override
  Future<void> setShuffle({required bool shuffle}) {
    return _player.setShuffleModeEnabled(shuffle);
  }

  @override
  Track? get currentTrack {
    final index = _player.currentIndex;
    if (index != null) {
      return _player.sequence.elementAtOrNull(index)?.tag as Track?;
    }
    return null;
  }

  @override
  Repeat get repeat => _repeat;

  @override
  Future<void> setRepeat(Repeat repeat) {
    _repeat = repeat;
    switch (repeat) {
      case Repeat.none:
        return _player.setLoopMode(just_audio.LoopMode.off);
      case Repeat.one:
        return _player.setLoopMode(just_audio.LoopMode.one);
      case Repeat.all:
        return _player.setLoopMode(just_audio.LoopMode.all);
    }
  }

  @override
  bool get isPlaying => _player.playing;

  @override
  Future<void> setIsPlaying({required bool isPlaying}) {
    if (isPlaying) {
      return _player.play();
    } else {
      return _player.pause();
    }
  }

  @override
  double get volume => _player.volume;

  @override
  Future<void> setVolume(double volume) {
    return _player.setVolume(volume);
  }

  @override
  bool get muted => _player.volume == 0;

  @override
  Future<void> setMuted({required bool isMuted}) {
    if (isMuted) {
      return _player.setVolume(0);
    } else {
      return _player.setVolume(1);
    }
  }

  @override
  Duration get currentTime => _player.position;

  @override
  Future<void> setCurrentTime(Duration currentTime) {
    return _player.seek(currentTime);
  }

  @override
  Stream<Duration> get currentTime$ =>
      Rx.merge([_player.positionStream, _timeController.stream]);

  @override
  Stream<Track?> get currentTrack$ => Rx.merge([
    _player.currentIndexStream.map((index) {
      if (index != null && index >= 0) {
        return _player.sequence.elementAtOrNull(index)?.tag as Track?;
      }
      return null;
    }),
    _trackController.stream,
  ]).distinct((previous, next) => previous == next);

  @override
  Stream<double> get volume$ => _player.volumeStream;

  @override
  Stream<bool> get muted$ => _player.volumeStream.map((vol) => vol == 0);

  @override
  Stream<bool> get isPlaying$ => _player.playingStream;

  @override
  Stream<Repeat> get repeat$ => _player.loopModeStream.map((mode) {
    switch (mode) {
      case just_audio.LoopMode.off:
        return Repeat.none;
      case just_audio.LoopMode.one:
        return Repeat.one;
      case just_audio.LoopMode.all:
        return Repeat.all;
    }
  });

  @override
  Stream<bool> get shuffle$ => _player.shuffleModeEnabledStream;

  @override
  Stream<List<Track>> get tracklist$ {
    return _player.sequenceStream.map((sequence) {
      return sequence.map((source) => source.tag as Track).toList();
    });
  }

  @override
  Future<void> play(Track track, {List<Track>? tracklist}) async {
    if (tracklist != null) {
      await _player.clearAudioSources();
      await _player.addAudioSources(
        tracklist
            .map(
              (song) => just_audio.AudioSource.uri(
                Uri.parse(song.path),
                tag: song,
              ),
            )
            .toList(),
      );
    }
    final initialIndex = _player.sequence.indexWhere(
      (source) => source.tag == track,
    );

    _trackController.add(track); // Add this line to emit the track immediately

    await _player.setAudioSource(
      _player.audioSource!,
      initialIndex: initialIndex >= 0 ? initialIndex : 0,
    );
    await _player.play(); // Add this line to start playback immediately
  }

  @override
  Future<void> pause() {
    return _player.pause();
  }

  @override
  Stream<TrackState> get trackState$ => _trackStateController.stream;

  @override
  TrackState get trackState {
    if (_player.processingState == just_audio.ProcessingState.completed) {
      return TrackState.notPlaying;
    } else if (_player.playing) {
      return TrackState.playing;
    } else {
      return TrackState.paused;
    }
  }
}
