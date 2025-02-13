import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/progress_slider.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';

/// {@template playback_controls}
/// A widget that displays the playback controls and progress slider.
/// {@endtemplate}
class PlaybackControls extends StatefulWidget {
  /// {@macro playback_controls}
  const PlaybackControls({
    required this.player,
    required this.onNext,
    required this.onPrevious,
    required this.duration,
    required this.position,
    required this.onSeek,
    super.key,
  });

  /// The audio player
  final IAudioPlayer player;

  /// Called when the next button is pressed
  final FutureOr<void> Function() onNext;

  /// Called when the previous button is pressed
  final FutureOr<void> Function() onPrevious;

  /// The total duration of the current track
  final Duration duration;

  /// The current position of the track
  final Duration position;

  /// Called when the user seeks to a new position
  final FutureOr<void> Function(Duration duration) onSeek;

  @override
  State<PlaybackControls> createState() => _PlaybackControlsState();
}

class _PlaybackControlsState extends State<PlaybackControls>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final StreamSubscription<bool> _isPlayingSubscription;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.player.isPlaying ? 1.0 : 0.0,
    );

    _isPlayingSubscription = widget.player.isPlaying$.listen((isPlaying) {
      if (isPlaying) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _isPlayingSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 4,
            children: [
              StreamBuilder(
                stream: widget.player.repeat$,
                builder: (context, snapshot) {
                  return _ControlButton(
                    icon: Icon(
                      snapshot.data!.icon,
                      color: Colors.white70,
                      size: 16,
                    ),
                    onPressed: () async {
                      await widget.player.setRepeat(snapshot.data!.next);
                    },
                    size: 16,
                  );
                },
              ),
              _ControlButton(
                icon: const Icon(
                  Icons.skip_previous,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: widget.onPrevious,
                size: 24,
              ),
              _ControlButton(
                icon: AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: _controller,
                  color: Colors.white,
                  size: 36,
                ),
                onPressed: () async {
                  await widget.player.setIsPlaying(
                    isPlaying: !widget.player.isPlaying,
                  );
                },
                size: 36,
              ),
              _ControlButton(
                icon: const Icon(
                  Icons.skip_next,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: widget.onNext,
                size: 24,
              ),
              StreamBuilder(
                stream: widget.player.shuffle$,
                builder: (context, snapshot) {
                  return _ControlButton(
                    icon: Icon(
                      Icons.shuffle,
                      color: snapshot.data ?? false
                          ? Colors.white
                          : Colors.white70,
                      size: 16,
                    ),
                    onPressed: () async {
                      await widget.player.setShuffle(
                        shuffle: !snapshot.data!,
                      );
                    },
                    size: 16,
                  );
                },
              ),
            ],
          ),
          ProgressSlider(
            duration: widget.duration,
            position: widget.position,
            onSeek: widget.onSeek,
          ),
        ],
      ),
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
