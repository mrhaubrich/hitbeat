import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/album_cover.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/playback_controls.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/song_info.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/volume_control.dart';
import 'package:hitbeat/src/modules/home/controllers/bottom_bar_controller.dart';

const kBottomBarHeight = 80.0;

/// {@template bottom_bar}
/// A bottom bar that displays the currently playing song.
/// {@endtemplate}
class BottomBar extends StatelessWidget {
  /// {@macro bottom_bar}
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Modular.get<BottomBarController>(),
      builder: (context, child) {
        final controller = Modular.get<BottomBarController>();
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCirc,
          height: controller.isBottomBarVisible ? kBottomBarHeight : 0,
          margin: EdgeInsets.only(
            bottom: controller.isBottomBarVisible ? 10 : 0,
            left: 10,
            right: 10,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.9),
            borderRadius: controller.isBottomBarVisible
                ? const BorderRadius.all(Radius.circular(14))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                flex: 20,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PlayerAlbumCover(),
                    PlayerSongInfo(),
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
        );
      },
    );
  }
}
