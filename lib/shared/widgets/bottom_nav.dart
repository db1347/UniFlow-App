import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:students_app/core/localization/translations.dart';

class BottomNav extends ConsumerWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(localizationProvider);
    final items = [
      _BottomNavItem(
        icon: Icons.person_outline,
        label: l10n.t('settings'),
        path: '/settings',
      ),
      _BottomNavItem(
        icon: Icons.calendar_today_outlined,
        label: l10n.t('calendar'),
        path: '/calendar',
      ),
      _BottomNavItem(
        icon: Icons.view_module_outlined,
        label: l10n.t('todo'),
        path: '/todo',
      ),
      _BottomNavItem(
        icon: Icons.timer_outlined,
        label: l10n.t('timer'),
        path: '/',
      ),
    ];

    final location = GoRouterState.of(context).uri.toString();

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          top: 8,
          left: 12,
          right: 12,
          // Clamp the bottom inset so the nav doesn't become too tall on
          // devices with large system insets. Keep a small extra offset.
          bottom: MediaQuery.of(context).viewPadding.bottom.clamp(0.0, 12.0) + 6,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((item) {
            final isActive = location == item.path;
            final color = isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (!isActive) {
                    context.go(item.path);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, color: color),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(color: color),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _BottomNavItem {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.path,
  });

  final IconData icon;
  final String label;
  final String path;
}
