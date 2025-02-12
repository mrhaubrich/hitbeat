import 'package:flutter/material.dart';
import 'package:flutter_desktop_template/src/modules/home/widgets/miolo.dart';
import 'package:flutter_modular/flutter_modular.dart';

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
