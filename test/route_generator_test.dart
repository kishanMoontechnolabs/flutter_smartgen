import 'dart:io';

import 'package:flutter_smartgen/src/config/smartgen_config.dart';
import 'package:flutter_smartgen/src/generators/page_generator.dart';
import 'package:flutter_smartgen/src/generators/route_generator.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('RouteGenerator', () {
    late Directory project;

    SmartgenConfig configWithRoutes() {
      return SmartgenConfig.load(project);
    }

    void writeConfig() {
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
    }

    setUp(() {
      project = Directory.systemTemp.createTempSync('smartgen_route_test');
      Directory(p.join(project.path, 'lib')).createSync();
      File(p.join(project.path, 'pubspec.yaml')).writeAsStringSync('''
name: my_app
environment:
  sdk: ^3.0.0
''');
      writeConfig();
    });

    tearDown(() {
      if (project.existsSync()) {
        project.deleteSync(recursive: true);
      }
    });

    test('creates lib/router when missing and registers route', () {
      PageGenerator(
        projectRoot: project,
        config: configWithRoutes(),
        pageName: 'profile',
      ).generate();

      final RouteGenerationResult result = RouteGenerator(
        projectRoot: project,
        config: configWithRoutes(),
        pageName: 'profile',
      ).register();

      expect(result.addedCount, 2);

      final File routesFile =
          File(p.join(project.path, 'lib', 'router', 'app_routes.dart'));
      final File pagesFile =
          File(p.join(project.path, 'lib', 'router', 'app_pages.dart'));

      expect(routesFile.existsSync(), isTrue);
      expect(pagesFile.existsSync(), isTrue);

      final String routesContent = routesFile.readAsStringSync();
      expect(routesContent, contains('class AppRoutes'));
      expect(routesContent, contains("static const String profilePage = '/profile';"));

      final String pagesContent = pagesFile.readAsStringSync();
      expect(pagesContent, contains('import \'package:get/get.dart\';'));
      expect(pagesContent, contains('name: AppRoutes.profilePage'));
      expect(pagesContent, contains('binding: ProfileScreenBinding()'));
      expect(pagesContent, contains('page: () => const ProfileScreen()'));
      expect(pagesContent, isNot(contains('transition')));
      expect(pagesContent, isNot(contains('transitionDuration')));
    });

    test('skips existing route constant and GetPage on second run', () {
      final SmartgenConfig config = configWithRoutes();
      PageGenerator(
        projectRoot: project,
        config: config,
        pageName: 'profile',
      ).generate();

      RouteGenerator(
        projectRoot: project,
        config: config,
        pageName: 'profile',
      ).register();

      final RouteGenerationResult second = RouteGenerator(
        projectRoot: project,
        config: config,
        pageName: 'profile',
      ).register();

      expect(second.addedCount, 0);
      expect(second.skippedCount, 2);
    });

    test('register throws when page module is missing', () {
      expect(
        () => RouteGenerator(
          projectRoot: project,
          config: configWithRoutes(),
          pageName: 'missing',
        ).register(),
        throwsA(isA<StateError>()),
      );
    });

    test('tryRegister prints message and returns null when module missing', () {
      RouteGenerationResult? result;
      expect(
        () {
          result = RouteGenerator.tryRegister(
            projectRoot: project,
            config: configWithRoutes(),
            pageName: 'missing',
          );
        },
        returnsNormally,
      );
      expect(result, isNull);
    });
  });
}
