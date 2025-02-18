import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitbeat/src/modules/home/modules/dashboard/blocs/bloc/drag_n_drop_bloc.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

/// {@template drop_zone_widget}
/// A widget that displays a drop zone for files.
/// {@endtemplate}
class DropZoneWidget extends StatelessWidget {
  /// {@macro drop_zone_widget}
  const DropZoneWidget({
    required this.isLoading,
    required this.onTap,
    required this.onDrop,
    required this.dragNDropBloc,
    super.key,
  });

  /// Whether the controller is loading.
  final bool isLoading;

  /// A callback that is called when the user taps the drop zone.
  final VoidCallback onTap;

  /// A callback that is called when the user drops files.
  final FutureOr<void> Function(List<Uri?>) onDrop;

  /// The bloc that handles the drag and drop state.
  final DragNDropBloc dragNDropBloc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropRegion(
      formats: const [Formats.fileUri],
      onDropOver: (event) {
        dragNDropBloc.add(const DragStartEvent());
        return DropOperation.copy;
      },
      onDropLeave: (_) => dragNDropBloc.add(const DragEndEvent()),
      onPerformDrop: (event) async {
        dragNDropBloc.add(const DragEndEvent());
        if (event.session.items.isEmpty) return;

        final item = event.session.items;
        final urisFutures = item.map((i) async {
          Uri? data;
          final completer = Completer<void>();
          i.dataReader?.getValue(
            Formats.fileUri,
            (value) {
              data = value;
              completer.complete();
            },
          );
          await completer.future;
          return data;
        }).toList();

        final uris = await Future.wait(urisFutures);

        await onDrop(uris);
      },
      child: BlocProvider(
        create: (context) => dragNDropBloc,
        child: BlocBuilder<DragNDropBloc, DragNDropState>(
          builder: (context, state) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface.withValues(alpha: 0.8),
                  ],
                ),
                border: Border.all(
                  color: state.isDragging
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.5),
                  width: state.isDragging ? 3 : 2,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: state.isDragging
                        ? theme.colorScheme.primary.withValues(alpha: 0.3)
                        : Colors.transparent,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: _DropZoneContent(
                isLoading: isLoading,
                onTap: onTap,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DropZoneContent extends StatelessWidget {
  const _DropZoneContent({
    required this.isLoading,
    required this.onTap,
  });
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const CircularProgressIndicator()
              else
                BlocBuilder<DragNDropBloc, DragNDropState>(
                  builder: (context, state) {
                    return Icon(
                      Icons.cloud_upload_rounded,
                      size: 80,
                      color: state.isDragging
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    );
                  },
                ),
              const SizedBox(height: 24),
              BlocBuilder<DragNDropBloc, DragNDropState>(
                builder: (context, state) {
                  return Text(
                    'Drag and drop music files here\nor click to select files',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: state.isDragging
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(
                'Supported formats: MP3, WAV, FLAC, M4A',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
