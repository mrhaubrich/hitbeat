import 'package:flutter/material.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/album_cover.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/playback_controls.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/track_info.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/volume_control.dart';
import 'package:hitbeat/src/modules/player/models/album.dart';
import 'package:hitbeat/src/modules/player/models/artist.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';

/// The height of the bottom bar.
const kBottomBarHeight = 80.0;

/// {@template bottom_bar}
/// A bottom bar that displays the currently playing song.
/// {@endtemplate}
class BottomBar extends StatelessWidget {
  /// {@macro bottom_bar}
  const BottomBar({super.key});

  /// The track that is currently playing
  static const Track _track = Track(
    name: 'Rockstar',
    path: 'path/to/song.mp3',
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
  Widget build(BuildContext context) {
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
                      url: _track.album.cover,
                    ),
                    const Expanded(
                      child: TrackInfo(
                        track: _track,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 60,
                child: PlaybackControls(
                  isPlaying: true,
                  onPlayPause: () {},
                  onNext: () {},
                  onPrevious: () {},
                  onRepeat: () {},
                  onShuffle: () {},
                  duration: _track.duration,
                  position: const Duration(minutes: 1, seconds: 30),
                  onSeek: (position) {},
                ),
              ),
              Flexible(
                flex: 20,
                child: VolumeControl(
                  volume: 0.5,
                  onVolumeChanged: (volume) {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
