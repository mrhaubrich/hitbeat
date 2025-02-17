import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/data/repositories/track_repository.dart';
import 'package:hitbeat/src/modules/database/database_module.dart';
import 'package:hitbeat/src/modules/home/modules/track/controllers/track_controller.dart';
import 'package:hitbeat/src/modules/home/modules/track/pages/track_page.dart';

/// The Track module of the application.
class TrackModule extends Module {
  @override
  List<Module> imports = [
    DatabaseModule(),
  ];

  @override
  void exportedBinds(Injector i) {}

  @override
  void binds(Injector i) {
    i.addSingleton<TrackController>(TrackController.new);
    i.addSingleton<TrackRepository>(TrackRepository.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const TrackPage());
  }
}
