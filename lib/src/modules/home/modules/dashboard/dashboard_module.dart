import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/home/modules/dashboard/blocs/bloc/drag_n_drop_bloc.dart';
import 'package:hitbeat/src/modules/home/modules/dashboard/pages/add_songs_page.dart';
import 'package:hitbeat/src/modules/home/modules/dashboard/pages/dashboard_page.dart';
import 'package:hitbeat/src/modules/home/modules/track/track_module.dart';

/// The Dashboard module of the application.
class DashboardModule extends Module {
  @override
  List<Module> imports = [
    // DatabaseModule(),
    TrackModule(),
  ];

  @override
  void binds(Injector i) {
    i.add<DragNDropBloc>(DragNDropBloc.new);
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
