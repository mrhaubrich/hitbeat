import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/app_widget.dart';
import 'package:hitbeat/src/modules/app_module.dart';
import 'package:hitbeat/src/services/cover_cache_service.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:menubar/menubar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CoverCacheService.ensureInitialized();

  JustAudioMediaKit.ensureInitialized(
    macOS: true,
  );

  await setApplicationMenu([]);

  return runApp(
    ModularApp(
      module: AppModule(),
      child: const AppWidget(),
    ),
  );
}
