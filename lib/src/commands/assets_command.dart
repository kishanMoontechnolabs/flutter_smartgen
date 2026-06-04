import 'package:args/command_runner.dart';
import 'package:flutter_smartgen/src/commands/assets_images_command.dart';

/// Asset generation commands.
class AssetsCommand extends Command<int> {
  AssetsCommand() {
    addSubcommand(AssetsImagesCommand());
  }

  @override
  String get name => 'assets';

  @override
  String get description => 'Generate asset reference classes.';
}
