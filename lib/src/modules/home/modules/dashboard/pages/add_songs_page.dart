import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/data/repositories/track_repository.dart';
import 'package:hitbeat/src/modules/home/widgets/miolo.dart';
import 'package:hitbeat/src/modules/player/interfaces/metadata_extractor.dart';
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
    final theme = Theme.of(context);
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
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface.withValues(alpha: 0.8),
                  ],
                ),
                border: Border.all(
                  color: _isDragging
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.5),
                  width: _isDragging ? 3 : 2,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _isDragging
                        ? theme.colorScheme.primary.withValues(alpha: 0.3)
                        : Colors.transparent,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: _handleFileDrop,
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_rounded,
                          size: 80,
                          color: _isDragging
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Drag and drop music files here\nor click to select files',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: _isDragging
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Supported formats: MP3, WAV, FLAC, M4A',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
