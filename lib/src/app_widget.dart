import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/player/audio_handler.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';
import 'package:hitbeat/src/modules/playlist/services/queue_persistence_service.dart';
import 'package:hitbeat/src/theme/custom_theme.dart';

/// The main widget of the application.
class AppWidget extends StatefulWidget {
  /// The main widget of the application.
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Save state when app is paused, detached, or hidden
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      final queuePersistence = Modular.get<QueuePersistenceService>();
      queuePersistence.saveNow();
    }
  }

  Future<void> _initializeServices() async {
    print('Initializing audio handler');
    if (!HitbeatAudioHandler.isInitialized) {
      final player = Modular.get<IAudioPlayer>();
      await HitbeatAudioHandler.initialize(player);
    }

    // Initialize queue persistence to restore previous session
    print('Initializing queue persistence');
    final queuePersistence = Modular.get<QueuePersistenceService>();
    await queuePersistence.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'My Smart App',
      theme: customTheme,
      routerConfig: Modular.routerConfig,
      builder: (context, child) {
        return FutureBuilder(
          future: _initializeServices(),
          builder: (context, snapshot) {
            return child!;
          },
        );
      },
    ); //added by extension
  }
}
