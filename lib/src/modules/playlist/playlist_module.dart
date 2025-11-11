import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/data/database/database.dart';
import 'package:hitbeat/src/modules/database/database_module.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';
import 'package:hitbeat/src/modules/player/player_module.dart';
import 'package:hitbeat/src/modules/playlist/pages/playlist_detail_page.dart';
import 'package:hitbeat/src/modules/playlist/pages/playlist_page.dart';
import 'package:hitbeat/src/modules/playlist/services/playlist_service.dart';
import 'package:hitbeat/src/modules/playlist/services/queue_persistence_service.dart';

/// The Playlist module of the application.
class PlaylistModule extends Module {
  @override
  List<Module> get imports => [
    DatabaseModule(),
    PlayerModule(),
  ];

  @override
  void exportedBinds(Injector i) {
    i
      ..addSingleton<PlaylistService>(
        () => PlaylistService(database: i.get<HitBeatDatabase>()),
      )
      ..addSingleton<QueuePersistenceService>(
        () => QueuePersistenceService(
          audioPlayer: i.get<IAudioPlayer>(),
          playlistService: i.get<PlaylistService>(),
          database: i.get<HitBeatDatabase>(),
        ),
      );
  }

  @override
  void binds(Injector i) {
    // Local binds if needed
  }

  @override
  void routes(RouteManager r) {
    r
      ..child(
        '/',
        child: (_) => const PlaylistPage(),
      )
      ..child(
        '/:playlistId',
        child: (context) {
          final playlistId = Modular.args.params['playlistId'] as String;
          return PlaylistDetailPage(
            playlistId: int.parse(playlistId),
          );
        },
      );
  }
}
