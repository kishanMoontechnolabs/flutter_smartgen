import 'package:flutter_smartgen/src/utils/routes_parser.dart';
import 'package:test/test.dart';

void main() {
  group('RoutesParser', () {
    final RoutesParser parser = RoutesParser();

    test('parseRoutesFile finds route constants', () {
      const String content = '''
class AppRoutes {
  AppRoutes._();
  static const String homePage = '/home';
  static const String profilePage = '/profile';
}
''';

      final RoutesParseResult result = parser.parseRoutesFile(content);

      expect(result.routeConstants, hasLength(2));
      expect(result.routeConstants[0].name, 'homePage');
      expect(result.routeConstants[0].path, '/home');
      expect(result.routeConstants[1].name, 'profilePage');
      expect(result.routeConstants[1].path, '/profile');
    });

    test('parsePagesFile finds GetPage route names and imports', () {
      const String content = '''
import 'package:get/get.dart';
import 'package:my_app/router/app_routes.dart';
import 'package:my_app/screens/profile_screen/view/profile_screen.dart';

class AppPages {
  static final List<GetPage<dynamic>> getPages = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: AppRoutes.profilePage,
      binding: ProfileScreenBinding(),
      page: () => const ProfileScreen(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.settingsPage,
      binding: SettingsScreenBinding(),
      page: () => const SettingsScreen(),
    ),
  ];
}
''';

      final RoutesParseResult result = parser.parsePagesFile(content);

      expect(result.getPages, hasLength(2));
      expect(result.getPages[0].routeConstantName, 'profilePage');
      expect(result.getPages[1].routeConstantName, 'settingsPage');
      expect(
        result.existingImports,
        contains('package:my_app/screens/profile_screen/view/profile_screen.dart'),
      );
    });
  });
}
