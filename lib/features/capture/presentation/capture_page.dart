import 'package:flutter/material.dart';

import '../../../ui_system/widgets/glass_card.dart';
import '../../../ui_system/widgets/glass_scaffold.dart';

class CapturePage extends StatelessWidget {
  const CapturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: '捕获',
      actions: [
        IconButton(
          tooltip: '捕获',
          icon: const Icon(Icons.mic_none),
          onPressed: () {},
        ),
      ],
      body: ListView(
        children: const [GlassCard(child: Text('快速文字、语音和 AI 解析入口将在后续接入。'))],
      ),
    );
  }
}
