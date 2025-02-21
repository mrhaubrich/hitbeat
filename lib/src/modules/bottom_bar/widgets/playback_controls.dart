import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/animated_play_pause_button.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/progress_slider.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';

/// {@template playback_controls}
/// A widget that displays the playback controls and progress slider.
/// {@endtemplate}
class PlaybackControls extends StatelessWidget {
  /// {@macro playback_controls}
  const PlaybackControls({
    required this.player,
    super.key,
  });

  /// The audio player
  final IAudioPlayer player;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RepaintBoundary(
            child: _ControlButtonsRow(player: player),
          ),
          RepaintBoundary(
            child: ProgressSlider(
              player: player,
              onSeek: (position) async {
                await player.setCurrentTime(position);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButtonsRow extends StatelessWidget {
  const _ControlButtonsRow({
    required this.player,
  });

  final IAudioPlayer player;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 4,
      children: [
        RepaintBoundary(
          child: _RepeatButton(player: player),
        ),
        _ControlButton(
          icon: const Icon(
            Icons.skip_previous,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () async {
            await player.previous();
          },
          size: 24,
        ),
        RepaintBoundary(
          child: AnimatedPlayPauseButton(player: player),
        ),
        _ControlButton(
          icon: const Icon(
            Icons.skip_next,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () async {
            await player.next();
          },
          size: 24,
        ),
        RepaintBoundary(
          child: _ShuffleButton(player: player),
        ),
      ],
    );
  }
}

class _RepeatButton extends StatelessWidget {
  const _RepeatButton({required this.player});

  final IAudioPlayer player;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: player.repeat$,
      builder: (context, snapshot) {
        return _ControlButton(
          icon: Icon(
            snapshot.data?.icon,
            color: Colors.white70,
            size: 16,
          ),
          onPressed: () async {
            await player.setRepeat(snapshot.data!.next);
          },
          size: 16,
        );
      },
    );
  }
}

class _ShuffleButton extends StatelessWidget {
  const _ShuffleButton({required this.player});

  final IAudioPlayer player;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: player.shuffle$,
      builder: (context, snapshot) {
        return _ControlButton(
          icon: Icon(
            Icons.shuffle,
            color: snapshot.data ?? false ? Colors.white : Colors.white70,
            size: 16,
          ),
          onPressed: () async {
            await player.setShuffle(
              shuffle: !snapshot.data!,
            );
          },
          size: 16,
        );
      },
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.onPressed,
    this.size = 32,
  });

  final Widget icon;
  final FutureOr<void> Function() onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButtonTheme(
      data: IconButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          visualDensity: VisualDensity.compact,
          alignment: Alignment.center,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      child: IconButton(
        icon: icon,
        onPressed: () async {
          await onPressed();
        },
      ),
    );
  }
}
