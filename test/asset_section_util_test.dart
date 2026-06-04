import 'package:flutter_smartgen/src/utils/asset_section_util.dart';
import 'package:test/test.dart';

void main() {
  group('AssetSectionUtil', () {
    test('derives section title from directory path', () {
      expect(AssetSectionUtil.titleForDirectory('assets/images'), 'Images');
      expect(AssetSectionUtil.titleForDirectory('assets/icons'), 'Icons');
      expect(
        AssetSectionUtil.titleForDirectory('assets/onboarding'),
        'Onboarding',
      );
    });
  });
}
