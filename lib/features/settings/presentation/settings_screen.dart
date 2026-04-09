import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:students_app/core/localization/app_language.dart';
import 'package:students_app/core/localization/translations.dart';
import 'package:students_app/core/theme/app_theme.dart';
import 'package:students_app/features/settings/application/settings_controller.dart';
import 'package:students_app/shared/widgets/app_header.dart';
import 'package:students_app/shared/widgets/bottom_nav.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final l10n = ref.watch(localizationProvider);
    final themeNotifier = ref.read(settingsControllerProvider.notifier);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go('/');
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const AppHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
                  children: [
                    Text(
                      l10n.t('settings'),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.t('language'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ...AppLanguage.values.map(
                      (language) => Card(
                        child: ListTile(
                          leading: Icon(
                            settings.language == language
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                          ),
                          title: Text(language.displayName),
                          onTap: () => themeNotifier.setLanguage(language),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.t('theme'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ...ThemeType.values.map(
                      (theme) => Card(
                        child: ListTile(
                          leading: _ThemePreview(theme: theme),
                          title: Text(theme.name.toUpperCase()),
                          trailing: settings.theme == theme
                              ? const Icon(Icons.check_circle)
                              : null,
                          onTap: () => themeNotifier.setTheme(theme),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.t('mainCountdown'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _DateTile(
                      label: l10n.t('targetDate'),
                      date: settings.mainTargetDate,
                      onPressed: (date) => themeNotifier.setMainTargetDate(
                        date ?? settings.mainTargetDate,
                      ),
                    ),
                    _DateTile(
                      label: l10n.t('startDate'),
                      date: settings.mainStartDate,
                      onPressed: (date) => themeNotifier.setMainStartDate(
                        date ?? settings.mainStartDate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNav(),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.date,
    required this.onPressed,
  });

  final String label;
  final DateTime date;
  final ValueChanged<DateTime?> onPressed;

  @override
  Widget build(BuildContext context) {
    final formatted =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return Card(
      child: ListTile(
        title: Text(label),
        subtitle: Text(formatted),
        trailing: const Icon(Icons.calendar_today),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          onPressed(picked);
        },
      ),
    );
  }
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.theme});

  final ThemeType theme;

  @override
  Widget build(BuildContext context) {
    final colors = _themeSwatches[theme] ?? [Colors.white];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: colors
          .map(
            (color) => Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          )
          .toList(),
    );
  }
}

const Map<ThemeType, List<Color>> _themeSwatches = {
  ThemeType.dark: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF3B82F6)],
  ThemeType.glacier: [Color(0xFF0E7490), Color(0xFF38BDF8)],
  ThemeType.harvest: [Color(0xFF9A3412), Color(0xFFF97316)],
  ThemeType.lavender: [Color(0xFF6D28D9), Color(0xFFC084FC)],
  ThemeType.brutalist: [Color(0xFF111827), Color(0xFFE5E7EB)],
  ThemeType.obsidian: [Color(0xFF1A1B4B), Color(0xFF6366F1)],
  ThemeType.orchid: [Color(0xFF9D174D), Color(0xFFF472B6)],
  ThemeType.solar: [Color(0xFF92400E), Color(0xFFFBBF24)],
  ThemeType.tide: [Color(0xFF0F766E), Color(0xFF2DD4BF)],
  ThemeType.verdant: [Color(0xFF166534), Color(0xFF4ADE80)],
};
