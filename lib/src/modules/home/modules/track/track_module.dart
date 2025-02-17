import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/home/widgets/miolo.dart';

/// The Track module of the application.
class TrackModule extends Module {
  @override
  void routes(RouteManager r) {
    r
      ..child(
        '/',
        child: (_) => Miolo(
          child: Center(
            child: Column(
              children: [
                const Text('Shop'),
                ElevatedButton(
                  onPressed: () {
                    Modular.to.navigate('cart');
                  },
                  child: const Text('Go to Cart'),
                ),
              ],
            ),
          ),
        ),
      )
      ..child(
        '/cart',
        child: (_) => const Miolo(
          child: Center(
            child: Text('Shop > Cart'),
          ),
        ),
      );
  }
}
