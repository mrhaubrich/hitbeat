import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/home/widgets/miolo.dart';

/// The Ice-Cream module of the application.
class IceCreamModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (_) => const Miolo(
        child: Center(
          child: Text('Ice-Cream'),
        ),
      ),
    );
  }
}
