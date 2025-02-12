/// Enum for repeat modes.
enum Repeat {
  /// No repeat
  none,

  /// Repeat the current track
  one,

  /// Repeat the entire tracklist
  all;

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
