import 'dart:io';

import 'package:flutter_smartgen/src/runner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('AppCommand', () {
    late Directory project;

    setUp(() {
      project = Directory.systemTemp.createTempSync('smartgen_app_cmd_test');
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

    test('creates app files via CLI', () async {
      final int code = await SmartGenRunner().run(<String>[
        'app',
        '--cwd',
        project.path,
      ]);

      expect(code, 0);
      expect(
        File(p.join(project.path, 'lib/app/app_class.dart')).existsSync(),
        isTrue,
      );
    });

    test('invalid name exits 1 without stack trace', () async {
      final int code = await SmartGenRunner().run(<String>[
        'app',
        '--cwd',
        project.path,
        'foo',
      ]);

      expect(code, 1);
    });
  });
}
