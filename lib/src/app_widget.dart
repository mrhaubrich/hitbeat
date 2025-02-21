import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/player/audio_handler.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';
import 'package:hitbeat/src/theme/custom_theme.dart';

/// The main widget of the application.
class AppWidget extends StatelessWidget {
  /// The main widget of the application.
  const AppWidget({super.key});

  Future<void> _initializeAudioHandler() async {
    print('Initializing audio handler');
    if (HitbeatAudioHandler.isInitialized) {
      return;
    }

    final player = Modular.get<IAudioPlayer>();
    await HitbeatAudioHandler.initialize(player);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'My Smart App',
      theme: customTheme,
      routerConfig: Modular.routerConfig,
      builder: (context, child) {
        return FutureBuilder(
          future: _initializeAudioHandler(),
          builder: (context, snapshot) {
            return child!;
          },
        );
      },
    ); //added by extension
  }
}
