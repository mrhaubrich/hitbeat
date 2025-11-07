import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';

/// {@template song_editor_widget}
/// A widget that allows the user to edit the information of a list of songs.
/// {@endtemplate}
class SongEditorWidget extends StatelessWidget {
  /// {@macro song_editor_widget}
  const SongEditorWidget({
    required this.songs,
    required this.isLoading,
    required this.onSave,
    required this.onCancel,
    super.key,
  });

  /// The list of songs to edit.
  final List<Track> songs;

  /// Whether the controller is loading.
  final bool isLoading;

  /// The function to call when the user saves the changes.
  final FutureOr<void> Function(List<Track>) onSave;

  /// The function to call when the user cancels the changes.
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return const Center(
        child: Text('Drop songs on the left side to edit their information'),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: songs.length,
            prototypeItem: Card(
              key: const ValueKey('prototype'),
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.album, size: 48, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Song ${-100}'),
                          TextFormField(
                            initialValue: 'song.name',
                            decoration: const InputDecoration(
                              labelText: 'Title',
                            ),
                            onChanged: (_) {},
                          ),
                          TextFormField(
                            initialValue: 'song.artist.name',
                            decoration: const InputDecoration(
                              labelText: 'Artist',
                            ),
                            onChanged: (_) {},
                          ),
                          TextFormField(
                            initialValue: 'song.album.name',
                            decoration: const InputDecoration(
                              labelText: 'Album',
                            ),
                            onChanged: (_) {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            itemBuilder: (context, index) {
              final song = songs[index];
              return Card(
                key: ValueKey(song.path),
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: song.album.cover != null
                              ? DecorationImage(
                                  image: MemoryImage(song.album.cover!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: song.album.cover == null
                            ? const Center(
                                child: Icon(
                                  Icons.album,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Song ${index + 1}'),
                            TextFormField(
                              initialValue: song.name,
                              decoration: const InputDecoration(
                                labelText: 'Title',
                              ),
                              onChanged: (value) =>
                                  songs[index] = song.copyWith(name: value),
                            ),
                            TextFormField(
                              initialValue: song.artist.name,
                              decoration: const InputDecoration(
                                labelText: 'Artist',
                              ),
                              onChanged: (value) =>
                                  songs[index] = song.copyWith(
                                    artist: song.artist.copyWith(name: value),
                                  ),
                            ),
                            TextFormField(
                              initialValue: song.album.name,
                              decoration: const InputDecoration(
                                labelText: 'Album',
                              ),
                              onChanged: (value) =>
                                  songs[index] = song.copyWith(
                                    album: song.album.copyWith(name: value),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: isLoading ? null : onCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: isLoading ? null : () => onSave(songs),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
