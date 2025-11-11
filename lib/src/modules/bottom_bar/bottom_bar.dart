import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/album_cover.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/playback_controls.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/track_info.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/volume_control.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';
import 'package:hitbeat/src/services/cover_cache_service.dart';

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
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: Theme.of(context).primaryColor,
          ),
        ),
        margin: EdgeInsets.zero,
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
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          firstChild: const AlbumCover.network(
                            key: ValueKey(kNoAlbumCover),
                            url: kNoAlbumCover,
                          ),
                          secondChild: () {
                            final coverHash = snapshot.data?.album.coverHash;
                            final coverPath = Modular.get<CoverCacheService>()
                                .getCoverPath(coverHash);
                            if (coverPath != null) {
                              return AlbumCover.file(
                                key: ValueKey(coverHash),
                                file: File(coverPath),
                              );
                            }
                            return const SizedBox();
                          }(),
                          // Avoid triggering a synchronous disk read via Album.
                          // cover.
                          // Rely on the presence of a coverHash instead.
                          crossFadeState: snapshot.data?.album.coverHash == null
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
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
