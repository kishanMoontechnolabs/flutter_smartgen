import 'dart:io';

import 'package:flutter_smartgen/src/generators/env_generator.dart';
import 'package:flutter_smartgen/src/runner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('EnvCommand', () {
    late Directory project;

    setUp(() {
      project = Directory.systemTemp.createTempSync('smartgen_env_cmd_test');
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

    test('creates env files via CLI', () async {
      final int code = await SmartGenRunner().run(<String>[
        'env',
        '--cwd',
        project.path,
      ]);

      expect(code, 0);
      expect(
        File(p.join(project.path, EnvGenerator.developmentFile)).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(project.path, EnvGenerator.productionFile)).existsSync(),
        isTrue,
      );
    });
  });
}
