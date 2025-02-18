import 'package:flutter/material.dart';
import 'package:hitbeat/src/data/repositories/track_repository.dart';
import 'package:hitbeat/src/modules/home/modules/dashboard/services/file_handler_service.dart';
import 'package:hitbeat/src/modules/player/interfaces/metadata_extractor.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';

/// {@template add_songs_state}
/// The state of the [AddSongsController].
/// {@endtemplate}
class AddSongsState {
  /// {@macro add_songs_state}
  const AddSongsState({
    this.isDragging = false,
    this.isLoading = false,
    this.error,
    this.songs = const [],
  });

  /// Whether the user is dragging files.
  final bool isDragging;

  /// Whether the controller is loading.
  final bool isLoading;

  /// The error message.
  final String? error;

  /// The list of songs.
  final List<Track> songs;

  /// Creates a copy of this state with the given fields replaced by
  /// the new values.
  AddSongsState copyWith({
    bool? isDragging,
    bool? isLoading,
    String? error,
    List<Track>? songs,
  }) {
    return AddSongsState(
      isDragging: isDragging ?? this.isDragging,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      songs: songs ?? this.songs,
    );
  }
}

/// {@template add_songs_controller}
/// A controller that handles adding songs to the database.
/// {@endtemplate}
class AddSongsController extends ValueNotifier<AddSongsState> {
  /// {@macro add_songs_controller}
  AddSongsController({
    required IMetadataExtractor metadataExtractor,
    required TrackRepository trackRepository,
    required FileHandlerService fileHandler,
  })  : _metadataExtractor = metadataExtractor,
        _trackRepository = trackRepository,
        _fileHandler = fileHandler,
        super(const AddSongsState());
  final IMetadataExtractor _metadataExtractor;
  final TrackRepository _trackRepository;
  final FileHandlerService _fileHandler;

  /// Sets the dragging state.
  // ignore: avoid_positional_boolean_parameters
  void setDragging(bool isDragging) {
    value = value.copyWith(isDragging: isDragging);
  }

  /// Handles the file drop event.
  Future<void> handleFileDrop() async {
    value = value.copyWith(isLoading: true);
    try {
      final paths = await _fileHandler.pickFiles();
      if (paths.isEmpty) {
        value = value.copyWith(isLoading: false);
        return;
      }
      await _processFiles(paths);
      //
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      value = value.copyWith(error: e.toString());
    } finally {
      value = value.copyWith(isLoading: false);
    }
  }

  /// Handles the native file drop event.
  Future<void> handleNativeFileDrop(List<Uri?> uris) async {
    value = value.copyWith(isLoading: true);
    try {
      final paths = await _fileHandler.handleUris(uris);
      if (paths.isEmpty) {
        value = value.copyWith(isLoading: false);
        return;
      }
      await _processFiles(paths);
      //
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      value = value.copyWith(error: e.toString());
    } finally {
      value = value.copyWith(isLoading: false);
    }
  }

  Future<void> _processFiles(List<String> paths) async {
    final tracks = _metadataExtractor.extractTracks(paths);
    // Update state with extracted tracks instead of saving them
    value = value.copyWith(
      songs: tracks,
      isLoading: false,
      isDragging: false,
    );
  }

  /// Saves the list of songs.
  Future<void> saveSongs(List<Track> songs) async {
    value = value.copyWith(isLoading: true);
    try {
      await _trackRepository.insertTracks(songs);
      value = const AddSongsState();
      //
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      value = value.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Clears the list of songs.
  void clearSongs() {
    value = const AddSongsState();
  }
}
