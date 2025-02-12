import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/home/controllers/menu_bar_controller.dart';
import 'package:hitbeat/src/modules/home/widgets/miolo.dart';

/// The Settings page of the application.
class SettingsPage extends StatelessWidget {
  /// Creates the Settings page.
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Miolo(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Settings'),
      ),
      child: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: Modular.get<MenuBarController>().isToggled,
            builder: (context, value, child) {
              return SwitchListTile(
                value: value,
                onChanged: (value) {
                  Modular.get<MenuBarController>().toggle();
                },
                title: const Text('Show Menu Bar'),
                subtitle: const Text('Show or hide the menu bar.'),
              );
            },
          ),
        ],
      ),
    );
  }
}
