import 'package:hitbeat/src/modules/player/enums/repeat.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';
import 'package:just_audio/just_audio.dart' as just_audio;

/// {@template audio_player}
/// An audio player that plays audio files.
/// {@endtemplate}
class AudioPlayer implements IAudioPlayer {
  /// {@macro audio_player}
  AudioPlayer() {
    _player = just_audio.AudioPlayer()..setVolume(1);
    _tracklist = [];
    _currentIndex = 0;
    _shuffle = false;
    _repeat = Repeat.none;
  }

  late final just_audio.AudioPlayer _player;
  late final List<Track> _tracklist;
  late int _currentIndex;
  late bool _shuffle;
  late Repeat _repeat;

  @override
  List<Track> get tracklist => _tracklist;

  @override
  void dispose() {
    _player.dispose();
  }

  @override
  Future<void> setTrack(Track newSong) async {
    await _player.setAudioSource(
      just_audio.AudioSource.uri(Uri.parse(newSong.path)),
    );
    _tracklist
      ..clear()
      ..add(newSong);
    _currentIndex = 0;
  }

  @override
  void clearTracklist() {
    _tracklist.clear();
    _currentIndex = 0;
    _player.stop();
  }

  @override
  void concatTracks(List<Track> songs) {
    _tracklist.addAll(songs);
  }

  @override
  Future<void> next() async {
    if (_currentIndex < _tracklist.length - 1) {
      _currentIndex++;
      await setTrack(_tracklist[_currentIndex]);
    } else if (_repeat == Repeat.all) {
      _currentIndex = 0;
      await setTrack(_tracklist[_currentIndex]);
    }
  }

  @override
  Future<void> previous() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      await setTrack(_tracklist[_currentIndex]);
    } else if (_repeat == Repeat.all) {
      _currentIndex = _tracklist.length - 1;
      await setTrack(_tracklist[_currentIndex]);
    }
  }

  @override
  bool get shuffle => _shuffle;

  @override
  void setShuffle({required bool shuffle}) {
    _shuffle = shuffle;
    if (shuffle) {
      _tracklist.shuffle();
    }
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
  Stream<Duration> get currentTime$ => _player.positionStream;

  @override
  Stream<Track?> get currentTrack$ => _player.currentIndexStream.map(
        (index) => tracklist.elementAtOrNull(index ?? 0),
      );

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
  Stream<bool> get shuffle$ => Stream.value(_shuffle);

  @override
  Stream<List<Track>> get tracklist$ => Stream.value(_tracklist);
}
