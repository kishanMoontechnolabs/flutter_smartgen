import 'dart:io';

import 'package:flutter_smartgen/src/utils/asset_scanner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('AssetScanner', () {
    late Directory project;

    setUp(() {
      project = Directory.systemTemp.createTempSync('smartgen_asset_scan_test');
      Directory(p.join(project.path, 'assets', 'images')).createSync(
        recursive: true,
      );
      Directory(p.join(project.path, 'assets', 'icons')).createSync(
        recursive: true,
      );

      File(p.join(project.path, 'assets', 'images', 'ic_back.svg'))
          .writeAsStringSync('<svg></svg>');
      File(p.join(project.path, 'assets', 'images', 'notes.txt'))
          .writeAsStringSync('included');
      File(p.join(project.path, 'assets', 'icons', 'search_icon.svg'))
          .writeAsStringSync('<svg></svg>');
      File(p.join(project.path, 'assets', 'icons', '.DS_Store'))
          .writeAsStringSync('skip');
    });

    tearDown(() {
      if (project.existsSync()) {
        project.deleteSync(recursive: true);
      }
    });

    test('scans all files in configured directories', () {
      final List<ScannedAsset> assets = AssetScanner(
        projectRoot: project,
        directories: <String>['assets/images', 'assets/icons'],
      ).scan();

      expect(assets.length, 3);
      expect(assets.map((ScannedAsset a) => a.assetPath), [
        'assets/images/ic_back.svg',
        'assets/images/notes.txt',
        'assets/icons/search_icon.svg',
      ]);
    });
  });
}
