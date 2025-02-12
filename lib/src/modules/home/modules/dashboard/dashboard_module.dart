import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/home/modules/dashboard/pages/dashboard_page.dart';

/// The Dashboard module of the application.
class DashboardModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (_) => const DashboardPage(),
    );
  }
}
