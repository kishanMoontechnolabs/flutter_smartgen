import 'package:flutter/material.dart';

/// Shared scaffold used by smartgen-generated screens in this example app.
class CommonScaffold extends StatelessWidget {
  const CommonScaffold({required this.body, super.key, this.title});

  final Widget body;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null ? null : AppBar(title: Text(title!)),
      body: body,
    );
  }
}
