import 'dart:io';

import 'package:flutter_smartgen/src/config/smartgen_config.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('SmartgenConfig', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('smartgen_config_test');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('loads required fields and optional common_scaffold', () {
      File(p.join(tempDir.path, SmartgenConfig.fileName)).writeAsStringSync('''
package_name: my_app
screens_base: lib/screens
common_scaffold:
  import: package:my_app/widgets/common_scaffold.dart
  class_name: CommonScaffold
naming:
  screen_suffix: Screen
  controller_suffix: Controller
''');

      final SmartgenConfig config = SmartgenConfig.load(tempDir);

      expect(config.packageName, 'my_app');
      expect(config.screensBase, 'lib/screens');
      expect(config.commonScaffold?.className, 'CommonScaffold');
      expect(config.commonScaffold?.import,
          'package:my_app/widgets/common_scaffold.dart');
    });

    test('throws when smartgen.yaml is missing', () {
      expect(
        () => SmartgenConfig.load(tempDir),
        throwsA(isA<StateError>()),
      );
    });

    test('loads routes configuration', () {
      File(p.join(tempDir.path, SmartgenConfig.fileName)).writeAsStringSync('''
package_name: my_app
screens_base: lib/screens
routes:
  routes_file: lib/router/custom_routes.dart
  pages_file: lib/router/custom_pages.dart
  routes_class: CustomRoutes
  pages_class: CustomPages
  route_name_suffix: Route
''');

      final SmartgenConfig config = SmartgenConfig.load(tempDir);

      expect(config.routes?.routesFile, 'lib/router/custom_routes.dart');
      expect(config.routes?.pagesFile, 'lib/router/custom_pages.dart');
      expect(config.routes?.routesClass, 'CustomRoutes');
      expect(config.routes?.pagesClass, 'CustomPages');
      expect(config.routes?.routeNameSuffix, 'Route');
    });

    test('loads assets.images configuration', () {
      File(p.join(tempDir.path, SmartgenConfig.fileName)).writeAsStringSync('''
package_name: my_app
screens_base: lib/screens
assets:
  images:
    output: lib/app/app_images.dart
    class_name: AppImages
    directories:
      - assets/images
      - assets/icons
      - assets/onboarding
''');

      final SmartgenConfig config = SmartgenConfig.load(tempDir);

      expect(config.assetsImages?.className, 'AppImages');
      expect(config.assetsImages?.directories, [
        'assets/images',
        'assets/icons',
        'assets/onboarding',
      ]);
    });
  });
}
