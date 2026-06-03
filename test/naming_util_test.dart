import 'package:flutter_smartgen/src/utils/naming_util.dart';
import 'package:test/test.dart';

void main() {
  group('PageNaming', () {
    test('profile maps to profile_screen module and Profile classes', () {
      final PageNaming naming = PageNaming(
        inputName: 'profile',
        screenSuffix: 'Screen',
        controllerSuffix: 'Controller',
      );

      expect(naming.moduleSnake, 'profile_screen');
      expect(naming.barrelFile, 'profile.dart');
      expect(naming.viewFile, 'profile_screen.dart');
      expect(naming.screenClass, 'ProfileScreen');
      expect(naming.controllerClass, 'ProfileController');
      expect(naming.repositoryClass, 'ProfileScreenRepository');
      expect(naming.modelClass, 'ProfileModel');
    });

    test('strips _page suffix from input', () {
      final PageNaming naming = PageNaming(
        inputName: 'settings_page',
        screenSuffix: 'Screen',
        controllerSuffix: 'Controller',
      );

      expect(naming.moduleSnake, 'settings_screen');
      expect(naming.screenClass, 'SettingsScreen');
    });
  });
}
