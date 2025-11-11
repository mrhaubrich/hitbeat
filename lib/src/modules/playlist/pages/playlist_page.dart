import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/home/widgets/miolo.dart';
import 'package:hitbeat/src/modules/playlist/models/playlist.dart';
import 'package:hitbeat/src/modules/playlist/services/playlist_service.dart';
import 'package:hitbeat/src/services/cover_cache_service.dart';

/// The Playlist page for managing user playlists.
class PlaylistPage extends StatefulWidget {
  /// Creates a new playlist page.
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  late final PlaylistService _playlistService;
  List<Playlist> _playlists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _playlistService = Modular.get<PlaylistService>();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    setState(() => _isLoading = true);
    try {
      final playlists = await _playlistService.getAllPlaylists();
      setState(() {
        _playlists = playlists;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading playlists: $e')),
        );
      }
    }
  }

  Future<void> _createPlaylist() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    Uint8List? selectedCoverData;
    String? coverHash;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Playlist'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cover art preview
                GestureDetector(
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                    );
                    if (result != null && result.files.single.bytes != null) {
                      setState(() {
                        selectedCoverData = result.files.single.bytes;
                      });
                    } else if (result != null &&
                        result.files.single.path != null) {
                      final file = File(result.files.single.path!);
                      final bytes = await file.readAsBytes();
                      setState(() {
                        selectedCoverData = bytes;
                      });
                    }
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: selectedCoverData != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.memory(
                              selectedCoverData!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 40,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add Cover',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Playlist Name',
                    hintText: 'Enter playlist name',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Enter description',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if ((result ?? false) && nameController.text.isNotEmpty) {
      try {
        // Store cover art if selected
        if (selectedCoverData != null) {
          final coverService = CoverCacheService();
          coverHash = await coverService.storeCoverAsync(selectedCoverData);
        }

        await _playlistService.createPlaylist(
          name: nameController.text,
          description: descriptionController.text.isEmpty
              ? null
              : descriptionController.text,
          coverHash: coverHash,
        );
        await _loadPlaylists();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Playlist created successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating playlist: $e')),
          );
        }
      }
    }
  }

  Future<void> _deletePlaylist(Playlist playlist) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Playlist'),
        content: Text(
          'Are you sure you want to delete "${playlist.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        await _playlistService.deletePlaylist(playlist.id);
        await _loadPlaylists();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Playlist deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting playlist: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Miolo(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Playlists'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _createPlaylist,
              tooltip: 'Create Playlist',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _playlists.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.playlist_add,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No playlists yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first playlist to get started',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _createPlaylist,
                      icon: const Icon(Icons.add),
                      label: const Text('Create Playlist'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _playlists.length,
                itemBuilder: (context, index) {
                  final playlist = _playlists[index];
                  final coverService = CoverCacheService();
                  final coverPath = coverService.getCoverPath(
                    playlist.coverHash,
                  );

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: coverPath != null && File(coverPath).existsSync()
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.file(
                                File(coverPath),
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              ),
                            )
                          : CircleAvatar(
                              child: Text(
                                playlist.name.isEmpty
                                    ? '?'
                                    : playlist.name[0].toUpperCase(),
                              ),
                            ),
                      title: Text(playlist.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (playlist.description != null)
                            Text(
                              playlist.description!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          Text(
                            '${playlist.tracks.length} ${playlist.tracks.length == 1 ? 'track' : 'tracks'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deletePlaylist(playlist),
                        tooltip: 'Delete playlist',
                      ),
                      onTap: () {
                        Modular.to.navigate('/playlists/${playlist.id}');
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
