import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/home/modules/dashboard/controllers/add_songs_controller.dart';
import 'package:hitbeat/src/modules/home/modules/dashboard/services/file_handler_service.dart';
import 'package:hitbeat/src/modules/home/modules/dashboard/widgets/drop_zone_widget.dart';
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
  late final AddSongsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AddSongsController(
      metadataExtractor: Modular.get(),
      trackRepository: Modular.get(),
      fileHandler: FileHandlerService(),
    );
    _controller.addListener(_handleStateChanges);
  }

  void _handleStateChanges() {
    if (!mounted) return;

    final state = _controller.value;
    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error!)),
      );
    } else if (!state.isLoading && !state.isDragging) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Songs added successfully!')),
      );
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleStateChanges)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Miolo(
      appBar: AppBar(
        title: const Text('Add Songs'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Modular.to.navigate('/dashboard/'),
        ),
      ),
      child: ValueListenableBuilder<AddSongsState>(
        valueListenable: _controller,
        builder: (context, state, _) {
          return DropZoneWidget(
            isDragging: state.isDragging,
            isLoading: state.isLoading,
            onTap: _controller.handleFileDrop,
            onDrop: _controller.handleNativeFileDrop,
            onDragState: _controller.setDragging,
          );
        },
      ),
    );
  }
}
