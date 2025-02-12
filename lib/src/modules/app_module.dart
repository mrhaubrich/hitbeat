import 'package:flutter_desktop_template/src/modules/home/home_module.dart';
import 'package:flutter_modular/flutter_modular.dart';

/// The main module of the application.
class AppModule extends Module {
  @override
  void binds(Injector i) {}

  @override
  void routes(RouteManager r) {
    r.module('/', module: HomeModule());
  }
}
