import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/capture/presentation/capture_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/notes/presentation/note_editor_page.dart';
import '../features/notes/presentation/notes_page.dart';
import '../features/schedule/presentation/schedule_page.dart';
import '../features/settings/presentation/ai_settings_page.dart';
import '../features/settings/presentation/export_settings_page.dart';
import '../features/settings/presentation/security_settings_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/settings/presentation/tag_management_page.dart';
import '../features/splash/presentation/splash_page.dart';
import '../features/trash/presentation/trash_page.dart';
import 'app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

Page<void> _transitionPage(Widget child) {
  return CustomTransitionPage<void>(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.12, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 150),
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/trash',
        pageBuilder: (context, state) => _transitionPage(const TrashPage()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/notes/new',
        pageBuilder: (context, state) => _transitionPage(
          NoteEditorPage(folderId: state.uri.queryParameters['folderId']),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/notes/:id/edit',
        pageBuilder: (context, state) => _transitionPage(
          NoteEditorPage(noteId: state.pathParameters['id']),
        ),
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
                pageBuilder: (context, state) => _transitionPage(
                  NotesPage(folderId: state.pathParameters['folderId']),
                ),
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
                pageBuilder: (context, state) =>
                    _transitionPage(const AiSettingsPage()),
              ),
              GoRoute(
                path: 'security',
                pageBuilder: (context, state) =>
                    _transitionPage(const SecuritySettingsPage()),
              ),
              GoRoute(
                path: 'export',
                pageBuilder: (context, state) =>
                    _transitionPage(const ExportSettingsPage()),
              ),
              GoRoute(
                path: 'tags',
                pageBuilder: (context, state) =>
                    _transitionPage(const TagManagementPage()),
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
