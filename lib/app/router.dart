import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/capture/presentation/capture_page.dart';
import '../features/notes/presentation/note_editor_page.dart';
import '../features/notes/presentation/notes_page.dart';
import '../features/schedule/presentation/schedule_page.dart';
import '../features/settings/presentation/ai_settings_page.dart';
import '../features/settings/presentation/security_settings_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/splash/presentation/splash_page.dart';
import 'app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/capture',
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/notes/new',
        builder: (context, state) =>
            NoteEditorPage(folderId: state.uri.queryParameters['folderId']),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/notes/:id/edit',
        builder: (context, state) =>
            NoteEditorPage(noteId: state.pathParameters['id']),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/capture',
                builder: (context, state) => const CapturePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notes',
                builder: (context, state) => const NotesPage(),
                routes: [
                  GoRoute(
                    path: 'folder/:folderId',
                    builder: (context, state) =>
                        NotesPage(folderId: state.pathParameters['folderId']),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/timeline',
                builder: (context, state) => const SchedulePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
                routes: [
                  GoRoute(
                    path: 'ai',
                    builder: (context, state) => const AiSettingsPage(),
                  ),
                  GoRoute(
                    path: 'security',
                    builder: (context, state) => const SecuritySettingsPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('GlassNote')),
      body: Center(child: Text(state.error?.message ?? 'Route not found')),
    ),
  );
});
