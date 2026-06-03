import 'dart:io';

import 'package:path/path.dart' as p;

/// Locates the Flutter/Dart project root containing pubspec.yaml and lib/.
class ProjectRoot {
  ProjectRoot(this.directory);

  final Directory directory;

  static ProjectRoot find({String? startPath}) {
    Directory current = Directory(
      startPath ?? Directory.current.path,
    ).absolute;

    while (true) {
      final File pubspec = File(p.join(current.path, 'pubspec.yaml'));
      final Directory libDir = Directory(p.join(current.path, 'lib'));
      if (pubspec.existsSync() && libDir.existsSync()) {
        return ProjectRoot(current);
      }

      final Directory parent = current.parent;
      if (parent.path == current.path) {
        throw StateError(
          'Could not find a Flutter project root (pubspec.yaml + lib/). '
          'Run smartgen from your app directory.',
        );
      }
      current = parent;
    }
  }

  String readPackageName() {
    final File pubspec = File(p.join(directory.path, 'pubspec.yaml'));
    final RegExp namePattern = RegExp(r'^name:\s*(\S+)', multiLine: true);
    final Match? match = namePattern.firstMatch(pubspec.readAsStringSync());
    if (match == null) {
      throw FormatException('Could not read package name from pubspec.yaml.');
    }
    return match.group(1)!;
  }
}
