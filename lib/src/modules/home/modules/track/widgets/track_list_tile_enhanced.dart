import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hitbeat/src/modules/home/modules/track/widgets/track_tile_components/track_tile_container.dart';
import 'package:hitbeat/src/modules/home/modules/track/widgets/track_tile_components/track_tile_content.dart';
import 'package:hitbeat/src/modules/player/enums/track_state.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';

/// {@template track_list_tile}
/// An enhanced list tile for a track with desktop-optimized UX.
///
/// This is the main orchestration widget that handles:
/// - Hover and press animations
/// - Stream listening for track state
/// - Composition of sub-components
///
/// The visual components are split into separate files in the
/// `track_tile_components/` directory for better maintainability.
/// {@endtemplate}
class TrackListTileEnhanced extends StatefulWidget {
  /// {@macro track_list_tile}
  const TrackListTileEnhanced({
    required this.track,
    required this.onTap,
    required this.player,
    this.trackNumber,
    super.key,
  });

  /// The track
  final Track track;

  /// The callback when the tile is tapped
  final VoidCallback onTap;

  /// The player to interact with
  final IAudioPlayer player;

  /// The track number in the list
  final int? trackNumber;

  @override
  State<TrackListTileEnhanced> createState() => _TrackListTileEnhancedState();
}

class _TrackListTileEnhancedState extends State<TrackListTileEnhanced>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 1.008).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHoverChanged(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      unawaited(_animationController.forward());
    } else {
      unawaited(_animationController.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHoverChanged(true),
      onExit: (_) => _onHoverChanged(false),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, _) => AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: TrackTileContainer(
              isHovered: _isHovered,
              child: StreamBuilder<Track?>(
                stream: widget.player.currentTrack$,
                builder: (context, currentTrackSnapshot) {
                  return StreamBuilder<TrackState>(
                    stream: widget.player.trackState$,
                    builder: (context, trackStateSnapshot) {
                      final trackState =
                          trackStateSnapshot.data ?? TrackState.notPlaying;
                      final isCurrentTrack =
                          currentTrackSnapshot.data == widget.track;
                      final isPlaying =
                          isCurrentTrack && trackState == TrackState.playing;

                      return TrackTileContent(
                        track: widget.track,
                        trackNumber: widget.trackNumber,
                        isCurrentTrack: isCurrentTrack,
                        isPlaying: isPlaying,
                        trackState: trackState,
                        isHovered: _isHovered,
                        onTap: widget.onTap,
                        onTapDown: () => setState(() => _isPressed = true),
                        onTapUp: () => setState(() => _isPressed = false),
                        onTapCancel: () => setState(() => _isPressed = false),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
