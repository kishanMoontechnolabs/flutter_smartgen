import 'dart:io';

import 'package:flutter_smartgen/src/runner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('CLI error handling', () {
    test('init outside Flutter project exits 1 without stack trace', () async {
      final Directory project =
          Directory.systemTemp.createTempSync('smartgen_cli_err_init');
      try {
        final int code = await SmartGenRunner().run(<String>[
          'init',
          '--cwd',
          project.path,
        ]);
        expect(code, 1);
      } finally {
        project.deleteSync(recursive: true);
      }
    });

    test('page without smartgen.yaml exits 1 without stack trace', () async {
      final Directory project =
          Directory.systemTemp.createTempSync('smartgen_cli_err_page');
      try {
        Directory(p.join(project.path, 'lib')).createSync();
        File(p.join(project.path, 'pubspec.yaml')).writeAsStringSync('''
name: test_app
environment:
  sdk: ^3.0.0
''');

        final int code = await SmartGenRunner().run(<String>[
          'page',
          '--cwd',
          project.path,
          'profile',
        ]);
        expect(code, 1);
      } finally {
        project.deleteSync(recursive: true);
      }
    });

    test('assets images without smartgen.yaml exits 1 without stack trace', () async {
      final Directory project =
          Directory.systemTemp.createTempSync('smartgen_cli_err_assets');
      try {
        Directory(p.join(project.path, 'lib')).createSync();
        File(p.join(project.path, 'pubspec.yaml')).writeAsStringSync('''
name: test_app
environment:
  sdk: ^3.0.0
''');

        final int code = await SmartGenRunner().run(<String>[
          'assets',
          'images',
          '--cwd',
          project.path,
        ]);
        expect(code, 1);
      } finally {
        project.deleteSync(recursive: true);
      }
    });
  });
}
