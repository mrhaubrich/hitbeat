import 'package:flutter/material.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/album_cover.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/playback_controls.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/song_info.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/volume_control.dart';

/// The height of the bottom bar.
const kBottomBarHeight = 80.0;

/// {@template bottom_bar}
/// A bottom bar that displays the currently playing song.
/// {@endtemplate}
class BottomBar extends StatelessWidget {
  /// {@macro bottom_bar}
  const BottomBar({super.key});

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
              const Flexible(
                flex: 20,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PlayerAlbumCover(),
                    Expanded(
                      child: PlayerSongInfo(
                        songName:
                            'Very Very Long Song Name That is Very Long Even More Long',
                        artistName: 'Artist Name',
                      ),
                    ),
                  ],
                ),
              ),
              const Flexible(
                flex: 60,
                child: PlaybackControls(),
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
