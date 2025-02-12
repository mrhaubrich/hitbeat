import 'package:flutter/foundation.dart';

/// The controller for the bottom bar.
class BottomBarController extends ChangeNotifier {
  bool _isBottomBarVisible = false;

  /// Whether the bottom bar is visible.
  bool get isBottomBarVisible => _isBottomBarVisible;

  set isBottomBarVisible(bool value) {
    _isBottomBarVisible = value;
    notifyListeners();
  }

  /// Toggles the visibility of the bottom bar.
  void toggleBottomBarVisibility() {
    _isBottomBarVisible = !_isBottomBarVisible;
    notifyListeners();
  }
}
