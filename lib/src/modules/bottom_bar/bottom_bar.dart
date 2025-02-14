import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/album_cover.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/playback_controls.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/track_info.dart';
import 'package:hitbeat/src/modules/bottom_bar/widgets/volume_control.dart';
import 'package:hitbeat/src/modules/player/interfaces/metadata_extractor.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';

/// The height of the bottom bar.
const kBottomBarHeight = 80.0;

/// The URL of the default album cover.
const kNoAlbumCover =
    'https://emby.media/community/uploads/inline/355992/5c1cc71abf1ee_genericcoverart.jpg';

/// {@template bottom_bar}
/// A bottom bar that displays the currently playing song.
/// {@endtemplate}
class BottomBar extends StatefulWidget {
  /// {@macro bottom_bar}
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  final IAudioPlayer _player = Modular.get<IAudioPlayer>();
  final IMetadataExtractor _metadataExtractor =
      Modular.get<IMetadataExtractor>();

  Future<List<String>> getAssetPaths(String directory) async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final manifestMap = json.decode(manifestContent) as Map<String, dynamic>;
    final assetPaths = manifestMap.keys
        .where((String key) => key.startsWith(directory))
        .toList();
    return assetPaths;
  }

  Future<List<String>> get _trackPaths async {
    return getAssetPaths('assets/songs/');
  }

  @override
  void initState() {
    super.initState();
    _initializeTracks();
  }

  Future<List<Track>> _initializeTracks() async {
    final paths = await _trackPaths;
    final tracks = _metadataExtractor.extractTracks(paths);
    // for (final track in tracks) {
    //   track.path = 'asset:///${track.path}';
    // }
    final newTracks = tracks.map((track) {
      return track.copyWith(
        path: 'asset:///${track.path}',
      );
    }).toList();
    _player.concatTracks(newTracks);
    return newTracks;
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
        left: 10,
        right: 10,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.all(Radius.circular(14)),
        ),
        child: SizedBox(
          height: kBottomBarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 20,
                child: StreamBuilder(
                  stream: _player.currentTrack$,
                  builder: (context, snapshot) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          firstChild: const AlbumCover.asset(
                            path: kNoAlbumCover,
                          ),
                          secondChild: snapshot.data?.album.cover != null
                              ? AlbumCover.memory(
                                  bytes: snapshot.data!.album.cover!,
                                )
                              : const SizedBox(),
                          crossFadeState: snapshot.data?.album.cover == null
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                        ),
                        Expanded(
                          child: TrackInfo(
                            track: snapshot.data ?? Track.empty,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Flexible(
                flex: 60,
                child: PlaybackControls(
                  player: _player,
                ),
              ),
              Flexible(
                flex: 20,
                child: StreamBuilder(
                  stream: _player.volume$,
                  builder: (context, snapshot) {
                    return VolumeControl(
                      volume: snapshot.data ?? 1,
                      onVolumeChanged: (volume) async {
                        await _player.setVolume(volume);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
