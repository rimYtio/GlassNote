import 'package:flutter/material.dart';

import '../../../ui_system/widgets/glass_card.dart';
import '../../../ui_system/widgets/glass_scaffold.dart';

class SecuritySettingsPage extends StatelessWidget {
  const SecuritySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GlassScaffold(
      title: '安全设置',
      body: GlassCard(child: Text('当前阶段使用应用私有目录保存本地数据，并预留加密接口。')),
    );
  }
}
