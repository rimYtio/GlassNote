import 'package:flutter/material.dart';

import '../../../ui_system/widgets/glass_card.dart';
import '../../../ui_system/widgets/glass_scaffold.dart';
import '../../../ui_system/widgets/glass_search_field.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim();

    return GlassScaffold(
      title: '时间线',
      body: ListView(
        children: [
          GlassSearchField(
            key: const ValueKey('timeline-search-field'),
            controller: _searchController,
            hintText: '搜索行程、提醒和待办',
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 18),
          GlassCard(
            child: Text(query.isEmpty ? '行程、提醒、待办将在下一阶段接入本地数据。' : '暂未找到相关行程'),
          ),
        ],
      ),
    );
  }
}
