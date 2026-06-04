import 'package:args/command_runner.dart';
import 'package:flutter_smartgen/src/utils/cli_errors.dart';
import 'package:test/test.dart';

void main() {
  group('cliErrorMessage', () {
    test('StateError returns message only', () {
      expect(
        cliErrorMessage(StateError('Page module not found.')),
        'Page module not found.',
      );
    });

    test('FormatException returns message only', () {
      expect(
        cliErrorMessage(FormatException('Invalid yaml.')),
        'Invalid yaml.',
      );
    });
  });

  group('isExpectedCliError', () {
    test('recognizes operational failures', () {
      expect(isExpectedCliError(StateError('x')), isTrue);
      expect(isExpectedCliError(FormatException('x')), isTrue);
      expect(isExpectedCliError(ArgumentError('x')), isTrue);
      expect(isExpectedCliError(Exception('x')), isFalse);
    });
  });

  group('runCommand', () {
    test('returns exit code 1 and does not throw on StateError', () async {
      final int code = await runCommand(() async {
        throw StateError('Something went wrong.');
      });

      expect(code, cliErrorExitCode);
    });

    test('rethrows UsageException', () async {
      await expectLater(
        runCommand(() async {
          throw UsageException('Missing arg.', 'usage');
        }),
        throwsA(isA<UsageException>()),
      );
    });
  });
}
