import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:menubar/menubar.dart';

/// A menu bar that displays the example menu.
class MenuBarController {
  /// A menu bar that displays the example menu.
  final ValueNotifier<bool> isToggled = ValueNotifier(false);

  static final _items = [
    NativeSubmenu(
      label: 'File',
      children: [
        NativeMenuItem(
          label: 'Open',
          shortcut: LogicalKeySet(
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.keyO,
          ),
          onSelected: () {
            // open file dialog from system
            FilePicker.platform.pickFiles().then(
              (result) {
                if (result != null) {
                  debugPrint(result.files.single.path);
                }
              },
            );
          },
        ),
        const NativeMenuDivider(),
        const NativeSubmenu(
          label: 'Recent Files',
          children: [
            NativeMenuItem(label: 'file1.txt'),
            NativeMenuItem(label: 'file2.txt'),
            NativeMenuItem(label: 'file3.txt'),
            NativeMenuDivider(),
            NativeMenuItem(label: 'Clear Menu'),
          ],
        ),
      ],
    ),
    NativeSubmenu(
      label: 'About',
      children: [
        NativeMenuItem(
          label: 'About',
          onSelected: () {
            final context = Modular.routerDelegate.navigatorKey.currentContext!;
            showAboutDialog(
              context: context,
              applicationName: 'My Smart App',
              applicationVersion: '1.0.0',
              applicationIcon: const FlutterLogo(),
              applicationLegalese: '© 2021 My Smart App',
            );
          },
        ),
      ],
    ),
  ];

  /// A menu bar that displays the example menu.
  Future<void> toggle() {
    if (isToggled.value) {
      isToggled.value = false;
      return setApplicationMenu([]);
    } else {
      isToggled.value = true;
      return setApplicationMenu(_items);
    }
  }
}
