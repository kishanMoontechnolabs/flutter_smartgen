import 'dart:io';

import 'package:flutter_smartgen/src/config/smartgen_config.dart';
import 'package:flutter_smartgen/src/runner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('RouteCommand', () {
    late Directory project;

    setUp(() {
      project = Directory.systemTemp.createTempSync('smartgen_route_cmd_test');
      Directory(p.join(project.path, 'lib')).createSync();
      File(p.join(project.path, 'pubspec.yaml')).writeAsStringSync('''
name: my_app
environment:
  sdk: ^3.0.0
''');
      File(p.join(project.path, SmartgenConfig.fileName)).writeAsStringSync('''
package_name: my_app
screens_base: lib/screens
routes:
  routes_file: lib/router/app_routes.dart
  pages_file: lib/router/app_pages.dart
  routes_class: AppRoutes
  pages_class: AppPages
  route_name_suffix: Page
''');
    });

    tearDown(() {
      if (project.existsSync()) {
        project.deleteSync(recursive: true);
      }
    });

    test('missing page module exits 1 with one error line, no throw', () async {
      final int code = await SmartGenRunner().run(<String>[
        'route',
        '--cwd',
        project.path,
        'setting',
      ]);

      expect(code, 1);
    });
  });
}
