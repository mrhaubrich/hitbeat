import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/data/database/database.dart' as db;
import 'package:hitbeat/src/modules/player/models/track.dart';
import 'package:hitbeat/src/modules/playlist/services/playlist_service.dart';
import 'package:super_context_menu/super_context_menu.dart';

/// {@template track_context_menu}
/// A context menu for track items that allows adding to playlists.
/// {@endtemplate}
class TrackContextMenu extends StatelessWidget {
  /// {@macro track_context_menu}
  const TrackContextMenu({
    required this.track,
    required this.child,
    super.key,
  });

  /// The track for this context menu.
  final Track track;

  /// The child widget.
  final Widget child;

  Future<void> _addToPlaylist(
    BuildContext context,
    int playlistId,
    String playlistName,
  ) async {
    final playlistService = Modular.get<PlaylistService>();
    final database = Modular.get<db.HitBeatDatabase>();

    try {
      // Get the track ID from the database
      final dbTrack = await database.getTrackByPath(track.path);
      if (dbTrack == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Track not found in database')),
          );
        }
        return;
      }

      await playlistService.addTrackToPlaylist(
        playlistId: playlistId,
        trackId: dbTrack.id,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "${track.name}" to "$playlistName"'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding to playlist: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContextMenuWidget(
      child: child,
      menuProvider: (menuContext) async {
        return _buildMenu(context);
      },
    );
  }

  Future<Menu> _buildMenu(BuildContext context) async {
    final playlistService = Modular.get<PlaylistService>();

    try {
      final playlists = await playlistService.getAllPlaylists();

      return Menu(
        title: track.name,
        children: [
          MenuAction(
            title: 'Play',
            callback: () {
              // TODO: Implement play action
            },
            image: MenuImage.icon(Icons.play_arrow),
          ),
          MenuSeparator(),
          if (playlists.isEmpty)
            Menu(
              title: 'Add to Playlist',
              children: [
                MenuAction(
                  title: 'No playlists available',
                  callback: () {},
                  attributes: const MenuActionAttributes(
                    disabled: true,
                  ),
                ),
              ],
              image: MenuImage.icon(Icons.playlist_add),
            )
          else
            Menu(
              title: 'Add to Playlist',
              image: MenuImage.icon(Icons.playlist_add),
              children: playlists
                  .map(
                    (playlist) => MenuAction(
                      title: playlist.name,
                      callback: () =>
                          _addToPlaylist(context, playlist.id, playlist.name),
                      image: MenuImage.icon(Icons.playlist_play),
                    ),
                  )
                  .toList(),
            ),
          MenuAction(
            title: 'Add to Queue',
            callback: () async {
              // TODO: Implement add to queue
            },
            image: MenuImage.icon(Icons.queue_music),
          ),
        ],
      );
    } catch (e) {
      return Menu(
        title: track.name,
        children: [
          MenuAction(
            title: 'Error loading playlists',
            callback: () {},
            attributes: const MenuActionAttributes(
              disabled: true,
            ),
          ),
        ],
      );
    }
  }
}
