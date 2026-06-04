import 'package:flutter_smartgen/src/utils/asset_naming_util.dart';
import 'package:test/test.dart';

void main() {
  group('AssetNamingUtil', () {
    test('converts snake_case file names to camelCase', () {
      expect(AssetNamingUtil.toConstantName('ic_back.svg'), 'icBack');
      expect(AssetNamingUtil.toConstantName('bg_dashboard.png'), 'bgDashboard');
    });

    test('appends Icon suffix for _icon file names', () {
      expect(AssetNamingUtil.toConstantName('search_icon.svg'), 'searchIcon');
      expect(AssetNamingUtil.toConstantName('menu_icon.svg'), 'menuIcon');
    });

    test('handles _icon_<digits> pattern', () {
      expect(AssetNamingUtil.toConstantName('plus_icon_2.svg'), 'plus2Icon');
    });

    test('returns unique name when collision exists', () {
      final String name = AssetNamingUtil.uniqueConstantName(
        fileName: 'search_icon.svg',
        usedNames: <String>{'searchIcon'},
      );

      expect(name, 'searchIcon_2');
    });
  });
}
