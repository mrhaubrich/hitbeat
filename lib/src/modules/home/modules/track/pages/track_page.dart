import 'dart:async';

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
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _bloc.add(const TrackSubscriptionRequested());
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    // Debounce search to avoid lag on rapid typing (250ms optimal)
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text.toLowerCase();
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
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
      body: FocusScope(
        child: Column(
          children: [
            // Search and sort bar with enhanced visual separation
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor.withAlpha(250),
                border: Border(
                  bottom: BorderSide(
                    color: theme.primaryColor.withAlpha(26),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(38),
                    blurRadius: 8,
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
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _searchFocusNode.hasFocus
                              ? [
                                  BoxShadow(
                                    color: theme.primaryColor.withAlpha(77),
                                    blurRadius: 12,
                                  ),
                                ]
                              : null,
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Find something to play…',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.search,
                                color: _searchFocusNode.hasFocus
                                    ? theme.primaryColor
                                    : Colors.grey[500],
                              ),
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
                                color: theme.primaryColor.withAlpha(153),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: _searchFocusNode.hasFocus
                                ? theme.cardColor.withAlpha(255)
                                : theme.cardColor.withAlpha(230),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Sort button
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.primaryColor.withAlpha(77),
                      ),
                    ),
                    child: PopupMenuButton<_SortOption>(
                      icon: Icon(
                        _sortOption.icon,
                        color: theme.primaryColor,
                        size: 22,
                      ),
                      tooltip: 'Sort by: ${_sortOption.label}',
                      offset: const Offset(0, 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (option) {
                        setState(() {
                          _sortOption = option;
                        });
                      },
                      itemBuilder: (context) =>
                          _SortOption.values.map((option) {
                            return PopupMenuItem(
                              value: option,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    option.icon,
                                    size: 20,
                                    color: _sortOption == option
                                        ? theme.primaryColor
                                        : Colors.grey[400],
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    option.label,
                                    style: TextStyle(
                                      color: _sortOption == option
                                          ? theme.primaryColor
                                          : Colors.grey[200],
                                      fontWeight: _sortOption == option
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                  if (_sortOption == option) ...[
                                    const Spacer(),
                                    Icon(
                                      Icons.check,
                                      size: 18,
                                      color: theme.primaryColor,
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }).toList(),
                    ),
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
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.cardColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(51),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.library_music_outlined,
                              size: 64,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Your library is empty',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Start by adding music from the Dashboard',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Navigate to dashboard
                              Modular.to.navigate('/dashboard');
                            },
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Add Music'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
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
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.cardColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(51),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.search_off,
                              size: 56,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'No results found',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'No tracks match ',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                                ),
                                TextSpan(
                                  text: '"$_searchQuery"',
                                  style: TextStyle(
                                    color: theme.primaryColor.withAlpha(204),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Try a different search term',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 24),
                          OutlinedButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              _searchFocusNode.requestFocus();
                            },
                            icon: const Icon(Icons.clear_all),
                            label: const Text('Clear Search'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.primaryColor,
                              side: BorderSide(
                                color: theme.primaryColor.withAlpha(128),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Track count header with refined spacing and visual rhythm
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.scaffoldBackgroundColor.withAlpha(242),
                              theme.scaffoldBackgroundColor.withAlpha(0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 1.0],
                          ),
                          border: const Border(
                            bottom: BorderSide(
                              color: Colors.transparent,
                              width: 0,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.music_note_outlined,
                              size: 15,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${filteredTracks.length}',
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              filteredTracks.length == 1 ? 'track' : 'tracks',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            if (_searchQuery.isNotEmpty) ...[
                              const SizedBox(width: 4),
                              Text(
                                '(from ${allTracks.length})',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                            const Spacer(),
                            if (_sortOption != _SortOption.nameAsc) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withAlpha(26),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.primaryColor.withAlpha(51),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _sortOption.icon,
                                      size: 14,
                                      color: theme.primaryColor.withAlpha(204),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _sortOption.label.split(' ').first,
                                      style: TextStyle(
                                        color: theme.primaryColor.withAlpha(
                                          204,
                                        ),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Track list with staggered fade-in animation
                      Expanded(
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.white,
                                Colors.white,
                                Colors.transparent,
                              ],
                              stops: [0.0, 0.02, 0.95, 1.0],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.dstIn,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(
                              top: 8,
                              bottom: 24,
                            ),
                            itemCount: filteredTracks.length,
                            itemBuilder: (context, index) {
                              final track = filteredTracks[index];

                              return TweenAnimationBuilder<double>(
                                duration: Duration(
                                  milliseconds:
                                      200 + (index * 30).clamp(0, 400),
                                ),
                                curve: Curves.easeOutCubic,
                                tween: Tween(begin: 0, end: 1),
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 20 * (1 - value)),
                                      child: child,
                                    ),
                                  );
                                },
                                child: TrackListTileEnhanced(
                                  key: ValueKey(track.path),
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
                                            trackPlaybackState !=
                                            TrackState.playing,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
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
