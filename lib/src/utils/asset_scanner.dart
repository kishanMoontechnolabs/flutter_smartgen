import 'dart:io';

import 'package:path/path.dart' as p;

/// A single asset file discovered under a configured assets directory.
class ScannedAsset {
  const ScannedAsset({
    required this.assetPath,
    required this.fileName,
    required this.directory,
  });

  /// Full asset path (e.g. `assets/icons/search_icon.svg`).
  final String assetPath;

  /// File name with extension (e.g. `search_icon.svg`).
  final String fileName;

  /// Configured directory (e.g. `assets/icons`).
  final String directory;
}

/// Scans configured asset directories for files.
class AssetScanner {
  AssetScanner({
    required this.projectRoot,
    required this.directories,
  });

  final Directory projectRoot;
  final List<String> directories;

  /// Returns discovered assets sorted by directory order, then file name.
  List<ScannedAsset> scan() {
    final List<ScannedAsset> results = <ScannedAsset>[];

    for (final String directoryPath in directories) {
      final Directory directory = Directory(
        p.join(projectRoot.path, directoryPath),
      );
      if (!directory.existsSync()) {
        continue;
      }

      for (final FileSystemEntity entity in directory.listSync()) {
        if (entity is! File) {
          continue;
        }

        final String fileName = p.basename(entity.path);
        if (fileName.startsWith('.') || fileName == '.DS_Store') {
          continue;
        }

        final String assetPath = p
            .join(directoryPath, fileName)
            .replaceAll(r'\', '/');

        results.add(
          ScannedAsset(
            assetPath: assetPath,
            fileName: fileName,
            directory: directoryPath,
          ),
        );
      }
    }

    results.sort((ScannedAsset a, ScannedAsset b) {
      final int directoryCompare = directories
          .indexOf(a.directory)
          .compareTo(directories.indexOf(b.directory));
      if (directoryCompare != 0) {
        return directoryCompare;
      }
      return a.fileName.compareTo(b.fileName);
    });

    return results;
  }
}
