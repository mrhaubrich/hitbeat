import 'package:flutter_desktop_template/src/modules/home/modules/dashboard/pages/dashboard_page.dart';
import 'package:flutter_modular/flutter_modular.dart';

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
