import 'dart:io';

import 'package:file_picker/file_picker.dart';

/// A service that handles file operations.
class FileHandlerService {
  /// The supported audio file extensions.
  static const supportedExtensions = ['.mp3', '.wav', '.flac', '.m4a'];

  /// Checks if the given path is an audio file.
  bool isAudioFile(String path) {
    final extension = path.toLowerCase();
    return supportedExtensions.any(extension.endsWith);
  }

  /// Gets all audio files from the given directory.
  List<String> getAudioFilesFromDirectory(String dirPath) {
    final dir = Directory(dirPath);
    final audioFiles = <String>[];

    if (!dir.existsSync()) return audioFiles;

    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File && isAudioFile(entity.path)) {
        audioFiles.add(entity.path);
      }
    }

    return audioFiles;
  }

  /// Gets all audio files from the given directory asynchronously, avoiding UI blocking.
  Future<List<String>> getAudioFilesFromDirectoryAsync(String dirPath) async {
    final dir = Directory(dirPath);
    final audioFiles = <String>[];

    if (!await dir.exists()) return audioFiles;

    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File && isAudioFile(entity.path)) {
        audioFiles.add(entity.path);
      }
    }

    return audioFiles;
  }

  /// Picks audio files from the device.
  Future<List<String>> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: supportedExtensions
          .map((e) => e.substring(1))
          .toList(),
      allowMultiple: true,
      dialogTitle: 'Select audio files',
    );

    if (result == null) return [];

    final allPaths = <String>[];
    for (final file in result.files) {
      final path = file.path!;
      if (await FileSystemEntity.isDirectory(path)) {
        allPaths.addAll(await getAudioFilesFromDirectoryAsync(path));
      } else {
        allPaths.add(path);
      }
    }

    return allPaths;
  }

  /// Handles the given URIs.
  Future<List<String>> handleUris(List<Uri?> uris) async {
    final allPaths = <String>[];

    for (final uri in uris) {
      if (uri == null) continue;
      final path = uri.toFilePath();

      if (await FileSystemEntity.isDirectory(path)) {
        allPaths.addAll(await getAudioFilesFromDirectoryAsync(path));
      } else if (isAudioFile(path)) {
        allPaths.add(path);
      }
    }

    return allPaths;
  }
}
