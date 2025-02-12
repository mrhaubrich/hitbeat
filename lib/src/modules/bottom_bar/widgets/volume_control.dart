import 'package:flutter/material.dart';
import 'package:interactive_slider/interactive_slider.dart';

/// {@template volume_control}
/// A widget that displays a volume control.
/// {@endtemplate}
class VolumeControl extends StatefulWidget {
  /// {@macro volume_control}
  const VolumeControl({
    required this.volume,
    required this.onVolumeChanged,
    super.key,
  });

  /// Current volume level (0.0 to 1.0)
  final double volume;

  /// Callback when volume changes
  final void Function(double volume) onVolumeChanged;

  @override
  State<VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl> {
  double? hoverVolume;

  String _formatVolume(double volume) {
    return '${(volume * 100).round()}%';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InteractiveSlider(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          initialProgress: widget.volume,
          startIcon: const Icon(Icons.volume_mute, color: Colors.white),
          endIcon: const Icon(Icons.volume_up, color: Colors.white),
          centerIcon: hoverVolume == null
              ? null
              : Text(
                  _formatVolume(hoverVolume!),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
          onProgressUpdated: (value) {
            widget.onVolumeChanged(value);
            setState(() {
              hoverVolume = null;
            });
          },
          onFocused: (value) {
            setState(() {
              hoverVolume = value;
            });
          },
          onChanged: (value) {
            setState(() {
              hoverVolume = value;
            });
          },
        ),
      ],
    );
  }
}
