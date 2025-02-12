import 'package:flutter/material.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/progress_slider.dart';

/// {@template playback_controls}
/// A widget that displays the playback controls and progress slider.
/// {@endtemplate}
class PlaybackControls extends StatefulWidget {
  /// {@macro playback_controls}
  const PlaybackControls({
    required this.isPlaying,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onRepeat,
    required this.onShuffle,
    required this.duration,
    required this.position,
    required this.onSeek,
    super.key,
    this.isRepeatEnabled = false,
    this.isShuffleEnabled = false,
  });

  /// Whether the player is currently playing
  final bool isPlaying;

  /// Called when the play/pause button is pressed
  final VoidCallback onPlayPause;

  /// Called when the next button is pressed
  final VoidCallback onNext;

  /// Called when the previous button is pressed
  final VoidCallback onPrevious;

  /// Called when the repeat button is pressed
  final VoidCallback onRepeat;

  /// Called when the shuffle button is pressed
  final VoidCallback onShuffle;

  /// The total duration of the current track
  final Duration duration;

  /// The current position of the track
  final Duration position;

  /// Called when the user seeks to a new position
  final ValueChanged<Duration> onSeek;

  /// Whether repeat mode is enabled
  final bool isRepeatEnabled;

  /// Whether shuffle mode is enabled
  final bool isShuffleEnabled;

  @override
  State<PlaybackControls> createState() => _PlaybackControlsState();
}

class _PlaybackControlsState extends State<PlaybackControls>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.isPlaying ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(PlaybackControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
              _ControlButton(
                icon: Icon(
                  Icons.repeat,
                  color: widget.isRepeatEnabled ? Colors.white : Colors.white70,
                  size: 16,
                ),
                onPressed: widget.onRepeat,
                size: 16,
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
                onPressed: widget.onPlayPause,
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
              _ControlButton(
                icon: Icon(
                  Icons.shuffle,
                  color:
                      widget.isShuffleEnabled ? Colors.white : Colors.white70,
                  size: 16,
                ),
                onPressed: widget.onShuffle,
                size: 16,
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
  final VoidCallback onPressed;
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
        onPressed: onPressed,
      ),
    );
  }
}
