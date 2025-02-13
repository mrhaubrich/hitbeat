import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

/// {@template repeat}
/// The repeat mode of the player.
/// {@endtemplate}
enum Repeat {
  /// No repeat
  none(icon: Icons.repeat),

  /// Repeat the current track
  one(icon: Icons.repeat_one),

  /// Repeat the entire tracklist
  all(icon: Icons.repeat_on);

  /// {@macro repeat}
  const Repeat({
    required this.icon,
  });

  /// The icon of the repeat mode
  final IconData icon;

  /// Get the next repeat mode
  Repeat get next {
    switch (this) {
      case Repeat.none:
        return Repeat.one;
      case Repeat.one:
        return Repeat.all;
      case Repeat.all:
        return Repeat.none;
    }
  }
}
