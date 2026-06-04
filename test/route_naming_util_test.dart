import 'package:flutter_smartgen/src/utils/naming_util.dart';
import 'package:flutter_smartgen/src/utils/route_naming_util.dart';
import 'package:test/test.dart';

void main() {
  group('RouteNaming', () {
    PageNaming pageNaming(String name) {
      return PageNaming(
        inputName: name,
        screenSuffix: 'Screen',
        controllerSuffix: 'Controller',
      );
    }

    test('profile -> profilePage and /profile', () {
      final RouteNaming naming = RouteNaming(
        pageNaming: pageNaming('profile'),
        routeNameSuffix: 'Page',
      );

      expect(naming.routeConstantName, 'profilePage');
      expect(naming.routePath, '/profile');
    });

    test('sign_up -> signUpPage and /sign_up', () {
      final RouteNaming naming = RouteNaming(
        pageNaming: pageNaming('sign_up'),
        routeNameSuffix: 'Page',
      );

      expect(naming.routeConstantName, 'signUpPage');
      expect(naming.routePath, '/sign_up');
    });

    test('custom route name suffix', () {
      final RouteNaming naming = RouteNaming(
        pageNaming: pageNaming('settings'),
        routeNameSuffix: 'Route',
      );

      expect(naming.routeConstantName, 'settingsRoute');
      expect(naming.routePath, '/settings');
    });
  });
}
