import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

/// The main widget of the application.
class AppWidget extends StatelessWidget {
  /// The main widget of the application.
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'My Smart App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFcf352e),
          brightness: Brightness.dark,
          surface: const Color(0xFF212121),
          primary: const Color(0xFFcf352e),
          secondary: const Color(0xFFcf862e),
        ),
      ),
      routerConfig: Modular.routerConfig,
    ); //added by extension
  }
}
