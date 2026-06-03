import 'dart:io';

/// Result of writing a generated file.
class WriteResult {
  const WriteResult({
    required this.path,
    required this.created,
    required this.skipped,
  });

  final String path;
  final bool created;
  final bool skipped;
}

/// Creates directories and writes files with skip-if-exists behavior.
class FileOps {
  static WriteResult writeFile({
    required File file,
    required String content,
  }) {
    if (file.existsSync()) {
      return WriteResult(path: file.path, created: false, skipped: true);
    }
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(content);
    return WriteResult(path: file.path, created: true, skipped: false);
  }
}
