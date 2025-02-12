import 'package:flutter/material.dart';
import 'package:flutter_desktop_template/src/modules/home/widgets/bottom_bar.dart';
import 'package:flutter_desktop_template/src/modules/home/widgets/sidebar.dart';
import 'package:flutter_modular/flutter_modular.dart';

/// A scaffold with a sidebar.
class DesktopScaffold extends StatelessWidget {
  /// A scaffold with a sidebar.
  const DesktopScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Sidebar(
                  controller: Modular.get(),
                ),
                const Expanded(
                  child: RouterOutlet(),
                ),
              ],
            ),
          ),
          const BottomBar(),
        ],
      ),
    );
  }
}
