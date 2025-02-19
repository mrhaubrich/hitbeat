import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/theme/custom_theme.dart';

/// The main widget of the application.
class AppWidget extends StatelessWidget {
  /// The main widget of the application.
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'My Smart App',
      theme: customTheme,
      routerConfig: Modular.routerConfig,
    ); //added by extension
  }
}
