import 'dart:async';

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
  late final StreamSubscription<Track?> _trackSubscription;
  late final StreamSubscription<Duration> _positionSubscription;
  Track? _currentTrack;
  Duration _position = Duration.zero;

  /// The track that is currently playing
  static const Track _track = Track(
    name: 'Circles',
    path:
        '/home/marhaubrich/Music/Post Malone - Hollywoods Bleeding [FlexyOkay.com]/Post_Malone_-_Circles_FlexyOkay.com.mp3',
    album: Album(
      name: "Hollywood's Bleeding",
      cover:
          'https://cdna.artstation.com/p/assets/images/images/028/352/344/large/sharjeel-khan-post-malone-hollywood-bleeding-cover-art-by-me3.jpg?1594221623',
      tracks: [],
      artist: Artist(
        name: 'Post Malone',
        image:
            'https://cdna.artstation.com/p/assets/images/images/028/352/344/large/sharjeel-khan-post-malone-hollywood-bleeding-cover-art-by-me3.jpg?1594221623',
        albums: [],
      ),
    ),
    artist: Artist(
      name: 'Post Malone',
      image:
          'https://cdna.artstation.com/p/assets/images/images/028/352/344/large/sharjeel-khan-post-malone-hollywood-bleeding-cover-art-by-me3.jpg?1594221623',
      albums: [],
    ),
    duration: Duration(minutes: 3, seconds: 36),
  );

  @override
  void initState() {
    super.initState();
    if (_player.tracklist.isEmpty) {
      _player.setTrack(_track);
    }

    _trackSubscription = _player.currentTrack$.listen((track) {
      setState(() => _currentTrack = track);
    });

    _positionSubscription = _player.currentTime$.listen((position) {
      setState(() => _position = position);
    });
  }

  @override
  void dispose() {
    _trackSubscription.cancel();
    _positionSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTrack = _currentTrack ?? _track;

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
                  player: _player,
                  onNext: _player.next,
                  onPrevious: _player.previous,
                  duration: currentTrack.duration,
                  position: _position,
                  onSeek: (position) async {
                    await _player.setCurrentTime(position);
                  },
                ),
              ),
              Flexible(
                flex: 20,
                child: StreamBuilder(
                  stream: _player.volume$,
                  builder: (context, snapshot) {
                    return VolumeControl(
                      volume: snapshot.data ?? 1,
                      onVolumeChanged: (volume) async {
                        await _player.setVolume(volume);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
