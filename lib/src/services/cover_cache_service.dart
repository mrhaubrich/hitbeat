import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// {@template cover_cache_service}
/// A service for caching album cover art.
/// {@endtemplate}
class CoverCacheService {
  /// {@macro cover_cache_service}
  factory CoverCacheService() => _instance;
  CoverCacheService._internal();
  static final CoverCacheService _instance = CoverCacheService._internal();

  static late final String _cacheDir;

  /// Initializes the cache directory
  static Future<void> ensureInitialized() async {
    _cacheDir = await _getCacheDir();
    await Directory(_cacheDir).create(recursive: true);
  }

  static Future<String> _getCacheDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = p.join(appDir.path, 'covers');
    await Directory(cacheDir).create(recursive: true);
    return cacheDir;
  }

  String _generateCoverHash(Uint8List coverData) {
    final digest = md5.convert(coverData);
    return digest.toString();
  }

  /// Stores the cover data in the cache directory
  String? storeCover(Uint8List? coverData) {
    if (coverData == null) return null;

    final hash = _generateCoverHash(coverData);
    final coverPath = p.join(_cacheDir, '$hash.jpg');

    final file = File(coverPath);
    if (!file.existsSync()) {
      file.writeAsBytesSync(coverData);
    }

    return hash;
  }

  /// Retrieves the cover data from the cache directory
  Uint8List? getCover(String? hash) {
    if (hash == null) return null;

    final coverPath = p.join(_cacheDir, '$hash.jpg');
    final file = File(coverPath);

    if (file.existsSync()) {
      return file.readAsBytesSync();
    }
    return null;
  }

  /// Retrieves the cover path from the cache directory
  String? getCoverPath(String? hash) {
    if (hash == null) return null;

    return p.join(_cacheDir, '$hash.jpg');
  }
}
