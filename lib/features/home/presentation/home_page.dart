import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final routes = const [
      _HomeRoute('Notes', '/notes', Icons.note_alt_outlined),
      _HomeRoute('Folders', '/folders', Icons.folder_outlined),
      _HomeRoute('Schedule', '/schedule', Icons.timeline_outlined),
      _HomeRoute('Voice', '/voice', Icons.mic_none_outlined),
      _HomeRoute('Settings', '/settings', Icons.settings_outlined),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('GlassNote')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final route = routes[index];
          return ListTile(
            leading: Icon(route.icon),
            title: Text(route.label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(route.path),
          );
        },
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemCount: routes.length,
      ),
    );
  }
}

class _HomeRoute {
  const _HomeRoute(this.label, this.path, this.icon);

  final String label;
  final String path;
  final IconData icon;
}
