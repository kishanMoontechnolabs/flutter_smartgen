import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_smartgen/src/commands/assets_command.dart';
import 'package:flutter_smartgen/src/commands/env_command.dart';
import 'package:flutter_smartgen/src/commands/init_command.dart';
import 'package:flutter_smartgen/src/commands/page_command.dart';
import 'package:flutter_smartgen/src/commands/route_command.dart';
import 'package:flutter_smartgen/src/utils/cli_errors.dart';

/// Root CLI runner for smartgen.
class SmartGenRunner extends CommandRunner<int> {
  SmartGenRunner()
      : super(
          'smartgen',
          'Scaffold Flutter feature-module pages from smartgen.yaml.',
        ) {
    addCommand(InitCommand());
    addCommand(EnvCommand());
    addCommand(PageCommand());
    addCommand(RouteCommand());
    addCommand(AssetsCommand());
  }

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      return await super.run(args) ?? 0;
    } on UsageException catch (e) {
      stderr.writeln(e);
      return 64;
    } on Object catch (error) {
      if (isExpectedCliError(error)) {
        writeCliError(error);
        return cliErrorExitCode;
      }
      rethrow;
    }
  }
}
