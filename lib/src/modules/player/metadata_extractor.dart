import 'dart:io';
import 'dart:typed_data' show Uint8List;

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:collection/collection.dart';
import 'package:hitbeat/src/modules/player/interfaces/metadata_extractor.dart';
import 'package:hitbeat/src/modules/player/models/album.dart';
import 'package:hitbeat/src/modules/player/models/artist.dart';
import 'package:hitbeat/src/modules/player/models/genre.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';

/// {@template metadata_extractor}
/// A class that extracts metadata from audio files.
/// {@endtemplate}
class MetadataExtractor implements IMetadataExtractor {
  AudioMetadata? _metadata;

  @override
  void dispose() {
    _metadata = null;
  }

  AudioMetadata _readMetadata(String path) {
    final file = File(path);
    final metadata = readMetadata(file, getImage: true)
      ..title ??= file.path.split('/').last;

    return metadata;
  }

  Uint8List? _extractCoverArt() {
    final coverFront = _metadata!.pictures.firstWhereOrNull(
      (element) => element.pictureType == PictureType.coverFront,
    );

    return coverFront?.bytes ?? _metadata!.pictures.firstOrNull?.bytes;
  }

  @override
  Uint8List? extractCoverArt(String path) {
    _metadata ??= _readMetadata(path);

    return _extractCoverArt();
  }

  Artist _extractArtist() {
    return Artist(
      name: _metadata!.artist ?? 'Unknown',
      image: _metadata!.pictures
          .firstWhereOrNull(
            (element) => element.pictureType == PictureType.artistPerformer,
          )
          ?.bytes,
      albums: const [],
    );
  }

  Album _extractAlbum() {
    return Album(
      name: _metadata!.album ?? 'Unknown',
      artist: _extractArtist(),
      cover: _extractCoverArt(),
      tracks: const [],
    );
  }

  List<Genre> _extractGenres() {
    return _metadata!.genres
        .map(
          (e) => Genre(
            name: e,
          ),
        )
        .toList();
  }

  @override
  Track extractTrack(String path) {
    _metadata ??= _readMetadata(path);

    if (_metadata == null) {
      throw Exception('Failed to read metadata');
    }

    if (_metadata!.duration == null) {
      throw Exception('Failed to read duration');
    }

    final track = Track(
      name: _metadata!.title ?? 'Unknown',
      album: _extractAlbum(),
      artist: _extractArtist(),
      duration: _metadata!.duration!,
      path: path,
      genres: _extractGenres(),
    );

    _metadata = null;

    return track;
  }

  @override
  List<Track> extractTracks(List<String> paths) {
    final tracks = paths.map(extractTrack);
    return List<Track>.from(tracks);
  }
}
