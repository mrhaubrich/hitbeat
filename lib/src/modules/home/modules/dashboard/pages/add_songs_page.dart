import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/home/modules/dashboard/blocs/add_songs/add_songs_bloc.dart';
import 'package:hitbeat/src/modules/home/modules/dashboard/widgets/drop_zone_widget.dart';
import 'package:hitbeat/src/modules/home/modules/dashboard/widgets/song_editor_widget.dart';
import 'package:hitbeat/src/modules/home/widgets/miolo.dart';

/// {@template add_songs_page}
/// The Add Songs page of the application.
/// {@endtemplate}
class AddSongsPage extends StatefulWidget {
  /// {@macro add_songs_page}
  const AddSongsPage({super.key});

  @override
  State<AddSongsPage> createState() => _AddSongsPageState();
}

class _AddSongsPageState extends State<AddSongsPage> {
  late final AddSongsBloc _bloc = Modular.get<AddSongsBloc>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddSongsBloc, AddSongsState>(
      bloc: _bloc,
      listener: (context, state) {
        if (state case AddSongsError(:final message)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        } else if (state is AddSongsSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Songs added successfully!')),
          );
        }
      },
      child: Miolo(
        appBar: AppBar(
          title: const Text('Add Songs'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Modular.to.navigate('/dashboard/'),
          ),
        ),
        child: BlocBuilder<AddSongsBloc, AddSongsState>(
          bloc: _bloc,
          builder: (context, state) {
            return Row(
              children: [
                Expanded(
                  child: DropZoneWidget(
                    isLoading: state is AddSongsLoading,
                    onTap: () => _bloc.add(
                      const AddSongsPickFiles(),
                    ),
                    onDrop: (uris) => _bloc.add(
                      AddSongsDropFiles(uris),
                    ),
                    dragNDropBloc: Modular.get(),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: SongEditorWidget(
                    songs: switch (state) {
                      AddSongsLoaded(:final songs) => songs,
                      _ => const [],
                    },
                    isLoading: state is AddSongsLoading,
                    onSave: (songs) => _bloc.add(
                      AddSongsSave(songs),
                    ),
                    onCancel: () => _bloc.add(
                      const AddSongsClear(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
