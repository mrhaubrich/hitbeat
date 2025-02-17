import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/home/widgets/example_card.dart';
import 'package:hitbeat/src/modules/home/widgets/example_context_menu.dart';
import 'package:hitbeat/src/modules/home/widgets/miolo.dart';

/// The Dashboard page of the application.
class DashboardPage extends StatelessWidget {
  /// Creates the Dashboard page.
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Miolo(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Songs',
            onPressed: () => Modular.to.navigate('add-songs'),
          ),
        ],
      ),
      child: const SizedBox(
        width: double.infinity,
        child: Wrap(
          children: [
            ExampleContextMenu(
              child: ExampleCard(
                title: Text('Card 1'),
                subtitle: Text('Right-click me!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
