import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/home/modules/track/blocs/track_bloc.dart';
import 'package:hitbeat/src/modules/home/modules/track/widgets/track_list_tile_enhanced.dart';
import 'package:hitbeat/src/modules/player/enums/track_state.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';

/// {@template track_page}
/// A page to display and play tracks.
/// {@endtemplate}
class TrackPage extends StatefulWidget {
  /// {@macro track_page}
  const TrackPage({super.key});

  @override
  State<TrackPage> createState() => _TrackPageState();
}

enum _SortOption {
  nameAsc('Name (A-Z)', Icons.sort_by_alpha),
  nameDesc('Name (Z-A)', Icons.sort_by_alpha),
  artistAsc('Artist (A-Z)', Icons.person),
  artistDesc('Artist (Z-A)', Icons.person),
  albumAsc('Album (A-Z)', Icons.album),
  albumDesc('Album (Z-A)', Icons.album),
  durationAsc('Duration (Short-Long)', Icons.timer),
  durationDesc('Duration (Long-Short)', Icons.timer);

  const _SortOption(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _TrackPageState extends State<TrackPage> {
  late final TrackBloc _bloc = Modular.get<TrackBloc>();
  final IAudioPlayer _player = Modular.get<IAudioPlayer>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  _SortOption _sortOption = _SortOption.nameAsc;

  @override
  void initState() {
    super.initState();
    _bloc.add(const TrackSubscriptionRequested());
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<Track> _filterAndSortTracks(List<Track> tracks) {
    // Filter tracks based on search query
    final filteredTracks =
        tracks.where((track) {
            if (_searchQuery.isEmpty) return true;
            return track.name.toLowerCase().contains(_searchQuery) ||
                track.artist.name.toLowerCase().contains(_searchQuery) ||
                track.album.name.toLowerCase().contains(_searchQuery);
          }).toList()
          // Sort tracks based on selected option
          ..sort((a, b) {
            switch (_sortOption) {
              case _SortOption.nameAsc:
                return a.name.toLowerCase().compareTo(b.name.toLowerCase());
              case _SortOption.nameDesc:
                return b.name.toLowerCase().compareTo(a.name.toLowerCase());
              case _SortOption.artistAsc:
                return a.artist.name.toLowerCase().compareTo(
                  b.artist.name.toLowerCase(),
                );
              case _SortOption.artistDesc:
                return b.artist.name.toLowerCase().compareTo(
                  a.artist.name.toLowerCase(),
                );
              case _SortOption.albumAsc:
                return a.album.name.toLowerCase().compareTo(
                  b.album.name.toLowerCase(),
                );
              case _SortOption.albumDesc:
                return b.album.name.toLowerCase().compareTo(
                  a.album.name.toLowerCase(),
                );
              case _SortOption.durationAsc:
                return a.duration.compareTo(b.duration);
              case _SortOption.durationDesc:
                return b.duration.compareTo(a.duration);
            }
          });

    return filteredTracks;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // Search and sort bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: Focus(
                    onFocusChange: (focused) => setState(() {}),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Search songs, artists, or albums…',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: Icon(
                          Icons.search,
                          color: _searchFocusNode.hasFocus
                              ? theme.primaryColor
                              : Colors.grey[500],
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: _searchController.clear,
                                tooltip: 'Clear search',
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.primaryColor.withAlpha(128),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: _searchFocusNode.hasFocus
                            ? theme.cardColor.withAlpha(255)
                            : theme.cardColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Sort button
                PopupMenuButton<_SortOption>(
                  icon: Icon(
                    _sortOption.icon,
                    color: theme.primaryColor,
                  ),
                  tooltip: 'Sort tracks',
                  onSelected: (option) {
                    setState(() {
                      _sortOption = option;
                    });
                  },
                  itemBuilder: (context) => _SortOption.values.map((option) {
                    return PopupMenuItem(
                      value: option,
                      child: Row(
                        children: [
                          Icon(
                            option.icon,
                            size: 20,
                            color: _sortOption == option
                                ? theme.primaryColor
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            option.label,
                            style: TextStyle(
                              color: _sortOption == option
                                  ? theme.primaryColor
                                  : null,
                              fontWeight: _sortOption == option
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // Track list
          Expanded(
            child: BlocBuilder<TrackBloc, TrackBlocState>(
              bloc: _bloc,
              builder: (context, state) {
                if (state is TrackLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is! TrackLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allTracks = state.tracks;
                final filteredTracks = _filterAndSortTracks(allTracks);

                if (allTracks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.library_music_outlined,
                          size: 80,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No tracks in your library',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add some music from the Dashboard',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (filteredTracks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tracks found for "$_searchQuery"',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Track count header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          Text(
                            '${filteredTracks.length} ${filteredTracks.length == 1 ? 'track' : 'tracks'}',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_searchQuery.isNotEmpty) ...[
                            Text(
                              ' (filtered from ${allTracks.length})',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Track list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: filteredTracks.length,
                        itemBuilder: (context, index) {
                          final track = filteredTracks[index];

                          return TrackListTileEnhanced(
                            track: track,
                            player: _player,
                            trackNumber: index + 1,
                            onTap: () {
                              final trackState = _player.trackState;
                              final currentTrack = _player.currentTrack;
                              final isCurrentTrack =
                                  currentTrack?.path == track.path;

                              final trackPlaybackState = isCurrentTrack
                                  ? trackState
                                  : TrackState.notPlaying;

                              _bloc.add(
                                TrackPlayPauseRequested(
                                  track: track,
                                  tracklist: filteredTracks,
                                  isCurrentTrack: isCurrentTrack,
                                  shouldPlay:
                                      trackPlaybackState != TrackState.playing,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
