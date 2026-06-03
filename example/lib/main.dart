import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const SmartgenExampleApp());
}

/// Empty starter app — generate config and pages with smartgen (see example/README.md).
class SmartgenExampleApp extends StatelessWidget {
  const SmartgenExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'flutter_smartgen example',
      home: const _ExampleHome(),
    );
  }
}

class _ExampleHome extends StatelessWidget {
  const _ExampleHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('smartgen example')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
            Text(
              'Run smartgen from this folder:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            Text('1. dart run flutter_smartgen:smartgen init'),
            Text('2. Edit smartgen.yaml (e.g. common_scaffold)'),
            Text('3. dart run flutter_smartgen:smartgen page demo'),
            SizedBox(height: 16),
            Text(
              'Then wire routes/bindings in main.dart and run flutter run.',
            ),
          ],
        ),
      ),
    );
  }
}
