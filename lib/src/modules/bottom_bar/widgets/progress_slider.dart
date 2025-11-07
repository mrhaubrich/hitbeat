import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';
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
  final _isHoveringNotifier = ValueNotifier<bool>(false);
  final _hoverPositionNotifier = ValueNotifier<Duration?>(null);

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
      initialTime =
          widget.player.currentTime.inMilliseconds /
          widget.player.currentTrack!.duration.inMilliseconds;
    }
    _controller = InteractiveSliderController(
      initialTime,
    );

    _positionSubscription = widget.player.currentTime$.listen((event) {
      if (_hoverPositionNotifier.value == null) {
        _controller.value =
            event.inMilliseconds /
            (widget.player.currentTrack?.duration ?? Duration.zero)
                .inMilliseconds;
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _controller.dispose();
    _isHoveringNotifier.dispose();
    _hoverPositionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveSlider(
      padding: EdgeInsets.zero,
      startIcon: _TimeText(
        stream: widget.player.currentTime$,
        formatDuration: _formatDuration,
      ),
      endIcon: _DurationText(
        stream: widget.player.currentTrack$,
        formatDuration: _formatDuration,
      ),
      centerIcon: ValueListenableBuilder<bool>(
        valueListenable: _isHoveringNotifier,
        builder: (context, isHovering, _) {
          if (!isHovering) return const SizedBox.shrink();
          return ValueListenableBuilder<Duration?>(
            valueListenable: _hoverPositionNotifier,
            builder: (context, hoverPosition, _) {
              return Text(
                _formatDuration(hoverPosition ?? Duration.zero),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              );
            },
          );
        },
      ),
      controller: _controller,
      onProgressUpdated: (value) async {
        _isHoveringNotifier.value = false;
        final newPosition = Duration(
          milliseconds:
              (value *
                      (widget.player.currentTrack?.duration.inMilliseconds ??
                          0))
                  .round(),
        );
        await widget.onSeek?.call(newPosition);
        _hoverPositionNotifier.value = null;
      },
      onFocused: (value) {
        final newPosition = Duration(
          milliseconds:
              (value *
                      (widget.player.currentTrack?.duration.inMilliseconds ??
                          0))
                  .round(),
        );
        _isHoveringNotifier.value = true;
        _hoverPositionNotifier.value = newPosition;
      },
      onChanged: (value) {
        if (!_isHoveringNotifier.value) return;
        final newDuration = Duration(
          milliseconds:
              (value *
                      (widget.player.currentTrack?.duration.inMilliseconds ??
                          0))
                  .round(),
        );
        _hoverPositionNotifier.value = newDuration;
      },
    );
  }
}

class _TimeText extends StatelessWidget {
  const _TimeText({
    required this.stream,
    required this.formatDuration,
  });

  final Stream<Duration> stream;
  final String Function(Duration) formatDuration;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: stream,
      builder: (context, snapshot) {
        return Text(
          formatDuration(snapshot.data ?? Duration.zero),
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        );
      },
    );
  }
}

class _DurationText extends StatelessWidget {
  const _DurationText({
    required this.stream,
    required this.formatDuration,
  });

  final Stream<Track?> stream;
  final String Function(Duration) formatDuration;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        return Text(
          formatDuration(snapshot.data?.duration ?? Duration.zero),
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        );
      },
    );
  }
}
