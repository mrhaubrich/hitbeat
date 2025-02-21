import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/home/modules/track/blocs/track_bloc.dart';
import 'package:hitbeat/src/modules/home/modules/track/widgets/track_list_tile.dart';
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

class _TrackPageState extends State<TrackPage> {
  late final _bloc = Modular.get<TrackBloc>();
  final _player = Modular.get<IAudioPlayer>();

  @override
  void initState() {
    super.initState();
    _bloc.add(const TrackSubscriptionRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TrackBloc, TrackBlocState>(
        bloc: _bloc,
        builder: (context, state) {
          if (state is TrackLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is! TrackLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final tracks = state.tracks;

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

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            prototypeItem: TrackListTile(
              track: Track.empty,
              onTap: () {},
              player: _player,
            ),
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];

              return TrackListTile(
                track: track,
                player: _player,
                onTap: () {
                  final trackState = _player.trackState;
                  final currentTrack = _player.currentTrack;
                  final isCurrentTrack = currentTrack?.path == track.path;

                  final trackPlaybackState =
                      isCurrentTrack ? trackState : TrackState.notPlaying;

                  _bloc.add(
                    TrackPlayPauseRequested(
                      track: track,
                      tracklist: tracks,
                      isCurrentTrack: isCurrentTrack,
                      shouldPlay: trackPlaybackState != TrackState.playing,
                    ),
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
