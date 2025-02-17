import 'dart:io';

import 'package:file_picker/file_picker.dart';

class FileHandlerService {
  static const supportedExtensions = ['.mp3', '.wav', '.flac', '.m4a'];

  bool isAudioFile(String path) {
    final extension = path.toLowerCase();
    return supportedExtensions.any(extension.endsWith);
  }

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

  Future<List<String>> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions:
          supportedExtensions.map((e) => e.substring(1)).toList(),
      allowMultiple: true,
      dialogTitle: 'Select audio files',
    );

    if (result == null) return [];

    final allPaths = <String>[];
    for (final file in result.files) {
      final path = file.path!;
      if (FileSystemEntity.isDirectorySync(path)) {
        allPaths.addAll(getAudioFilesFromDirectory(path));
      } else {
        allPaths.add(path);
      }
    }

    return allPaths;
  }

  Future<List<String>> handleUris(List<Uri?> uris) async {
    final allPaths = <String>[];

    for (final uri in uris) {
      if (uri == null) continue;
      final path = uri.toFilePath();

      if (FileSystemEntity.isDirectorySync(path)) {
        allPaths.addAll(getAudioFilesFromDirectory(path));
      } else if (isAudioFile(path)) {
        allPaths.add(path);
      }
    }

    return allPaths;
  }
}
