import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:students_app/core/localization/app_language.dart';
import 'package:students_app/core/localization/translations.dart';
import 'package:students_app/features/settings/application/settings_controller.dart';

class AppHeader extends ConsumerWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final translations = ref.watch(localizationProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        // Use the scaffold background (opaque) so the header doesn't
        // create a translucent band over the content below.
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              ' ',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'UniFlow',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.menu),
            color: theme.colorScheme.onSurface,
            onPressed: () => _showNavigationSheet(
              context,
              ref,
              settings.language,
              translations,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showNavigationSheet(
    BuildContext context,
    WidgetRef ref,
    AppLanguage language,
    AppLocalizations translations,
  ) {
    final alignment = language == AppLanguage.he
        ? Alignment.centerLeft
        : Alignment.centerRight;
    final items = [
      _NavItem(
        icon: Icons.timer_outlined,
        label: translations.t('timer'),
        path: '/',
      ),
      _NavItem(
        icon: Icons.calendar_today_outlined,
        label: translations.t('calendar'),
        path: '/calendar',
      ),
      _NavItem(
        icon: Icons.checklist_outlined,
        label: translations.t('todo'),
        path: '/todo',
      ),
      _NavItem(
        icon: Icons.settings_outlined,
        label: translations.t('settings'),
        path: '/settings',
      ),
    ];
    final currentLocation = GoRouterState.of(context).uri.toString();

    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: translations.t('menu'),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, __, ___) {
        final offsetTween = Tween<Offset>(
          begin: Offset(language == AppLanguage.he ? -1 : 1, 0),
          end: Offset.zero,
        );
        return Align(
          alignment: alignment,
          child: FractionallySizedBox(
            widthFactor: 0.8,
            child: SlideTransition(
              position: offsetTween.animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
              child: PopScope(
                canPop: true,
                onPopInvoked: (didPop) {
                  if (didPop) {
                    Navigator.of(context).pop();
                  }
                },
                child: Material(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            translations.t('menu'),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          for (final item in items)
                            ListTile(
                              leading: Icon(
                                item.icon,
                                color: item.path == currentLocation
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                              title: Text(item.label),
                              onTap: () {
                                Navigator.of(context).pop();
                                if (currentLocation != item.path) {
                                  context.go(item.path);
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label, required this.path});

  final IconData icon;
  final String label;
  final String path;
}
