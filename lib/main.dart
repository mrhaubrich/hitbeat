import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/app_widget.dart';
import 'package:hitbeat/src/modules/app_module.dart';
import 'package:hitbeat/src/services/cover_cache_service.dart';
import 'package:menubar/menubar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-cache frequently used images (logo) after binding init, no UI block.
  const logo = AssetImage('assets/logo/hitbeat-icon.png');
  // Fire and forget precache once we have a root context via WidgetsBinding.
  // We'll schedule it right after first frame.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final ctx = WidgetsBinding.instance.rootElement;
    if (ctx != null) {
      unawaited(precacheImage(logo, ctx));
    }
  });

  // Kick off cover cache initialization but don't block first frame.
  unawaited(CoverCacheService.ensureInitialized());

  // Don't await menu setup; perform after app starts.
  unawaited(setApplicationMenu([]));

  return runApp(
    ModularApp(
      module: AppModule(),
      child: const AppWidget(),
    ),
  );
}
