import 'dart:io';
import 'dart:isolate';
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
  static bool _isInitialized = false;

  /// Initializes the cache directory
  static Future<void> ensureInitialized() async {
    if (_isInitialized) return;
    _cacheDir = await _getCacheDir();
    await Directory(_cacheDir).create(recursive: true);
    _isInitialized = true;
  }

  static Future<String> _getCacheDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = p.join(appDir.path, 'covers');
    await Directory(cacheDir).create(recursive: true);
    return cacheDir;
  }

  static String _generateCoverHashSync(Uint8List coverData) {
    final digest = md5.convert(coverData);
    return digest.toString();
  }

  /// Offload hash generation to a separate isolate for large images to avoid
  /// blocking the UI. For small images (< 200KB) we keep it synchronous to
  /// reduce overhead.
  Future<String> _generateCoverHashAsync(Uint8List coverData) async {
    if (coverData.lengthInBytes < 200 * 1024) {
      return _generateCoverHashSync(coverData);
    }
    final receivePort = ReceivePort();
    await Isolate.spawn<_HashParams>(
      _hashEntryPoint,
      _HashParams(coverData, receivePort.sendPort),
    );
    return await receivePort.first as String;
  }

  static void _hashEntryPoint(_HashParams params) {
    final result = _generateCoverHashSync(params.data);
    params.sendPort.send(result);
  }

  /// Async variant to store cover without blocking UI.
  Future<String?> storeCoverAsync(Uint8List? coverData) async {
    if (coverData == null) return null;
    if (!_isInitialized) {
      await ensureInitialized();
    }
    final hash = await _generateCoverHashAsync(coverData);
    final coverPath = p.join(_cacheDir, '$hash.jpg');
    final file = File(coverPath);
    if (!file.existsSync()) {
      await file.writeAsBytes(coverData, flush: true);
    }
    return hash;
  }

  /// Stores the cover data in the cache directory (synchronous, legacy API).
  String? storeCover(Uint8List? coverData) {
    if (coverData == null) return null;
    final hash = _generateCoverHashSync(coverData);
    final coverPath = p.join(_cacheDir, '$hash.jpg');
    final file = File(coverPath);
    if (!file.existsSync()) {
      file.writeAsBytesSync(coverData);
    }
    return hash;
  }

  /// Async variant to retrieve cover without blocking UI.
  Future<Uint8List?> getCoverAsync(String? hash) async {
    if (hash == null) return null;
    if (!_isInitialized) {
      await ensureInitialized();
    }
    final coverPath = p.join(_cacheDir, '$hash.jpg');
    final file = File(coverPath);
    if (await file.exists()) {
      return file.readAsBytes();
    }
    return null;
  }

  /// Retrieves the cover data from the cache directory (synchronous, legacy API)
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
    if (!_isInitialized) return null;
    return p.join(_cacheDir, '$hash.jpg');
  }
}

/// Payload used to communicate with hashing isolate.
class _HashParams {
  _HashParams(this.data, this.sendPort);
  final Uint8List data;
  final SendPort sendPort;
}
