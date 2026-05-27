import 'package:flutter/material.dart';

import '../../../ui_system/widgets/glass_card.dart';
import '../../../ui_system/widgets/glass_scaffold.dart';

class AiSettingsPage extends StatelessWidget {
  const AiSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GlassScaffold(
      title: 'API 设置',
      body: GlassCard(child: Text('API Key 将通过安全存储接入，不进入普通数据库。')),
    );
  }
}
