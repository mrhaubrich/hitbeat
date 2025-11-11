import 'dart:async';

import 'package:hitbeat/src/data/database/database.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';
import 'package:hitbeat/src/modules/playlist/services/playlist_service.dart';

/// {@template queue_persistence_service}
/// Service that automatically saves and restores the playing queue.
/// {@endtemplate}
class QueuePersistenceService {
  /// {@macro queue_persistence_service}
  QueuePersistenceService({
    required IAudioPlayer audioPlayer,
    required PlaylistService playlistService,
    required HitBeatDatabase database,
  }) : _audioPlayer = audioPlayer,
       _playlistService = playlistService,
       _database = database;

  final IAudioPlayer _audioPlayer;
  final PlaylistService _playlistService;
  final HitBeatDatabase _database;
  StreamSubscription<List<dynamic>>? _tracklistSubscription;
  StreamSubscription<bool>? _isPlayingSubscription;
  Timer? _saveTimer;
  Timer? _periodicSaveTimer;

  /// Initializes the service and loads the saved queue.
  Future<void> initialize() async {
    // Load the saved queue
    await _loadQueue();

    // Listen to tracklist changes and save them
    _tracklistSubscription = _audioPlayer.tracklist$.listen(
      _onTracklistChanged,
    );

    // Listen to playing state to enable periodic saves during playback
    _isPlayingSubscription = _audioPlayer.isPlaying$.listen(
      _onPlayingStateChanged,
    );
  }

  /// Disposes of the service.
  void dispose() {
    _tracklistSubscription?.cancel();
    _isPlayingSubscription?.cancel();
    _saveTimer?.cancel();
    _periodicSaveTimer?.cancel();
  }

  Future<void> _loadQueue() async {
    try {
      final tracks = await _playlistService.loadCurrentQueue();
      if (tracks.isNotEmpty) {
        // Load the tracks into the player
        _audioPlayer.concatTracks(tracks);

        // Load and restore playback state
        final state = await _database.loadQueuePlaybackState();
        if (state != null &&
            state.trackIndex >= 0 &&
            state.trackIndex < tracks.length) {
          // Set the track at the saved index
          await _audioPlayer.setTrack(tracks[state.trackIndex]);
          // Set the playback position
          await _audioPlayer.setCurrentTime(state.position);
          // Keep it paused (don't auto-play on startup)
        }
      }
    } catch (e) {
      // Silently fail if loading fails
      // This is expected on first run when no queue exists
    }
  }

  void _onTracklistChanged(List<dynamic> tracklist) {
    // Debounce saves to avoid excessive database writes
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), _saveQueue);
  }

  void _onPlayingStateChanged(bool isPlaying) {
    if (isPlaying) {
      // Start periodic saves every 5 seconds while playing
      _periodicSaveTimer?.cancel();
      _periodicSaveTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _savePlaybackState(),
      );
    } else {
      // Stop periodic saves when paused/stopped, but save once
      _periodicSaveTimer?.cancel();
      unawaited(_savePlaybackState());
    }
  }

  Future<void> _saveQueue() async {
    try {
      await _playlistService.saveCurrentQueue(_audioPlayer.tracklist);
    } catch (e) {
      // Silently fail if saving fails
    }
  }

  Future<void> _savePlaybackState() async {
    try {
      final currentIndex = _audioPlayer.currentIndex;
      final currentTime = _audioPlayer.currentTime;

      // Only save if we have a valid index
      if (currentIndex >= 0) {
        await _database.saveQueuePlaybackState(
          currentTrackIndex: currentIndex,
          currentPosition: currentTime,
        );
      }
    } catch (e) {
      // Silently fail if saving fails
    }
  }

  /// Manually saves the current queue and playback state.
  /// Called when the app is closing or going to background.
  Future<void> saveNow() async {
    _saveTimer?.cancel();
    _periodicSaveTimer?.cancel();
    await _saveQueue();
    await _savePlaybackState();
  }
}
