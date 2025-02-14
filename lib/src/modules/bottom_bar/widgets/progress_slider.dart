import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';
import 'package:interactive_slider/interactive_slider.dart';

/// {@template progress_slider}
/// A widget that displays the song progress slider.
/// {@endtemplate}
class ProgressSlider extends StatefulWidget {
  /// {@macro progress_slider}
  const ProgressSlider({
    required this.player,
    this.onSeek,
    super.key,
  });

  /// The audio player
  final IAudioPlayer player;

  /// Callback when user seeks to a new position
  final FutureOr<void> Function(Duration position)? onSeek;

  @override
  State<ProgressSlider> createState() => _ProgressSliderState();
}

class _ProgressSliderState extends State<ProgressSlider> {
  late final InteractiveSliderController _controller;
  late final StreamSubscription<Duration> _positionSubscription;
  bool _isHovering = false;
  Duration? hoverPosition;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    var initialTime = 0.0;
    if (widget.player.currentTrack != null) {
      initialTime = widget.player.currentTime.inMilliseconds /
          widget.player.currentTrack!.duration.inMilliseconds;
    }
    _controller = InteractiveSliderController(
      initialTime,
    );

    _positionSubscription = widget.player.currentTime$.listen((event) {
      if (hoverPosition == null) {
        _controller.value = event.inMilliseconds /
            (widget.player.currentTrack?.duration ?? Duration.zero)
                .inMilliseconds;
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveSlider(
      padding: EdgeInsets.zero,
      startIcon: StreamBuilder(
        stream: widget.player.currentTime$,
        builder: (context, snapshot) {
          return Text(
            _formatDuration(snapshot.data ?? Duration.zero),
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          );
        },
      ),
      endIcon: StreamBuilder(
        stream: widget.player.currentTrack$,
        builder: (context, snapshot) {
          return Text(
            _formatDuration(snapshot.data?.duration ?? Duration.zero),
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          );
        },
      ),
      centerIcon: _isHovering
          ? Text(
              _formatDuration(hoverPosition ?? Duration.zero),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            )
          : null,
      controller: _controller,
      onProgressUpdated: (value) async {
        setState(() {
          _isHovering = false;
        });
        final newPosition = Duration(
          milliseconds: (value *
                  (widget.player.currentTrack?.duration.inMilliseconds ?? 0))
              .round(),
        );
        await widget.onSeek?.call(newPosition);
        setState(() {
          hoverPosition = null;
        });
      },
      onFocused: (value) {
        final newPosition = Duration(
          milliseconds: (value *
                  (widget.player.currentTrack?.duration.inMilliseconds ?? 0))
              .round(),
        );
        setState(() {
          _isHovering = true;
          hoverPosition = newPosition;
        });
      },
      onChanged: (value) {
        if (!_isHovering) return;
        final newDuration = Duration(
          milliseconds: (value *
                  (widget.player.currentTrack?.duration.inMilliseconds ?? 0))
              .round(),
        );
        setState(() {
          hoverPosition = newDuration;
        });
      },
    );
  }
}
