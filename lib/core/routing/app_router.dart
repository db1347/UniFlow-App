import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:students_app/features/calendar/presentation/calendar_screen.dart';
import 'package:students_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:students_app/features/not_found/not_found_screen.dart';
import 'package:students_app/features/settings/presentation/settings_screen.dart';
import 'package:students_app/features/schedule/presentation/schedule_screen.dart';
import 'package:students_app/features/todos/presentation/todo_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: DashboardScreen()),
      ),
      GoRoute(
        path: '/todo',
        name: 'todo',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: TodoScreen()),
      ),
      GoRoute(
        path: '/calendar',
        name: 'calendar',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: CalendarScreen()),
      ),
      GoRoute(
        path: '/schedule',
        name: 'schedule',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: ScheduleScreen()),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SettingsScreen()),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
    debugLogDiagnostics: false,
  );
});
