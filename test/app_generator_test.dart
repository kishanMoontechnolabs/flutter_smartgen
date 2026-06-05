import 'dart:io';

import 'package:flutter_smartgen/src/generators/app_generator.dart';
import 'package:flutter_smartgen/src/utils/app_file_registry.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('AppGenerator', () {
    late Directory project;

    setUp(() {
      project = Directory.systemTemp.createTempSync('smartgen_app_test');
      Directory(p.join(project.path, 'lib')).createSync();
      File(p.join(project.path, 'pubspec.yaml')).writeAsStringSync('''
name: my_app
environment:
  sdk: ^3.0.0
''');
    });

    tearDown(() {
      if (project.existsSync()) {
        project.deleteSync(recursive: true);
      }
    });

    test('creates all 11 app files when missing', () {
      final AppGenerationResult result = AppGenerator(
        projectRoot: project,
        packageName: 'my_app',
      ).generate();

      expect(result.createdCount, 11);
      expect(result.skippedCount, 0);

      for (final AppFileEntry entry in AppFileRegistry.entries) {
        expect(
          File(p.join(project.path, entry.relativePath)).existsSync(),
          isTrue,
          reason: entry.relativePath,
        );
      }

      final String appClass = File(
        p.join(project.path, 'lib/app/app_class.dart'),
      ).readAsStringSync();
      expect(appClass, contains('factory AppClass() => _singleton'));
      expect(appClass, contains('RxBool isLoading = false.obs'));

      final String appColors = File(
        p.join(project.path, 'lib/app/app_colors.dart'),
      ).readAsStringSync();
      expect(appColors, contains('class AppColors'));
      expect(appColors, isNot(contains('isLoading')));
    });

    test('creates only fonts when fileName is fonts', () {
      final AppGenerationResult result = AppGenerator(
        projectRoot: project,
        packageName: 'my_app',
        fileName: 'fonts',
      ).generate();

      expect(result.createdCount, 1);
      expect(
        File(p.join(project.path, 'lib/app/app_fonts.dart')).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(project.path, 'lib/app/app_colors.dart')).existsSync(),
        isFalse,
      );
    });

    test('skips existing files on second run', () {
      AppGenerator(
        projectRoot: project,
        packageName: 'my_app',
      ).generate();

      final AppGenerationResult second = AppGenerator(
        projectRoot: project,
        packageName: 'my_app',
      ).generate();

      expect(second.createdCount, 0);
      expect(second.skippedCount, 11);
    });

    test('creates only missing file when one exists', () {
      Directory(p.join(project.path, 'lib/app')).createSync(recursive: true);
      File(p.join(project.path, 'lib/app/app_colors.dart')).writeAsStringSync(
        'class AppColors {}',
      );

      final AppGenerationResult result = AppGenerator(
        projectRoot: project,
        packageName: 'my_app',
      ).generate();

      expect(result.createdCount, 10);
      expect(result.skippedCount, 1);
    });

    test('throws for unknown file name', () {
      expect(
        () => AppGenerator(
          projectRoot: project,
          packageName: 'my_app',
          fileName: 'foo',
        ).generate(),
        throwsA(isA<StateError>()),
      );
    });
  });
}
