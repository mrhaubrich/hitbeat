import 'dart:typed_data' show Uint8List;

import 'package:hitbeat/src/modules/player/models/track.dart';

/// {@template metadata_extractor}
/// Interface for extracting metadata from audio files.
/// {@endtemplate}
abstract interface class IMetadataExtractor {
  /// Extracts metadata from a single audio file
  ///
  /// [path] is the path to the audio file
  /// Returns a [Track] with all the metadata information
  Track extractTrack(String path);

  /// Extracts metadata from multiple audio files
  ///
  /// [paths] is a list of paths to audio files
  /// Returns a list of [Track]s with all the metadata information
  List<Track> extractTracks(List<String> paths);

  /// Extracts the album cover art from an audio file
  ///
  /// [path] is the path to the audio file
  /// Returns the cover art as a base64 encoded string
  /// Returns null if no cover art is found
  Uint8List? extractCoverArt(String path);

  /// Disposes of any resources used by the extractor
  void dispose();
}
