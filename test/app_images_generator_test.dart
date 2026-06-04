import 'dart:io';

import 'package:flutter_smartgen/src/config/smartgen_config.dart';
import 'package:flutter_smartgen/src/generators/app_images_generator.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('AppImagesGenerator', () {
    late Directory project;
    late SmartgenConfig config;

    setUp(() {
      project = Directory.systemTemp.createTempSync('smartgen_app_images_test');
      Directory(p.join(project.path, 'lib')).createSync();
      Directory(p.join(project.path, 'assets', 'images')).createSync(
        recursive: true,
      );
      Directory(p.join(project.path, 'assets', 'icons')).createSync(
        recursive: true,
      );

      File(p.join(project.path, 'pubspec.yaml')).writeAsStringSync('''
name: my_app
environment:
  sdk: ^3.0.0
''');

      File(p.join(project.path, SmartgenConfig.fileName)).writeAsStringSync('''
package_name: my_app
screens_base: lib/screens
assets:
  images:
    output: lib/app/app_images.dart
    class_name: AppImages
    directories:
      - assets/images
      - assets/icons
''');

      config = SmartgenConfig.load(project);

      File(p.join(project.path, 'assets', 'images', 'ic_back.svg'))
          .writeAsStringSync('<svg></svg>');
      File(p.join(project.path, 'assets', 'icons', 'search_icon.svg'))
          .writeAsStringSync('<svg></svg>');
    });

    tearDown(() {
      if (project.existsSync()) {
        project.deleteSync(recursive: true);
      }
    });

    test('creates AppImages when output file is missing', () {
      final AppImagesGenerationResult result = AppImagesGenerator(
        projectRoot: project,
        assetsImages: config.assetsImages!,
      ).generate();

      expect(result.createdFile, isTrue);
      expect(result.addedCount, 2);

      final File output = File(p.join(project.path, 'lib/app/app_images.dart'));
      expect(output.existsSync(), isTrue);

      final String content = output.readAsStringSync();
      expect(content, contains('/// Images'));
      expect(content, contains('/// Icons'));
      expect(content, contains("static const String icBack = 'assets/images/ic_back.svg';"));
      expect(content, contains("static const String searchIcon = 'assets/icons/search_icon.svg';"));
      expect(content, isNot(contains('basePath')));
    });

    test('appends only new assets on second run', () {
      AppImagesGenerator(
        projectRoot: project,
        assetsImages: config.assetsImages!,
      ).generate();

      File(p.join(project.path, 'assets', 'icons', 'menu_icon.svg'))
          .writeAsStringSync('<svg></svg>');

      final AppImagesGenerationResult result = AppImagesGenerator(
        projectRoot: project,
        assetsImages: config.assetsImages!,
      ).generate();

      expect(result.createdFile, isFalse);
      expect(result.addedCount, 1);
      expect(result.skippedCount, 2);

      final String content = File(
        p.join(project.path, 'lib/app/app_images.dart'),
      ).readAsStringSync();

      expect(content, contains("static const String menuIcon = 'assets/icons/menu_icon.svg';"));
      expect(content.split("static const String icBack").length, 2);
    });

    test('skips when all assets already exist', () {
      AppImagesGenerator(
        projectRoot: project,
        assetsImages: config.assetsImages!,
      ).generate();

      final AppImagesGenerationResult result = AppImagesGenerator(
        projectRoot: project,
        assetsImages: config.assetsImages!,
      ).generate();

      expect(result.addedCount, 0);
      expect(result.skippedCount, 2);
      expect(result.removedCount, 0);
    });

    test('removes constants when asset files are deleted', () {
      AppImagesGenerator(
        projectRoot: project,
        assetsImages: config.assetsImages!,
      ).generate();

      File(p.join(project.path, 'assets', 'icons', 'search_icon.svg'))
          .deleteSync();

      final AppImagesGenerationResult result = AppImagesGenerator(
        projectRoot: project,
        assetsImages: config.assetsImages!,
      ).generate();

      expect(result.removedCount, 1);
      expect(result.addedCount, 0);

      final String content = File(
        p.join(project.path, 'lib/app/app_images.dart'),
      ).readAsStringSync();

      expect(content, contains("icBack = 'assets/images/ic_back.svg'"));
      expect(content, isNot(contains('searchIcon')));
    });
  });
}
