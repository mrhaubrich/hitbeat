import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitbeat/src/data/repositories/track_repository.dart';
import 'package:hitbeat/src/modules/home/modules/dashboard/services/file_handler_service.dart';
import 'package:hitbeat/src/modules/player/interfaces/metadata_extractor.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';

part 'add_songs_event.dart';
part 'add_songs_state.dart';

class AddSongsBloc extends Bloc<AddSongsEvent, AddSongsState> {
  AddSongsBloc({
    required IMetadataExtractor metadataExtractor,
    required TrackRepository trackRepository,
    required FileHandlerService fileHandler,
  })  : _metadataExtractor = metadataExtractor,
        _trackRepository = trackRepository,
        _fileHandler = fileHandler,
        super(const AddSongsInitial()) {
    on<AddSongsPickFiles>(_onPickFiles);
    on<AddSongsDropFiles>(_onDropFiles);
    on<AddSongsSave>(_onSave);
    on<AddSongsClear>(_onClear);
  }

  final IMetadataExtractor _metadataExtractor;
  final TrackRepository _trackRepository;
  final FileHandlerService _fileHandler;

  Future<void> _onPickFiles(
    AddSongsPickFiles event,
    Emitter<AddSongsState> emit,
  ) async {
    try {
      emit(const AddSongsLoading());
      final paths = await _fileHandler.pickFiles();
      if (paths.isEmpty) {
        emit(const AddSongsInitial());
        return;
      }
      await _processFiles(paths, emit);
    } catch (e) {
      emit(AddSongsError(e.toString()));
    }
  }

  Future<void> _onDropFiles(
    AddSongsDropFiles event,
    Emitter<AddSongsState> emit,
  ) async {
    try {
      emit(const AddSongsLoading());
      final paths = await _fileHandler.handleUris(event.uris);
      if (paths.isEmpty) {
        emit(const AddSongsInitial());
        return;
      }
      await _processFiles(paths, emit);
    } catch (e) {
      emit(AddSongsError(e.toString()));
    }
  }

  Future<void> _processFiles(
    List<String> paths,
    Emitter<AddSongsState> emit,
  ) async {
    final tracks = _metadataExtractor.extractTracks(paths);
    emit(AddSongsLoaded(tracks));
  }

  Future<void> _onSave(
    AddSongsSave event,
    Emitter<AddSongsState> emit,
  ) async {
    try {
      emit(const AddSongsLoading());
      await _trackRepository.insertTracks(event.songs);
      emit(const AddSongsSuccess());
    } catch (e) {
      emit(AddSongsError(e.toString()));
    }
  }

  void _onClear(
    AddSongsClear event,
    Emitter<AddSongsState> emit,
  ) {
    emit(const AddSongsInitial());
  }
}
