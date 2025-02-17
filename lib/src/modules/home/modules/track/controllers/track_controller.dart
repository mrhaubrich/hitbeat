import 'package:hitbeat/src/data/repositories/track_repository.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';
import 'package:rxdart/rxdart.dart';

/// {@template track_controller}
/// Controller for managing tracks.
/// {@endtemplate}
class TrackController {
  /// {@macro track_controller}
  TrackController(this._repository) {
    _loadTracks();
  }

  final TrackRepository _repository;
  final _tracks = BehaviorSubject<List<Track>>.seeded(const []);

  /// The tracks in the player.
  Stream<List<Track>> get tracks$ => _tracks.stream;

  /// The tracks in the player.
  List<Track> get tracks => _tracks.value;

  Future<void> _loadTracks() async {
    final tracks = await _repository.getAllTracks();
    _tracks.add(tracks);
  }

  /// Disposes the controller.
  void dispose() {
    _tracks.close();
  }
}
