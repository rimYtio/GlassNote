import 'package:flutter/material.dart';

class PhaseOnePlaceholderPage extends StatelessWidget {
  const PhaseOnePlaceholderPage({
    required this.title,
    super.key,
    this.body = 'Phase one placeholder',
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(body)),
    );
  }
}
