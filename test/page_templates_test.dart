import 'package:flutter_smartgen/src/config/smartgen_config.dart';
import 'package:flutter_smartgen/src/templates/page_templates.dart';
import 'package:flutter_smartgen/src/utils/naming_util.dart';
import 'package:test/test.dart';

void main() {
  group('PageTemplates', () {
    test('view uses Scaffold and SizedBox when common_scaffold absent', () {
      final SmartgenConfig config = SmartgenConfig(
        packageName: 'my_app',
        screensBase: 'lib/screens',
        naming: const NamingConfig(),
        configDirectory: '/tmp',
      );
      final PageNaming naming = PageNaming(
        inputName: 'profile',
        screenSuffix: 'Screen',
        controllerSuffix: 'Controller',
      );
      final PageTemplates templates = PageTemplates(
        config: config,
        naming: naming,
        moduleImportPath: 'screens/profile_screen',
      );

      final String view = templates.viewFile();
      expect(view, contains('return Scaffold('));
      expect(view, contains('return const SizedBox();'));
      expect(view, contains('Widget _mainBody(BuildContext context)'));
      expect(templates.controllerFile(), contains('void onInit()'));
      expect(templates.controllerFile(), isNot(contains('releaseResources')));
    });

    test('view uses CommonScaffold when configured', () {
      final SmartgenConfig config = SmartgenConfig(
        packageName: 'my_app',
        screensBase: 'lib/screens',
        naming: const NamingConfig(),
        commonScaffold: const CommonScaffoldConfig(
          import: 'package:my_app/widgets/common_scaffold.dart',
          className: 'CommonScaffold',
        ),
        configDirectory: '/tmp',
      );
      final PageNaming naming = PageNaming(
        inputName: 'profile',
        screenSuffix: 'Screen',
        controllerSuffix: 'Controller',
      );
      final PageTemplates templates = PageTemplates(
        config: config,
        naming: naming,
        moduleImportPath: 'screens/profile_screen',
      );

      final String view = templates.viewFile();
      expect(view, contains('return CommonScaffold('));
      expect(view, contains('return const SizedBox();'));
    });
  });
}
