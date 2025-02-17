import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/data/repositories/track_repository.dart';
import 'package:hitbeat/src/modules/home/widgets/miolo.dart';
import 'package:hitbeat/src/modules/player/interfaces/metadata_extractor.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';

/// {@template add_songs_page}
/// A page to add songs to the player.
/// {@endtemplate}
class AddSongsPage extends StatefulWidget {
  /// {@macro add_songs_page}
  const AddSongsPage({super.key});

  @override
  State<AddSongsPage> createState() => _AddSongsPageState();
}

class _AddSongsPageState extends State<AddSongsPage> {
  final _player = Modular.get<IAudioPlayer>();
  final _metadataExtractor = Modular.get<IMetadataExtractor>();
  final _trackRepository = Modular.get<TrackRepository>();
  bool _isDragging = false;

  Future<void> _handleFileDrop() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result != null) {
        final paths = result.files.map((file) => file.path!).toList();
        final tracks = _metadataExtractor.extractTracks(paths);
        await _handleTrackAdd(tracks);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Songs added successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding songs: $e')),
        );
      }
    }
  }

  Future<void> _handleTrackAdd(List<Track> tracks) async {
    await _trackRepository.insertTracks(tracks);
  }

  @override
  Widget build(BuildContext context) {
    return Miolo(
      appBar: AppBar(
        title: const Text('Add Songs'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Modular.to.pop(),
        ),
      ),
      child: DragTarget<List<String>>(
        onWillAcceptWithDetails: (_) {
          setState(() => _isDragging = true);
          return true;
        },
        onLeave: (_) {
          setState(() => _isDragging = false);
        },
        onAcceptWithDetails: (_) {
          setState(() => _isDragging = false);
          _handleFileDrop();
        },
        builder: (context, candidateData, rejectedData) {
          return GestureDetector(
            onTap: _handleFileDrop,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isDragging
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                  width: 2,
                  // style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      size: 80,
                      color: _isDragging
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Drag and drop music files here\nor click to select files',
                      style: TextStyle(
                        fontSize: 20,
                        color: _isDragging
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
