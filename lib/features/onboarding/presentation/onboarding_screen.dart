import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:students_app/core/localization/app_language.dart';
import 'package:students_app/core/localization/translations.dart';
import 'package:students_app/core/providers/shared_prefs_provider.dart';
import 'package:students_app/features/settings/application/settings_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;
  static const _totalPages = 5;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  void _complete() {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool('onboarding_complete', true);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(localizationProvider);
    final theme = Theme.of(context);

    final pages = <_PageData>[
      _PageData(
        emoji: '🎓',
        titleKey: 'onboarding_welcome_title',
        descKey: 'onboarding_welcome_subtitle',
        showLanguagePicker: true,
      ),
      _PageData(
        emoji: '⏱️',
        titleKey: 'onboarding_countdowns_title',
        descKey: 'onboarding_countdowns_desc',
      ),
      _PageData(
        emoji: '✅',
        titleKey: 'onboarding_todo_title',
        descKey: 'onboarding_todo_desc',
      ),
      _PageData(
        emoji: '📅',
        titleKey: 'onboarding_schedule_title',
        descKey: 'onboarding_schedule_desc',
      ),
      _PageData(
        emoji: '🚀',
        titleKey: 'onboarding_ready_title',
        descKey: 'onboarding_ready_desc',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top row: skip button
            SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_currentPage < _totalPages - 1)
                      TextButton(
                        onPressed: _complete,
                        child: Text(
                          l10n.t('onboarding_skip'),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _totalPages,
                itemBuilder: (context, index) {
                  final data = pages[index];
                  return _OnboardingPage(data: data, l10n: l10n);
                },
              ),
            ),

            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_totalPages, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  width: i == _currentPage ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            // Next / Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentPage < _totalPages - 1
                        ? l10n.t('onboarding_next')
                        : l10n.t('onboarding_get_started'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _PageData {
  const _PageData({
    required this.emoji,
    required this.titleKey,
    required this.descKey,
    this.showLanguagePicker = false,
  });

  final String emoji;
  final String titleKey;
  final String descKey;
  final bool showLanguagePicker;
}

class _OnboardingPage extends ConsumerWidget {
  const _OnboardingPage({required this.data, required this.l10n});

  final _PageData data;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji in a soft circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(data.emoji, style: const TextStyle(fontSize: 56)),
          ),

          const SizedBox(height: 36),

          Text(
            l10n.t(data.titleKey),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            l10n.t(data.descKey),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.65),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          if (data.showLanguagePicker) ...[
            const SizedBox(height: 36),
            _LanguagePicker(l10n: l10n),
          ],
        ],
      ),
    );
  }
}

class _LanguagePicker extends ConsumerWidget {
  const _LanguagePicker({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final notifier = ref.read(settingsControllerProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          l10n.t('onboarding_choose_language'),
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: AppLanguage.values.map((lang) {
            final selected = settings.language == lang;
            return ChoiceChip(
              label: Text(lang.displayName),
              selected: selected,
              onSelected: (_) => notifier.setLanguage(lang),
              selectedColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: selected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
