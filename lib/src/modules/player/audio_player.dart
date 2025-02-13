import 'dart:async';

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
    _playlist = just_audio.ConcatenatingAudioSource(children: []);
    _shuffle = false;
    _repeat = Repeat.none;
    _initializePlayer();
  }

  late final just_audio.AudioPlayer _player;
  late final just_audio.ConcatenatingAudioSource _playlist;
  late bool _shuffle;
  late Repeat _repeat;

  Future<void> _initializePlayer() async {
    await _player.setAudioSource(_playlist);
  }

  @override
  List<Track> get tracklist {
    return _playlist.sequence.map((source) => source.tag as Track).toList();
  }

  @override
  Future<void> dispose() async {
    await _player.dispose();
  }

  @override
  Future<void> addTrack(Track newSong) {
    return _playlist.add(
      just_audio.AudioSource.uri(
        Uri.parse(newSong.path),
        tag: newSong,
      ),
    );
  }

  @override
  Future<void> setTrack(Track newSong) async {
    await _playlist.clear();
    await _playlist.add(
      just_audio.AudioSource.uri(
        Uri.parse(newSong.path),
        tag: newSong,
      ),
    );
    await _player.seek(Duration.zero, index: 0);
  }

  @override
  void clearTracklist() {
    _playlist.clear();
    _player.stop();
  }

  @override
  Future<void> concatTracks(List<Track> songs) {
    return _playlist.addAll(
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
  bool get shuffle => _shuffle;

  @override
  void setShuffle({required bool shuffle}) {
    _shuffle = shuffle;
    _player.setShuffleModeEnabled(shuffle);
  }

  @override
  Track? get currentTrack {
    final index = _player.currentIndex;
    if (index != null) {
      return _playlist.sequence[index].tag as Track;
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
  Stream<Duration> get currentTime$ => _player.positionStream;

  @override
  Stream<Track?> get currentTrack$ => _player.currentIndexStream.map(
        (index) {
          if (index != null) {
            return _playlist.sequence[index].tag as Track;
          }
          return null;
        },
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
  Stream<bool> get shuffle$ => _player.shuffleModeEnabledStream;

  @override
  Stream<List<Track>> get tracklist$ {
    return _player.sequenceStream.map((sequence) {
      return sequence?.map((source) => source.tag as Track).toList() ?? [];
    });
  }
}
