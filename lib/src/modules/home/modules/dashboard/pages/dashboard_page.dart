import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/data/repositories/track_repository.dart';
import 'package:hitbeat/src/modules/home/widgets/example_card.dart';
import 'package:hitbeat/src/modules/home/widgets/example_context_menu.dart';
import 'package:hitbeat/src/modules/home/widgets/miolo.dart';
import 'package:hitbeat/src/modules/player/interfaces/metadata_extractor.dart';

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
    final repository = Modular.get<TrackRepository>();
    final metadataExtractor = Modular.get<IMetadataExtractor>();

    return Miolo(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save test tracks to DB',
            onPressed: () async {
              try {
                final paths = await _trackPaths;
                final tracks = metadataExtractor.extractTracks(paths);

                for (final track in tracks) {
                  await repository.insertTrack(track);
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tracks saved to database'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
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
