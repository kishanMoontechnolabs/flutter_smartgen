import 'dart:io';

import 'package:flutter_smartgen/src/config/smartgen_config.dart';
import 'package:flutter_smartgen/src/generators/page_generator.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('PageGenerator', () {
    late Directory project;

    setUp(() {
      project = Directory.systemTemp.createTempSync('smartgen_page_test');
      Directory(p.join(project.path, 'lib')).createSync();
      File(p.join(project.path, 'pubspec.yaml')).writeAsStringSync('''
name: my_app
environment:
  sdk: ^3.0.0
''');
      File(p.join(project.path, SmartgenConfig.fileName)).writeAsStringSync('''
package_name: my_app
screens_base: lib/screens
naming:
  screen_suffix: Screen
  controller_suffix: Controller
''');
    });

    tearDown(() {
      if (project.existsSync()) {
        project.deleteSync(recursive: true);
      }
    });

    test('creates 6 files for a new page', () {
      final PageGenerationResult result = PageGenerator(
        projectRoot: project,
        config: SmartgenConfig.load(project),
        pageName: 'profile',
      ).generate();

      expect(result.results, hasLength(6));
      expect(result.createdCount, 6);

      final String modulePath = p.join(
        project.path,
        'lib',
        'screens',
        'profile_screen',
      );
      expect(Directory(modulePath).existsSync(), isTrue);
      expect(File(p.join(modulePath, 'profile.dart')).existsSync(), isTrue);
      expect(
        File(p.join(modulePath, 'view', 'profile_screen.dart')).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(modulePath, 'binding', 'profile_screen_binding.dart'))
            .existsSync(),
        isTrue,
      );
      expect(
        Directory(p.join(modulePath, 'view', 'widget')).existsSync(),
        isFalse,
      );
    });

    test('skips existing files on second run', () {
      final SmartgenConfig config = SmartgenConfig.load(project);
      PageGenerator(
        projectRoot: project,
        config: config,
        pageName: 'profile',
      ).generate();

      final PageGenerationResult second = PageGenerator(
        projectRoot: project,
        config: config,
        pageName: 'profile',
      ).generate();

      expect(second.createdCount, 0);
      expect(second.skippedCount, 6);
    });
  });
}
