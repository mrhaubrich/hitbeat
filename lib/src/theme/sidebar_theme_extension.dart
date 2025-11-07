import 'package:flutter/material.dart';

/// The extension of the sidebar theme.
class SidebarThemeExtension extends ThemeExtension<SidebarThemeExtension> {
  /// Creates a new sidebar theme extension.
  const SidebarThemeExtension({
    required this.canvasColor,
    required this.actionColor,
    required this.accentCanvasColor,
    required this.activeIconColor,
    this.textColor = Colors.white,
  });

  /// The color of the sidebar canvas.
  final Color canvasColor;

  /// The color of the action.
  final Color actionColor;

  /// The color of the accent canvas.
  final Color accentCanvasColor;

  /// The color of the text.
  final Color textColor;

  /// The color of the active icon.
  final Color activeIconColor;

  @override
  SidebarThemeExtension copyWith({
    Color? canvasColor,
    Color? actionColor,
    Color? accentCanvasColor,
    Color? textColor,
    Color? activeIconColor,
  }) {
    return SidebarThemeExtension(
      canvasColor: canvasColor ?? this.canvasColor,
      actionColor: actionColor ?? this.actionColor,
      accentCanvasColor: accentCanvasColor ?? this.accentCanvasColor,
      textColor: textColor ?? this.textColor,
      activeIconColor: activeIconColor ?? this.activeIconColor,
    );
  }

  @override
  SidebarThemeExtension lerp(
    ThemeExtension<SidebarThemeExtension>? other,
    double t,
  ) {
    if (other is! SidebarThemeExtension) return this;
    return SidebarThemeExtension(
      canvasColor: Color.lerp(canvasColor, other.canvasColor, t)!,
      actionColor: Color.lerp(actionColor, other.actionColor, t)!,
      accentCanvasColor: Color.lerp(
        accentCanvasColor,
        other.accentCanvasColor,
        t,
      )!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
      activeIconColor: Color.lerp(activeIconColor, other.activeIconColor, t)!,
    );
  }
}
