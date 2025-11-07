import 'dart:async';

import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:hitbeat/src/modules/player/enums/repeat.dart';
import 'package:hitbeat/src/modules/player/enums/track_state.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';
import 'package:rxdart/rxdart.dart';

/// An IAudioPlayer implementation backed by flutter_soloud
class AudioPlayerSoLoud implements IAudioPlayer {
  /// Creates a SoLoud-backed audio player.
  AudioPlayerSoLoud() {
    _trackController = BehaviorSubject<Track?>();
    _timeController = BehaviorSubject<Duration>.seeded(Duration.zero);
    _trackStateController = BehaviorSubject<TrackState>.seeded(
      TrackState.notPlaying,
    );
    _volumeController = BehaviorSubject<double>.seeded(1);
    _mutedController = BehaviorSubject<bool>.seeded(false);
    _isPlayingController = BehaviorSubject<bool>.seeded(false);
    _repeatController = BehaviorSubject<Repeat>.seeded(Repeat.none);
    _shuffleController = BehaviorSubject<bool>.seeded(false);
    _tracklistController = BehaviorSubject<List<Track>>.seeded(const []);
    unawaited(_init());
  }

  // SoLoud engine singleton
  final SoLoud _sl = SoLoud.instance;
  AudioSource? _currentSource;
  // Use a nullable handle instead of inaccessible error constant
  SoundHandle? _currentHandle;

  // Internal playlist handling
  final List<Track> _playlist = <Track>[];
  int _currentIndex = -1;

  // State controllers
  late final BehaviorSubject<Track?> _trackController;
  late final BehaviorSubject<Duration> _timeController;
  late final BehaviorSubject<TrackState> _trackStateController;
  late final BehaviorSubject<double> _volumeController;
  late final BehaviorSubject<bool> _mutedController;
  late final BehaviorSubject<bool> _isPlayingController;
  late final BehaviorSubject<Repeat> _repeatController;
  late final BehaviorSubject<bool> _shuffleController;
  late final BehaviorSubject<List<Track>> _tracklistController;

  // Timing helpers
  Timer? _ticker;
  Duration _basePosition = Duration.zero;
  DateTime? _startedAt;

  Future<void> _init() async {
    if (!_sl.isInitialized) {
      await _sl.init();
    }
    _sl.setGlobalVolume(1);
  }

  @override
  List<Track> get tracklist => List.unmodifiable(_playlist);

  @override
  void dispose() {
    _ticker?.cancel();
    if (_currentHandle != null) {
      unawaited(_sl.stop(_currentHandle!));
    }
    // Do not deinit SoLoud globally here; engine is a singleton in app scope
    unawaited(_trackController.close());
    unawaited(_timeController.close());
    unawaited(_trackStateController.close());
    unawaited(_volumeController.close());
    unawaited(_mutedController.close());
    unawaited(_isPlayingController.close());
    unawaited(_repeatController.close());
    unawaited(_shuffleController.close());
    unawaited(_tracklistController.close());
  }

  String _normalizePath(String path) {
    if (path.startsWith('file://')) return path.replaceFirst('file://', '');
    return path;
  }

  Future<void> _loadAndPlayCurrent({bool autoPlay = true}) async {
    if (_currentIndex < 0 || _currentIndex >= _playlist.length) return;
    final track = _playlist[_currentIndex];
    _trackController.add(track);
    if (_currentSource != null) {
      unawaited(_sl.disposeSource(_currentSource!));
    }
    _currentSource = await _sl.loadFile(_normalizePath(track.path));

    _basePosition = Duration.zero;
    _startedAt = null;
    _timeController.add(Duration.zero);

    if (autoPlay) {
      _currentHandle = await _sl.play(
        _currentSource!,
        volume: _volumeController.value,
        looping: repeat == Repeat.one,
      );
      _isPlayingController.add(true);
      _trackStateController.add(TrackState.playing);
      _startTicker();
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _startedAt = DateTime.now();
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (t) async {
      final track = currentTrack;
      if (track == null) return;

      final now = DateTime.now();
      final elapsed = _startedAt != null
          ? now.difference(_startedAt!)
          : Duration.zero;
      var pos = _basePosition + elapsed;
      if (pos > track.duration) pos = track.duration;
      _timeController.add(pos);

      // Detect end-of-track and advance according to repeat/shuffle
      if (pos >= track.duration - const Duration(milliseconds: 150)) {
        // Avoid tight loops
        _ticker?.cancel();
        await _onCompleted();
      }
    });
  }

