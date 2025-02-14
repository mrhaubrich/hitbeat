import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/data/database/database.dart';
import 'package:hitbeat/src/data/repositories/track_repository.dart';
import 'package:hitbeat/src/modules/home/home_module.dart';
import 'package:hitbeat/src/modules/player/player_module.dart';

/// The main module of the application.
class AppModule extends Module {
  @override
  List<Module> get imports => [PlayerModule()];

  @override
  void binds(Injector i) {
    i
      ..addSingleton<HitBeatDatabase>(HitBeatDatabase.new)
      ..addSingleton<TrackRepository>(TrackRepository.new);
  }

  @override
  void routes(RouteManager r) {
    r.module('/', module: HomeModule());
  }
}
