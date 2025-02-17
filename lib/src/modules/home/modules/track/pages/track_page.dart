import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/home/modules/track/controllers/track_controller.dart';
import 'package:hitbeat/src/modules/home/modules/track/widgets/track_list_tile.dart';
import 'package:hitbeat/src/modules/player/enums/track_state.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';

class TrackPage extends StatefulWidget {
  const TrackPage({super.key});

  @override
  State<TrackPage> createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  final _controller = Modular.get<TrackController>();
  final _player = Modular.get<IAudioPlayer>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _controller.tracks$,
        builder: (context, tracksSnapshot) {
          if (!tracksSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tracks = tracksSnapshot.data!;

          if (tracks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_off, size: 64, color: Colors.grey[700]),
                  const SizedBox(height: 16),
                  Text(
                    'No tracks found',
                    style: TextStyle(color: Colors.grey[700], fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return StreamBuilder<Track?>(
            stream: _player.currentTrack$,
            builder: (context, currentTrackSnapshot) {
              final currentTrack = currentTrackSnapshot.data;

              return StreamBuilder<TrackState>(
                stream: _player.trackState$,
                builder: (context, stateSnapshot) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: tracks.length,
                    itemBuilder: (context, index) {
                      final track = tracks[index]
                          .copyWith(path: 'asset:///${tracks[index].path}');

                      final isCurrentTrack = currentTrack?.path == track.path;
                      final trackState = isCurrentTrack
                          ? (stateSnapshot.data ?? TrackState.notPlaying)
                          : TrackState.notPlaying;

                      return TrackListTile(
                        track: track,
                        trackState: trackState,
                        onTap: () {
                          if (isCurrentTrack) {
                            _player.setIsPlaying(
                              isPlaying: trackState != TrackState.playing,
                            );
                          } else {
                            _player.play(
                              track,
                              tracklist: tracks
                                  .map(
                                    (e) => e.copyWith(
                                      path: 'asset:///${e.path}',
                                    ),
                                  )
                                  .toList(),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