  Future<void> _onCompleted() async {
    _isPlayingController.add(false);
    _trackStateController.add(TrackState.notPlaying);
    switch (repeat) {
      case Repeat.one:
        await setCurrentTime(Duration.zero);
        await setIsPlaying(isPlaying: true);
        return;
      case Repeat.all:
        await next();
        return;
      case Repeat.none:
        // stay stopped at end
        return;
    }
  }

  @override
  Future<void> play(Track track, {List<Track>? tracklist}) async {
    if (tracklist != null) {
      _playlist
        ..clear()
        ..addAll(tracklist);
      _tracklistController.add(List.unmodifiable(_playlist));
    } else if (_playlist.isEmpty) {
      _playlist.add(track);
      _tracklistController.add(List.unmodifiable(_playlist));
    }

    _currentIndex = _playlist.indexWhere((t) => t == track);
    if (_currentIndex < 0) {
      _playlist.add(track);
      _currentIndex = _playlist.length - 1;
      _tracklistController.add(List.unmodifiable(_playlist));
    }

    await _loadAndPlayCurrent();
  }

  @override
  Future<void> pause() async {
    if (_currentHandle != null) {
      _sl.setPause(_currentHandle!, true);
    }
    if (_startedAt != null) {
      _basePosition += DateTime.now().difference(_startedAt!);
      _startedAt = null;
    }
    _ticker?.cancel();
    _isPlayingController.add(false);
    _trackStateController.add(TrackState.paused);
  }

  @override
  Future<void> addTrack(Track newSong) async {
    _playlist.add(newSong);
    _tracklistController.add(List.unmodifiable(_playlist));
    _trackController.add(newSong);
  }

  @override
  Future<void> setTrack(Track newSong) async {
    if (_playlist.isEmpty) {
      _playlist.add(newSong);
      _tracklistController.add(List.unmodifiable(_playlist));
    }
    _currentIndex = _playlist.indexWhere((t) => t == newSong);
    if (_currentIndex < 0) {
      _playlist.insert(0, newSong);
      _currentIndex = 0;
      _tracklistController.add(List.unmodifiable(_playlist));
    }
    if (_currentHandle != null) {
      await _sl.stop(_currentHandle!);
    }
    _ticker?.cancel();
    await _loadAndPlayCurrent(autoPlay: false);
  }

  @override
  Future<void> clearTracklist() async {
    _playlist.clear();
    _currentIndex = -1;
    _tracklistController.add(const []);
    _trackController.add(null);
    _timeController.add(Duration.zero);
    _ticker?.cancel();
    _basePosition = Duration.zero;
    _startedAt = null;
    if (_currentHandle != null) {
      await _sl.stop(_currentHandle!);
    }
  }

  @override
  void concatTracks(List<Track> songs) {
    final wasEmpty = _playlist.isEmpty;
    _playlist.addAll(songs);
    _tracklistController.add(List.unmodifiable(_playlist));
    if (wasEmpty) {
      _trackController.add(songs.first);
    }
  }

  @override
  Future<void> next() async {
    if (_playlist.isEmpty) return;
    if (_shuffleController.value) {
      final nextIndex =
          (_currentIndex + 1 + (_playlist.length * 37)) % _playlist.length;
      _currentIndex = nextIndex;
    } else {
      _currentIndex = (_currentIndex + 1) % _playlist.length;
    }
    if (_currentHandle != null) {
      await _sl.stop(_currentHandle!);
    }
    _ticker?.cancel();
    await _loadAndPlayCurrent();
  }

