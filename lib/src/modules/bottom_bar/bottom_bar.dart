import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/album_cover.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/playback_controls.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/track_info.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/volume_control.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';
import 'package:hitbeat/src/modules/player/models/album.dart';
import 'package:hitbeat/src/modules/player/models/artist.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';

/// The height of the bottom bar.
const kBottomBarHeight = 80.0;

/// {@template bottom_bar}
/// A bottom bar that displays the currently playing song.
/// {@endtemplate}
class BottomBar extends StatefulWidget {
  /// {@macro bottom_bar}
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  final IAudioPlayer _player = Modular.get<IAudioPlayer>();
  final Duration _position = Duration.zero;

  /// The track that is currently playing
  static const Track _track = Track(
    name: 'Rockstar',
    path: 'assets/songs/Post_Malone_-_Circles.mp3',
    album: Album(
      name: 'Beerbongs & Bentleys',
      cover: 'https://i.scdn.co/image/ab67616d0000b273b1c4b76e23414c9f20242268',
      tracks: [],
      artist: Artist(
        name: 'Post Malone',
        image:
            'https://i.scdn.co/image/ab67616d0000b273b1c4b76e23414c9f20242268',
        albums: [],
      ),
    ),
    artist: Artist(
      name: 'Post Malone',
      image: 'https://i.scdn.co/image/ab67616d0000b273b1c4b76e23414c9f20242268',
      albums: [],
    ),
    duration: Duration(minutes: 3, seconds: 38),
  );

  @override
  void initState() {
    super.initState();
    if (_player.tracklist.isEmpty) {
      _player.setTrack(_track);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTrack =
        _player.tracklist.isEmpty ? _track : _player.tracklist.first;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
        left: 10,
        right: 10,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.all(Radius.circular(14)),
        ),
        child: SizedBox(
          height: kBottomBarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 20,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AlbumCover.network(
                      url: currentTrack.album.cover,
                    ),
                    Expanded(
                      child: TrackInfo(
                        track: currentTrack,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 60,
                child: PlaybackControls(
                  isPlaying: _player.isPlaying,
                  onPlayPause: () => setState(() {
                    _player.isPlaying = !_player.isPlaying;
                  }),
                  onNext: () => setState(_player.next),
                  onPrevious: () => setState(_player.previous),
                  onRepeat: () {
                    setState(() {
                      _player.repeat = _player.repeat.next;
                    });
                  },
                  onShuffle: () {
                    setState(() {
                      _player.shuffle = !_player.shuffle;
                    });
                  },
                  duration: currentTrack.duration,
                  position: _player.currentTime,
                  onSeek: (position) => setState(() {
                    _player.currentTime = position;
                  }),
                ),
              ),
              Flexible(
                flex: 20,
                child: VolumeControl(
                  volume: _player.volume,
                  onVolumeChanged: (volume) => setState(() {
                    _player.volume = volume;
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
