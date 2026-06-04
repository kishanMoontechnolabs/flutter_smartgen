import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_smartgen/src/config/smartgen_config.dart';

/// Exit code for expected command failures (missing config, invalid input, etc.).
const int cliErrorExitCode = 1;

/// Returns a single user-facing line for expected CLI failures.
String cliErrorMessage(Object error) {
  if (error is StateError) {
    return error.message;
  }
  if (error is FormatException) {
    return error.message;
  }
  if (error is FileSystemException) {
    return error.message;
  }
  if (error is OSError) {
    return error.message;
  }
  if (error is IOException) {
    return error.toString();
  }
  if (error is ArgumentError) {
    final Object? message = error.message;
    if (message is String && message.isNotEmpty) {
      return message;
    }
  }
  return error.toString();
}

/// Writes one error line to stderr (no stack trace).
void writeCliError(Object error) {
  stderr.writeln(cliErrorMessage(error));
}

/// Whether [error] is an expected operational failure (not a bug).
bool isExpectedCliError(Object error) {
  return error is StateError ||
      error is FormatException ||
      error is IOException ||
      error is ArgumentError;
}

/// Runs [action], printing one error line and returning [cliErrorExitCode] on failure.
///
/// [UsageException] is rethrown so the runner can print usage and exit 64.
Future<int> runCommand(Future<int> Function() action) async {
  try {
    return await action();
  } on UsageException {
    rethrow;
  } on Object catch (error) {
    writeCliError(error);
    return cliErrorExitCode;
  }
}

/// Loads [SmartgenConfig] from [directory]; errors propagate to [runCommand].
SmartgenConfig loadConfigFrom(Directory directory) {
  return SmartgenConfig.load(directory);
}