  @override
  Future<void> previous() async {
    if (_playlist.isEmpty) return;
    final currentPos = currentTime;
    if (currentPos.inSeconds > 5) {
      await setCurrentTime(Duration.zero);
      return;
    }
    _currentIndex = (_currentIndex - 1) < 0
        ? _playlist.length - 1
        : _currentIndex - 1;
    if (_currentHandle != null) {
      await _sl.stop(_currentHandle!);
    }
    _ticker?.cancel();
    await _loadAndPlayCurrent();
  }

  @override
  Track? get currentTrack =>
      (_currentIndex >= 0 && _currentIndex < _playlist.length)
      ? _playlist[_currentIndex]
      : null;

  @override
  bool get shuffle => _shuffleController.value;

  @override
  Future<void> setShuffle({required bool shuffle}) async {
    _shuffleController.add(shuffle);
  }

  @override
  Repeat get repeat => _repeatController.value;

  @override
  Future<void> setRepeat(Repeat repeat) async {
    _repeatController.add(repeat);
  }

  @override
  bool get isPlaying => _isPlayingController.value;

  @override
  Future<void> setIsPlaying({required bool isPlaying}) async {
    if (isPlaying) {
      if (_currentSource == null) {
        if (_playlist.isEmpty) return;
        _currentIndex = 0;
        await _loadAndPlayCurrent();
        return;
      }
      // resume
      if (_currentHandle != null) {
        _sl.setPause(_currentHandle!, false);
      } else {
        _currentHandle = await _sl.play(
          _currentSource!,
          volume: _volumeController.value,
          looping: repeat == Repeat.one,
        );
      }
      _startedAt = DateTime.now();
      _startTicker();
      _isPlayingController.add(true);
      _trackStateController.add(TrackState.playing);
    } else {
      await pause();
    }
  }

  @override
  double get volume => _volumeController.value;

  @override
  Future<void> setVolume(double volume) async {
    final v = volume.clamp(0.0, 1.0);
    if (_currentHandle != null) {
      _sl.setVolume(_currentHandle!, v);
    }
    _volumeController.add(v);
    if (v == 0 && !_mutedController.value) {
      _mutedController.add(true);
    } else if (v > 0 && _mutedController.value) {
      _mutedController.add(false);
    }
  }

  @override
  bool get muted => _mutedController.value;

  @override
  Future<void> setMuted({required bool isMuted}) async {
    _mutedController.add(isMuted);
    if (isMuted) {
      await setVolume(0);
    } else {
      // restore to 1.0 if previously muted with zero volume
      if (_volumeController.value == 0) {
        await setVolume(1);
      }
    }
  }

  @override
  Duration get currentTime {
    if (_startedAt == null) return _basePosition;
    return _basePosition + DateTime.now().difference(_startedAt!);
  }

  @override
  Future<void> setCurrentTime(Duration currentTime) async {
    final t = currentTime < Duration.zero ? Duration.zero : currentTime;
    _basePosition = t;
    _startedAt = DateTime.now();
    if (_currentHandle != null) {
      _sl.seek(_currentHandle!, t);
    }
    _timeController.add(t);
  }

  @override
  Stream<Duration> get currentTime$ => _timeController.stream;

  @override
  Stream<Track?> get currentTrack$ => _trackController.stream.distinct();

  @override
  Stream<double> get volume$ => _volumeController.stream;

  @override
  Stream<bool> get muted$ => _mutedController.stream;

  @override
  Stream<bool> get isPlaying$ => _isPlayingController.stream;

  @override
  Stream<Repeat> get repeat$ => _repeatController.stream;

  @override
  Stream<bool> get shuffle$ => _shuffleController.stream;

  @override
  Stream<List<Track>> get tracklist$ => _tracklistController.stream;

  @override
  Stream<TrackState> get trackState$ => _trackStateController.stream;

  @override
  TrackState get trackState => _trackStateController.value;
}
