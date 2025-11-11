import 'package:flutter/material.dart'
    show
        AppBarTheme,
        BorderRadius,
        BorderSide,
        Brightness,
        ButtonTextTheme,
        ButtonThemeData,
        CardThemeData,
        Color,
        ColorScheme,
        Colors,
        EdgeInsets,
        ListTileThemeData,
        Radius,
        RoundedRectangleBorder,
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
  cardTheme: const CardThemeData(
    color: Color(0xFF1A1A1A),
    margin: EdgeInsets.all(8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      side: BorderSide(
        color: Color(0xFF2A2A2A),
      ),
    ),
  ),
  listTileTheme: const ListTileThemeData(
    // Base appearance
    tileColor: Color(
      0xFF1A1A1A,
    ), // Matches your card color, consistent with dark UI
    selectedTileColor: Color(
      0xFF2A2A2A,
    ), // Slightly lighter, to show selection subtly
    iconColor: Colors.white70, // Default icons (e.g. play, more options)
    textColor: Colors.white, // Primary text, clear on dark backgrounds
    selectedColor: Colors.white, // Active/selected icon & text color
    // Layout & density
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    horizontalTitleGap: 12, // Space between icon/artwork and title
    minVerticalPadding: 8, // Keeps it airy but compact enough for lists
    minLeadingWidth: 40, // Ensures album art or icons have consistent width
    // Shape & edges
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),

    // Hover/Focus/Highlight feedback
    // hoverColor: Color(0xFF262626), // Slightly lighter on hover for mouse feedback
    // focusColor: Color(0xFF303030),
    // selectedTileColor: Color(0xFF2A2A2A), // Active tile background
    // tileColor: Color(0xFF1A1A1A),
    enableFeedback:
        true, // Enables sound/vibration feedback on supported devices
    // Style integration
    dense: true, // More compact rows; ideal for song lists
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
