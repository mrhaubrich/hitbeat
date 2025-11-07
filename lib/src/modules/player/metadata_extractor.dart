import 'dart:io';
import 'dart:typed_data' show Uint8List;

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:collection/collection.dart';
import 'package:hitbeat/src/modules/player/interfaces/metadata_extractor.dart';
import 'package:hitbeat/src/modules/player/models/album.dart';
import 'package:hitbeat/src/modules/player/models/artist.dart';
import 'package:hitbeat/src/modules/player/models/genre.dart';
import 'package:hitbeat/src/modules/player/models/track.dart';
import 'package:hitbeat/src/services/cover_cache_service.dart';

/// {@template metadata_extractor}
/// A class that extracts metadata from audio files.
/// {@endtemplate}
class MetadataExtractor implements IMetadataExtractor {
  /// {@macro metadata_extractor}
  MetadataExtractor(this._coverCache);

  final CoverCacheService _coverCache;

  @override
  void dispose() {}

  AudioMetadata _readMetadata(String path) {
    final file = File(path);
    final metadata = readMetadata(file, getImage: true)
      ..title ??= file.path.split('/').last;

    return metadata;
  }

  Uint8List? _extractCoverArt(AudioMetadata metadata) {
    final coverFront = metadata.pictures.firstWhereOrNull(
      (element) => element.pictureType == PictureType.coverFront,
    );

    return coverFront?.bytes ?? metadata.pictures.firstOrNull?.bytes;
  }

  @override
  Uint8List? extractCoverArt(String path) {
    final metadata = _readMetadata(path);
    return _extractCoverArt(metadata);
  }

  Artist _extractArtist(AudioMetadata metadata) {
    return Artist(
      name: metadata.artist ?? 'Unknown',
      image: metadata.pictures
          .firstWhereOrNull(
            (element) => element.pictureType == PictureType.artistPerformer,
          )
          ?.bytes,
      albums: const [],
    );
  }

  Album _extractAlbum(AudioMetadata metadata) {
    final coverData = _extractCoverArt(metadata);
    final coverHash = _coverCache.storeCover(coverData);

    return Album(
      name: metadata.album ?? 'Unknown',
      artist: _extractArtist(metadata),
      coverHash: coverHash,
      tracks: const [],
    );
  }

  List<Genre> _extractGenres(AudioMetadata metadata) {
    return metadata.genres
        .map(
          (e) => Genre(
            name: e,
          ),
        )
        .toList();
  }

  @override
  Future<Track> extractTrack(String path) async {
    final metadata = _readMetadata(path);

    if (metadata.duration == null) {
      throw Exception('Failed to read duration');
    }

    final track = Track(
      name: metadata.title ?? 'Unknown',
      album: _extractAlbum(metadata),
      artist: _extractArtist(metadata),
      duration: metadata.duration!,
      path: 'file:///$path',
      genres: _extractGenres(metadata),
    );

    return track;
  }

  @override
  Future<List<Track>> extractTracks(List<String> paths) async {
    // Limit concurrency to avoid UI starvation and reduce memory pressure.
    const poolSize = 3;
    final results = List<Track?>.filled(paths.length, null);
    var index = 0;

    Future<void> worker() async {
      while (true) {
        final current = index++;
        if (current >= paths.length) break;
        final p = paths[current];
        results[current] = await extractTrack(p);
      }
    }

    await Future.wait(List.generate(poolSize, (_) => worker()));
    return results.whereType<Track>().toList();
  }
}
