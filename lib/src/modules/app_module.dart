import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/home/home_module.dart';

/// The main module of the application.
class AppModule extends Module {
  @override
  void binds(Injector i) {}

  @override
  void routes(RouteManager r) {
    r.module('/', module: HomeModule());
  }
}
