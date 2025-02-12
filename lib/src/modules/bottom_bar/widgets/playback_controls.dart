import 'package:flutter/material.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/progress_slider.dart';

/// {@template playback_controls}
/// A widget that displays the playback controls and progress slider.
/// {@endtemplate}
class PlaybackControls extends StatefulWidget {
  /// {@macro playback_controls}
  const PlaybackControls({super.key});

  @override
  State<PlaybackControls> createState() => _PlaybackControlsState();
}

class _PlaybackControlsState extends State<PlaybackControls>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
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
                icon: const Icon(
                  Icons.repeat,
                  color: Colors.white70,
                  size: 16,
                ),
                onPressed: () {},
                size: 16,
              ),
              _ControlButton(
                icon: const Icon(
                  Icons.skip_previous,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {},
                size: 24,
              ),
              _ControlButton(
                icon: AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: _controller,
                  color: Colors.white,
                  size: 36,
                ),
                onPressed: _togglePlayPause,
                size: 36,
              ),
              _ControlButton(
                icon: const Icon(
                  Icons.skip_next,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {},
                size: 24,
              ),
              _ControlButton(
                icon: const Icon(
                  Icons.shuffle,
                  color: Colors.white70,
                  size: 16,
                ),
                onPressed: () {},
                size: 16,
              ),
            ],
          ),
          ProgressSlider(
            duration: const Duration(seconds: 180),
            position: const Duration(seconds: 60),
            onSeek: (position) {},
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
