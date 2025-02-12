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
                icon: Icons.skip_previous,
                onPressed: () {},
                type: _ButtonType.previous,
              ),
              _ControlButton(
                icon: Icons.play_arrow,
                onPressed: _togglePlayPause,
                type: _ButtonType.play,
                controller: _controller,
              ),
              _ControlButton(
                icon: Icons.skip_next,
                onPressed: () {},
                type: _ButtonType.next,
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

enum _ButtonType { previous, play, next }

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.type,
    this.controller,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final _ButtonType type;
  final AnimationController? controller;

  @override
  Widget build(BuildContext context) {
    Widget iconWidget;

    if (type == _ButtonType.play) {
      iconWidget = AnimatedIcon(
        icon: AnimatedIcons.play_pause,
        progress: controller ?? const AlwaysStoppedAnimation(0),
        color: Colors.white,
      );
    } else {
      iconWidget = Icon(icon, color: Colors.white);
    }

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
        icon: iconWidget,
        onPressed: onPressed,
      ),
    );
  }
}
