import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/data/database/database.dart' as db;
import 'package:hitbeat/src/modules/home/modules/track/widgets/track_list_tile_enhanced.dart';
import 'package:hitbeat/src/modules/home/widgets/miolo.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';
import 'package:hitbeat/src/modules/playlist/models/playlist.dart';
import 'package:hitbeat/src/modules/playlist/services/playlist_service.dart';
import 'package:hitbeat/src/services/cover_cache_service.dart';

/// {@template playlist_detail_page}
/// A page for viewing and managing a single playlist.
/// {@endtemplate}
class PlaylistDetailPage extends StatefulWidget {
  /// {@macro playlist_detail_page}
  const PlaylistDetailPage({
    required this.playlistId,
    super.key,
  });

  /// The ID of the playlist to display.
  final int playlistId;

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  late final PlaylistService _playlistService;
  late final IAudioPlayer _player;
  Playlist? _playlist;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _playlistService = Modular.get<PlaylistService>();
    _player = Modular.get<IAudioPlayer>();
    unawaited(_loadPlaylist());
  }

  Future<void> _loadPlaylist() async {
    setState(() => _isLoading = true);
    try {
      final playlist = await _playlistService.getPlaylistById(
        widget.playlistId,
      );
      setState(() {
        _playlist = playlist;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading playlist: $e')),
        );
      }
    }
  }

  Future<void> _editPlaylist() async {
    if (_playlist == null) return;

    final nameController = TextEditingController(text: _playlist!.name);
    final descriptionController = TextEditingController(
      text: _playlist!.description ?? '',
    );
    Uint8List? selectedCoverData;
    var coverHash = _playlist!.coverHash;

    // Load existing cover if available
    if (_playlist!.coverHash != null) {
      final coverService = CoverCacheService();
      selectedCoverData = await coverService.getCoverAsync(
        _playlist!.coverHash,
      );
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Playlist'),
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
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Change Cover',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                      ),
                      if (selectedCoverData != null)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              setState(() {
                                selectedCoverData = null;
                                coverHash = null;
                              });
                            },
                            tooltip: 'Remove cover',
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(4),
                              minimumSize: const Size(24, 24),
                            ),
                          ),
                        ),
                    ],
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
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if ((result ?? false) && nameController.text.isNotEmpty) {
      try {
        // Store new cover art if changed
        if (selectedCoverData != null &&
            selectedCoverData !=
                await CoverCacheService().getCoverAsync(_playlist!.coverHash)) {
          final coverService = CoverCacheService();
          coverHash = await coverService.storeCoverAsync(selectedCoverData);
        }

        await _playlistService.updatePlaylist(
          id: widget.playlistId,
          name: nameController.text,
          description: descriptionController.text.isEmpty
              ? null
              : descriptionController.text,
          coverHash: coverHash,
        );
        await _loadPlaylist();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Playlist updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating playlist: $e')),
          );
        }
      }
    }
  }

  Future<void> _removeTrack(Track track, int position) async {
    try {
      // Get track ID from database
      final database = Modular.get<db.HitBeatDatabase>();
      final dbTrack = await database.getTrackByPath(track.path);
      if (dbTrack == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Track not found')),
          );
        }
        return;
      }

      await _playlistService.removeTrackFromPlaylist(
        playlistId: widget.playlistId,
        trackId: dbTrack.id,
        position: position,
      );
      await _loadPlaylist();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed "${track.name}" from playlist')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing track: $e')),
        );
      }
    }
  }

  Future<void> _playPlaylist() async {
    if (_playlist == null || _playlist!.tracks.isEmpty) return;

    try {
      await _player.play(
        _playlist!.tracks.first,
        tracklist: _playlist!.tracks,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Playing "${_playlist!.name}"')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing playlist: $e')),
        );
      }
    }
  }

  Future<void> _clearPlaylist() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Playlist'),
        content: Text(
          'Are you sure you want to remove all tracks from "${_playlist?.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        await _playlistService.clearPlaylist(widget.playlistId);
        await _loadPlaylist();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Playlist cleared')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error clearing playlist: $e')),
          );
        }
      }
    }
  }

  Widget _buildCoverArt() {
    final coverService = CoverCacheService();
    final coverPath = coverService.getCoverPath(_playlist?.coverHash);

    if (coverPath != null && File(coverPath).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(coverPath),
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.playlist_play, size: 80),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Miolo(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_playlist?.name ?? 'Loading...'),
          actions: [
            if (_playlist != null) ...[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editPlaylist,
                tooltip: 'Edit Playlist',
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case 'clear':
                      await _clearPlaylist();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all),
                        SizedBox(width: 8),
                        Text('Clear Playlist'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _playlist == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64),
                    const SizedBox(height: 16),
                    const Text('Playlist not found'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Modular.to.pop(),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // Playlist header with cover and info
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).scaffoldBackgroundColor,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildCoverArt(),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PLAYLIST',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _playlist!.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              if (_playlist!.description != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _playlist!.description!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                              const SizedBox(height: 16),
                              Text(
                                '${_playlist!.tracks.length} ${_playlist!.tracks.length == 1 ? 'track' : 'tracks'}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        FilledButton.icon(
                          onPressed: _playlist!.tracks.isEmpty
                              ? null
                              : _playPlaylist,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Play'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _playlist!.tracks.isEmpty
                              ? null
                              : () {
                                  // TODO: Shuffle play
                                },
                          icon: const Icon(Icons.shuffle),
                          label: const Text('Shuffle'),
                        ),
                      ],
                    ),
                  ),
                  // Track list
                  Expanded(
                    child: _playlist!.tracks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.music_note_outlined,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No tracks in this playlist',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Right-click tracks in the Tracks page to add them',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _playlist!.tracks.length,
                            itemBuilder: (context, index) {
                              final track = _playlist!.tracks[index];
                              return Dismissible(
                                key: ValueKey('${track.path}_$index'),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (_) => _removeTrack(track, index),
                                child: TrackListTileEnhanced(
                                  track: track,
                                  player: _player,
                                  trackNumber: index + 1,
                                  playlistIndex: index,
                                  onTap: () {
                                    unawaited(
                                      _player.play(
                                        track,
                                        tracklist: _playlist!.tracks,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
