import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:students_app/core/localization/app_language.dart';
import 'package:students_app/core/routing/app_router.dart';
import 'package:students_app/core/theme/app_theme.dart';
import 'package:students_app/features/settings/application/settings_controller.dart';
import 'package:students_app/features/todos/application/todo_controller.dart';

class ChronoStyleApp extends ConsumerWidget {
  const ChronoStyleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final router = ref.watch(appRouterProvider);
    final baseTheme = AppTheme.themeFor(settings.theme);

    // If a widget requests an edit, navigate to the todo screen
    ref.listen<int?>(pendingEditTodoIdProvider, (previous, next) {
      if (next != null) {
        debugPrint('App: pendingEditTodoId=$next → navigating to /todo');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          router.go('/todo');
        });
      }
    });

    // If a widget requests to add a task, navigate to the todo screen
    ref.listen<bool>(pendingAddTaskProvider, (previous, next) {
      if (next) {
        debugPrint('App: pendingAddTaskProvider=true → navigating to /todo');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          router.go('/todo');
        });
      }
    });

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ChronoStyle',
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.workSansTextTheme(baseTheme.textTheme),
      ),
      routerConfig: router,
      locale: settings.language.locale,
      supportedLocales: const [Locale('en'), Locale('he')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: settings.language.textDirection,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
