import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/home/modules/track/controllers/track_controller.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';

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
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tracks = snapshot.data!;

          if (tracks.isEmpty) {
            return const Center(child: Text('No tracks found'));
          }

          return ListView.builder(
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              return ListTile(
                title: Text(track.name),
                subtitle: Text(track.artist.name),
                onTap: () => _player.play(
                  track.copyWith(path: 'asset:///${track.path}'),
                  tracklist: tracks
                      .map((e) => e.copyWith(path: 'asset:///${e.path}'))
                      .toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
