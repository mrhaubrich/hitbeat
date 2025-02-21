import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';

/// {@template animated_play_pause_button}
/// A widget that displays an animated play/pause button.
/// {@endtemplate}
class AnimatedPlayPauseButton extends StatefulWidget {
  /// {@macro animated_play_pause_button}
  const AnimatedPlayPauseButton({
    required this.player,
    super.key,
  });

  /// The audio player
  final IAudioPlayer player;

  @override
  State<AnimatedPlayPauseButton> createState() =>
      _AnimatedPlayPauseButtonState();
}

class _AnimatedPlayPauseButtonState extends State<AnimatedPlayPauseButton>
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
    return IconButton(
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
      style: IconButton.styleFrom(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
