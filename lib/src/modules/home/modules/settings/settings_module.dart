import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/home/modules/settings/pages/settings_page.dart';

/// The Settings module of the application.
class SettingsModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (_) => const SettingsPage(),
    );
  }
}
