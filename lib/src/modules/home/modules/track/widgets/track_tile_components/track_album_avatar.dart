import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';
import 'package:hitbeat/src/services/cover_cache_service.dart';

/// Album avatar with pulse animation for currently playing tracks
class TrackAlbumAvatar extends StatefulWidget {
  /// Creates an album avatar widget
  const TrackAlbumAvatar({
    required this.track,
    this.isPlaying = false,
    super.key,
  });

  /// The track to display the album cover for
  final Track track;

  /// Whether this track is currently playing
  final bool isPlaying;

  @override
  State<TrackAlbumAvatar> createState() => _TrackAlbumAvatarState();
}

class _TrackAlbumAvatarState extends State<TrackAlbumAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(TrackAlbumAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        unawaited(_pulseController.repeat(reverse: true));
      } else {
        _pulseController.stop();
        unawaited(
          _pulseController.animateTo(
            0,
            duration: const Duration(milliseconds: 200),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coverHash = widget.track.album.coverHash;

    Widget avatarContent;
    if (coverHash == null) {
      avatarContent = Icon(Icons.album, color: Colors.grey[600]);
    } else {
      final cache = Modular.get<CoverCacheService>();
      final path = cache.getCoverPath(coverHash);
      if (path == null) {
        avatarContent = Icon(Icons.album, color: Colors.grey[600]);
      } else {
        final file = File(path);
        avatarContent = Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: ResizeImage(
                FileImage(file),
                width: 56,
                height: 56,
              ),
              fit: BoxFit.cover,
            ),
          ),
        );
      }
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) => Transform.scale(
        scale: widget.isPlaying ? _pulseAnimation.value : 1.0,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: widget.isPlaying
                ? [
                    BoxShadow(
                      color: theme.primaryColor.withAlpha(102),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(77),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: ClipOval(child: child),
        ),
      ),
      child: avatarContent,
    );
  }
}
