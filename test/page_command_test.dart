import 'dart:io';

import 'package:flutter_smartgen/src/config/smartgen_config.dart';
import 'package:flutter_smartgen/src/runner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('PageCommand --route', () {
    late Directory project;

    setUp(() {
      project = Directory.systemTemp.createTempSync('smartgen_page_cmd_test');
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

    test('registers routes when --route is set', () async {
      final int code = await SmartGenRunner().run(<String>[
        'page',
        '--cwd',
        project.path,
        '--route',
        'profile',
      ]);

      expect(code, 0);

      final File routesFile =
          File(p.join(project.path, 'lib', 'router', 'app_routes.dart'));
      expect(routesFile.existsSync(), isTrue);
      expect(
        routesFile.readAsStringSync(),
        contains("static const String profilePage = '/profile';"),
      );

      final File pagesFile =
          File(p.join(project.path, 'lib', 'router', 'app_pages.dart'));
      expect(pagesFile.readAsStringSync(), contains('name: AppRoutes.profilePage'));
    });
  });
}
