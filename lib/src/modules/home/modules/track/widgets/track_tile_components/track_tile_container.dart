import 'package:flutter/material.dart';

/// Container with styling for the track tile (shadows, borders, etc.)
class TrackTileContainer extends StatelessWidget {
  /// Creates a track tile container
  const TrackTileContainer({
    required this.isHovered,
    required this.child,
    super.key,
  });

  /// Whether the tile is being hovered
  final bool isHovered;

  /// The child widget to wrap
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: isHovered ? theme.cardColor.withAlpha(245) : theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isHovered ? 55 : 28),
            blurRadius: isHovered ? 18 : 8,
            offset: Offset(0, isHovered ? 8 : 3),
            spreadRadius: isHovered ? 1 : 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: child,
      ),
    );
  }
}
