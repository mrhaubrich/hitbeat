import 'package:hitbeat/src/modules/player/enums/repeat.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';
import 'package:just_audio/just_audio.dart' as just_audio;

class AudioPlayer implements IAudioPlayer {
  AudioPlayer() {
    _player = just_audio.AudioPlayer();
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
      just_audio.AudioSource.file(newSong.path),
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
  void next() {
    if (_currentIndex < _tracklist.length - 1) {
      _currentIndex++;
      setTrack(_tracklist[_currentIndex]);
    } else if (_repeat == Repeat.all) {
      _currentIndex = 0;
      setTrack(_tracklist[_currentIndex]);
    }
  }

  @override
  void previous() {
    if (_currentIndex > 0) {
      _currentIndex--;
      setTrack(_tracklist[_currentIndex]);
    } else if (_repeat == Repeat.all) {
      _currentIndex = _tracklist.length - 1;
      setTrack(_tracklist[_currentIndex]);
    }
  }

  @override
  bool get shuffle => _shuffle;

  @override
  set shuffle(bool shuffle) {
    _shuffle = shuffle;
    if (shuffle) {
      _tracklist.shuffle();
    }
  }

  @override
  Repeat get repeat => _repeat;

  @override
  set repeat(Repeat repeat) {
    _repeat = repeat;
    switch (repeat) {
      case Repeat.none:
        _player.setLoopMode(just_audio.LoopMode.off);
      case Repeat.one:
        _player.setLoopMode(just_audio.LoopMode.one);
      case Repeat.all:
        _player.setLoopMode(just_audio.LoopMode.all);
    }
  }

  @override
  bool get isPlaying => _player.playing;

  @override
  set isPlaying(bool isPlaying) {
    if (isPlaying) {
      _player.play();
    } else {
      _player.pause();
    }
  }

  @override
  double get volume => _player.volume;

  @override
  set volume(double volume) {
    _player.setVolume(volume);
  }

  @override
  bool get muted => _player.volume == 0;

  @override
  set muted(bool isMuted) {
    if (isMuted) {
      _player.setVolume(0);
    } else {
      _player.setVolume(1);
    }
  }

  @override
  Duration get currentTime => _player.position;

  @override
  set currentTime(Duration currentTime) {
    _player.seek(currentTime);
  }
}
