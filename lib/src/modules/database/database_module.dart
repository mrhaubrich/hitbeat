import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/data/database/database.dart';

/// Database Module
class DatabaseModule extends Module {
  @override
  void exportedBinds(Injector i) {
    i.addSingleton<HitBeatDatabase>(HitBeatDatabase.new);
  }
}
