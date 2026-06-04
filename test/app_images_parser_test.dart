import 'package:flutter_smartgen/src/utils/app_images_parser.dart';
import 'package:test/test.dart';

void main() {
  group('AppImagesParser', () {
    final AppImagesParser parser = AppImagesParser();

    test('parses direct full asset paths', () {
      const String content = '''
class AppImages {
  AppImages._();

  static const String icBack = 'assets/images/ic_back.svg';
  static const String searchIcon = 'assets/icons/search_icon.svg';
}
''';

      final AppImagesParseResult result = parser.parse(content);

      expect(result.knownPaths, {
        'assets/images/ic_back.svg',
        'assets/icons/search_icon.svg',
      });
      expect(result.knownConstantNames, {'icBack', 'searchIcon'});
    });

    test('parses legacy interpolated paths using base constants', () {
      const String content = '''
class AppImages {
  AppImages._();

  static const String basePath = 'assets/images/';
  static const String baseIconPath = 'assets/images/icons/';
  static const String icBack = '\${basePath}ic_back.svg';
  static const String searchIcon = '\${baseIconPath}search_icon.svg';
}
''';

      final AppImagesParseResult result = parser.parse(content);

      expect(result.knownPaths, {
        'assets/images/ic_back.svg',
        'assets/images/icons/search_icon.svg',
      });
    });

    test('removes constants for deleted asset paths', () {
      const String content = '''
class AppImages {
  AppImages._();

  static const String icBack = 'assets/images/ic_back.svg';
  static const String searchIcon = 'assets/icons/search_icon.svg';
}
''';

      final String updated = parser.removeConstants(
        content,
        <String>{'assets/icons/search_icon.svg'},
      );

      expect(updated, contains("icBack = 'assets/images/ic_back.svg'"));
      expect(updated, isNot(contains('searchIcon')));
    });

    test('isManagedPath matches configured directories only', () {
      expect(
        AppImagesParser.isManagedPath(
          'assets/icons/search_icon.svg',
          <String>['assets/images', 'assets/icons'],
        ),
        isTrue,
      );
      expect(
        AppImagesParser.isManagedPath(
          'assets/other/foo.png',
          <String>['assets/images', 'assets/icons'],
        ),
        isFalse,
      );
    });
  });
}
