import 'dart:io';

import 'package:flutter_smartgen/src/generators/env_generator.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('EnvGenerator', () {
    late Directory project;

    setUp(() {
      project = Directory.systemTemp.createTempSync('smartgen_env_test');
      Directory(p.join(project.path, 'lib')).createSync();
    });

    tearDown(() {
      if (project.existsSync()) {
        project.deleteSync(recursive: true);
      }
    });

    test('creates both env files when missing', () {
      final EnvGenerationResult result = EnvGenerator(
        projectRoot: project,
      ).generate();

      expect(result.createdCount, 2);
      expect(result.skippedCount, 0);

      final File development = File(
        p.join(project.path, EnvGenerator.developmentFile),
      );
      final File production = File(
        p.join(project.path, EnvGenerator.productionFile),
      );

      expect(development.existsSync(), isTrue);
      expect(production.existsSync(), isTrue);

      final String content = development.readAsStringSync();
      expect(content, contains('BASE_URL='));
      expect(content, contains('API_KEY='));
      expect(production.readAsStringSync(), content);
    });

    test('skips existing files on second run', () {
      EnvGenerator(projectRoot: project).generate();

      final EnvGenerationResult second = EnvGenerator(
        projectRoot: project,
      ).generate();

      expect(second.createdCount, 0);
      expect(second.skippedCount, 2);
    });

    test('creates only missing file when one exists', () {
      File(p.join(project.path, EnvGenerator.developmentFile)).writeAsStringSync(
        'BASE_URL=https://dev.example.com\n',
      );

      final EnvGenerationResult result = EnvGenerator(
        projectRoot: project,
      ).generate();

      expect(result.createdCount, 1);
      expect(result.skippedCount, 1);

      expect(
        File(p.join(project.path, EnvGenerator.productionFile)).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(project.path, EnvGenerator.developmentFile))
            .readAsStringSync(),
        'BASE_URL=https://dev.example.com\n',
      );
    });
  });
}
