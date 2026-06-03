import 'dart:io';

import 'package:path/path.dart' as p;

/// Locates the flutter_smartgen package root (contains pubspec + example/).
String findPackageRoot({String? startPath}) {
  final List<String> candidates = <String>[
    if (startPath != null) startPath,
    ..._scriptSearchRoots(),
    Directory.current.path,
  ];

  for (final String candidate in candidates) {
    final String? root = _walkForRoot(candidate);
    if (root != null) {
      return root;
    }
  }

  throw StateError(
    'Could not find flutter_smartgen package root (pubspec + example/).',
  );
}

List<String> _scriptSearchRoots() {
  try {
    if (Platform.script.scheme != 'file') {
      return const <String>[];
    }
    final String scriptPath = Platform.script.toFilePath();
    final String scriptDir = p.dirname(scriptPath);
    return <String>[
      scriptDir,
      p.normalize(p.join(scriptDir, '..')),
      p.normalize(p.join(scriptDir, '../..')),
    ];
  } on Object {
    return const <String>[];
  }
}

String? _walkForRoot(String startPath) {
  Directory current = Directory(startPath).absolute;

  while (true) {
    final File pubspec = File(p.join(current.path, 'pubspec.yaml'));
    final Directory example = Directory(p.join(current.path, 'example'));
    if (pubspec.existsSync() &&
        example.existsSync() &&
        pubspec.readAsStringSync().contains('name: flutter_smartgen')) {
      return current.path;
    }

    final Directory parent = current.parent;
    if (parent.path == current.path) {
      return null;
    }
    current = parent;
  }
}
