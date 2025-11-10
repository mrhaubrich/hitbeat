import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/bottom_bar/bottom_bar.dart';
import 'package:hitbeat/src/modules/home/widgets/sidebar.dart';

/// A scaffold with a sidebar.
class DesktopScaffold extends StatefulWidget {
  /// Creates a new desktop scaffold.
  const DesktopScaffold({super.key});

  @override
  State<DesktopScaffold> createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends State<DesktopScaffold> {
  late final EnhancedSidebarController _sidebarController = Modular.get();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        // Remove one Column layer for simpler layout & less rebuild cost
        children: [
          Sidebar(controller: _sidebarController),
          // Main content with its own repaint boundary
          const Expanded(
            child: RepaintBoundary(
              child: RouterOutlet(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomBar(),
    );
  }
}
