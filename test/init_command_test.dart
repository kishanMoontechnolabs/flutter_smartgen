import 'dart:io';

import 'package:flutter_smartgen/src/commands/init_command.dart';
import 'package:flutter_smartgen/src/config/smartgen_config.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('InitCommand', () {
    test('buildDefaultYaml uses package name from pubspec, not a fixed app', () {
      final String yaml = InitCommand.buildDefaultYaml('my_flutter_app');

      expect(yaml, contains('package_name: my_flutter_app'));
      expect(yaml, isNot(contains('c3_mobile_app')));
      expect(yaml, contains('screens_base: lib/screens'));
      expect(yaml, isNot(contains('default_area')));
      expect(yaml, contains('assets:'));
      expect(yaml, contains('directories:'));
      expect(yaml, contains('- assets/images'));
      expect(yaml, contains('# - assets/icons'));
      expect(yaml.indexOf('naming:'), lessThan(yaml.indexOf('assets:')));
    });

    test('creates smartgen.yaml in project root', () async {
      final Directory project =
          Directory.systemTemp.createTempSync('smartgen_init_run');
      try {
        Directory(p.join(project.path, 'lib')).createSync();
        File(p.join(project.path, 'pubspec.yaml')).writeAsStringSync('''
name: test_app
environment:
  sdk: ^3.0.0
''');

        final Directory previous = Directory.current;
        Directory.current = project;
        try {
          final int code = await InitCommand().run();
          expect(code, 0);
        } finally {
          Directory.current = previous;
        }

        final File config =
            File(p.join(project.path, SmartgenConfig.fileName));
        expect(config.existsSync(), isTrue);
        final SmartgenConfig loaded = SmartgenConfig.load(project);
        expect(loaded.packageName, 'test_app');
      } finally {
        project.deleteSync(recursive: true);
      }
    });
  });
}
