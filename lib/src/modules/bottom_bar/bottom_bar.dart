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

/// The URL of the default album cover.
const kNoAlbumCover =
    'https://emby.media/community/uploads/inline/355992/5c1cc71abf1ee_genericcoverart.jpg';

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

  static const _post = Artist(
    name: 'Post Malone',
    image:
        'https://cdna.artstation.com/p/assets/images/images/028/352/344/large/sharjeel-khan-post-malone-hollywood-bleeding-cover-art-by-me3.jpg?1594221623',
    albums: [],
  );

  static const _hollywoodsBleeding = Album(
    name: "Hollywood's Bleeding",
    cover:
        'https://cdna.artstation.com/p/assets/images/images/028/352/344/large/sharjeel-khan-post-malone-hollywood-bleeding-cover-art-by-me3.jpg?1594221623',
    tracks: [],
    artist: _post,
  );

  /// The track that is currently playing
  static const _tracks = [
    Track(
      name: 'Allergic',
      path: 'asset:///assets/songs/Allergic.mp3',
      album: _hollywoodsBleeding,
      artist: _post,
      duration: Duration(minutes: 2, seconds: 37),
    ),
    Track(
      name: 'Circles',
      path: 'asset:///assets/songs/Post_Malone_-_Circles.mp3',
      album: _hollywoodsBleeding,
      artist: _post,
      duration: Duration(minutes: 3, seconds: 36),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeTracks();
  }

  Future<void> _initializeTracks() async {
    if (_player.tracklist.isEmpty) {
      try {
        _player.concatTracks(_tracks);
      } catch (e) {
        print('Error initializing tracks: $e');
        // Retry after a delay
        await Future.delayed(const Duration(seconds: 1));
        _player.concatTracks(_tracks);
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

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
                child: StreamBuilder(
                  stream: _player.currentTrack$,
                  builder: (context, snapshot) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AlbumCover.network(
                          url: snapshot.data?.album.cover ?? kNoAlbumCover,
                        ),
                        Expanded(
                          child: TrackInfo(
                            track: snapshot.data ?? Track.empty,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Flexible(
                flex: 60,
                child: PlaybackControls(
                  player: _player,
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
