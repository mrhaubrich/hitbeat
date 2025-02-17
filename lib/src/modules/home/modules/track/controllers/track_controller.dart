import 'package:hitbeat/src/data/repositories/track_repository.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';
import 'package:rxdart/rxdart.dart';

class TrackController {
  TrackController(this._repository) {
    _loadTracks();
  }

  final TrackRepository _repository;
  final _tracks = BehaviorSubject<List<Track>>.seeded(const []);

  Stream<List<Track>> get tracks$ => _tracks.stream;
  List<Track> get tracks => _tracks.value;

  Future<void> _loadTracks() async {
    final tracks = await _repository.getAllTracks();
    _tracks.add(tracks);
  }

  void dispose() {
    _tracks.close();
  }
}
