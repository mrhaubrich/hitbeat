import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/home/modules/dashboard/blocs/add_songs/add_songs_bloc.dart';
import 'package:hitbeat/src/modules/home/modules/dashboard/blocs/drag_n_drop/drag_n_drop_bloc.dart';
import 'package:hitbeat/src/modules/home/modules/dashboard/pages/add_songs_page.dart';
import 'package:hitbeat/src/modules/home/modules/dashboard/pages/dashboard_page.dart';
import 'package:hitbeat/src/modules/home/modules/dashboard/services/file_handler_service.dart';
import 'package:hitbeat/src/modules/home/modules/track/track_module.dart';
import 'package:hitbeat/src/modules/player/player_module.dart';

/// The Dashboard module of the application.
class DashboardModule extends Module {
  @override
  List<Module> imports = [
    // DatabaseModule(),
    TrackModule(),
    PlayerModule(),
  ];

  @override
  void binds(Injector i) {
    i
      ..add<DragNDropBloc>(DragNDropBloc.new)
      ..add<FileHandlerService>(FileHandlerService.new)
      ..add<AddSongsBloc>(AddSongsBloc.new);
  }

  @override
  void routes(RouteManager r) {
    r
      ..child(
        '/',
        child: (_) => const DashboardPage(),
      )
      ..child(
        '/add-songs',
        child: (_) => const AddSongsPage(),
      );
  }
}
