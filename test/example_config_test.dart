import 'dart:io';
import 'dart:isolate';

import 'package:flutter_smartgen/src/commands/init_command.dart';
import 'package:flutter_smartgen/src/config/smartgen_config.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

Future<String> _repoRoot() async {
  final Uri? packageUri = await Isolate.resolvePackageUri(
    Uri.parse('package:flutter_smartgen/src/config/smartgen_config.dart'),
  );
  if (packageUri == null) {
    throw StateError('Could not resolve flutter_smartgen package URI.');
  }
  return p.normalize(
    p.join(p.dirname(packageUri.toFilePath()), '..', '..', '..'),
  );
}

void main() {
  group('example app', () {
    late String examplePath;

    setUpAll(() async {
      examplePath = p.join(await _repoRoot(), 'example');
    });

    test('does not ship smartgen.yaml (created via smartgen init)', () {
      expect(
        File(p.join(examplePath, SmartgenConfig.fileName)).existsSync(),
        isFalse,
      );
    });

    test('smartgen init works in example directory', () async {
      final Directory temp = Directory.systemTemp.createTempSync('sg_example');
      try {
        _copyExampleSkeleton(temp.path, examplePath);

        final Directory previous = Directory.current;
        Directory.current = temp;
        try {
          final int code = await InitCommand().run();
          expect(code, 0);
        } finally {
          Directory.current = previous;
        }

        final SmartgenConfig config = SmartgenConfig.load(temp);
        expect(config.packageName, 'flutter_smartgen_example');
        expect(config.assetsImages?.directories, ['assets/images']);
      } finally {
        temp.deleteSync(recursive: true);
      }
    });
  });
}

void _copyExampleSkeleton(String dest, String source) {
  Directory(p.join(dest, 'lib')).createSync(recursive: true);
  File(p.join(dest, 'pubspec.yaml')).writeAsStringSync(
    File(p.join(source, 'pubspec.yaml')).readAsStringSync(),
  );
  for (final String rel in <String>[
    'lib/main.dart',
    'lib/widgets/common_scaffold.dart',
  ]) {
    final File src = File(p.join(source, rel));
    final File out = File(p.join(dest, rel));
    out.parent.createSync(recursive: true);
    out.writeAsStringSync(src.readAsStringSync());
  }
}
