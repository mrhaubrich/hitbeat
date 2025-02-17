import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hitbeat/src/modules/home/widgets/example_card.dart';
import 'package:hitbeat/src/modules/home/widgets/example_context_menu.dart';
import 'package:hitbeat/src/modules/home/widgets/miolo.dart';

/// The Dashboard page of the application.
class DashboardPage extends StatelessWidget {
  /// Creates the Dashboard page.
  const DashboardPage({super.key});

  Future<List<String>> _getAssetPaths(String directory) async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final manifestMap = json.decode(manifestContent) as Map<String, dynamic>;
    final assetPaths = manifestMap.keys
        .where((String key) => key.startsWith(directory))
        .toList();
    return assetPaths;
  }

  Future<List<String>> get _trackPaths async {
    return _getAssetPaths('assets/songs/');
  }

  @override
  Widget build(BuildContext context) {
    return Miolo(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Dashboard'),
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
