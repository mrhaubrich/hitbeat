import 'package:flutter/material.dart'
    show
        AppBarTheme,
        Brightness,
        ButtonTextTheme,
        ButtonThemeData,
        Color,
        ColorScheme,
        Colors,
        ThemeData,
        ThemeExtension;
import 'package:hitbeat/src/theme/sidebar_theme_extension.dart'
    show SidebarThemeExtension;

/// The custom theme of the application.
final ThemeData customTheme = ThemeData(
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFcf352e),
    onPrimary: Colors.white,
    secondary: Color(0xFFcf862e),
    onSecondary: Colors.white,
    surface: Color(0xFF212121),
    onSurface: Colors.white,
    error: Colors.red,
    onError: Colors.white,
  ),
  primaryColor: const Color(0xFFcf352e),
  scaffoldBackgroundColor: const Color(0xFF212121),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF212121),
    foregroundColor: Colors.white,
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Color(0xFFcf352e),
    textTheme: ButtonTextTheme.accent,
  ),
  extensions: const <ThemeExtension<dynamic>>[
    SidebarThemeExtension(
      canvasColor: Color.fromARGB(255, 48, 47, 47),
      actionColor: Color(0xFFcf352e),
      accentCanvasColor: Color(0xFFcf862e),
      activeIconColor: Colors.white,
    ),
  ],
  // Additional theme settings...
);
