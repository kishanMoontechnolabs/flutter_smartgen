import 'dart:io';

import 'package:flutter_smartgen/src/runner.dart';

Future<void> main(List<String> arguments) async {
  exit(await SmartGenRunner().run(arguments));
}
