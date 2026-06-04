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
    return writeNewFile(file: file, content: content);
  }

  /// Creates parent directories and writes [content] to [file].
  static WriteResult writeNewFile({
    required File file,
    required String content,
  }) {
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(content);
    return WriteResult(path: file.path, created: true, skipped: false);
  }

  /// Inserts [contentToAppend] before the final closing brace in [file].
  static void appendBeforeClosingBrace({
    required File file,
    required String contentToAppend,
  }) {
    final String existing = file.readAsStringSync();
    final int lastBrace = existing.lastIndexOf('}');
    if (lastBrace == -1) {
      throw FormatException('Could not find closing brace in ${file.path}.');
    }

    final String prefix = existing.substring(0, lastBrace);
    final String needsNewline = prefix.endsWith('\n') ? '' : '\n';
    final String updated =
        '$prefix$needsNewline$contentToAppend\n${existing.substring(lastBrace)}';
    file.writeAsStringSync(updated);
  }
}
