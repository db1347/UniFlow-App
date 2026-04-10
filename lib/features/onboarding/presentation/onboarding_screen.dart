import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:students_app/core/localization/app_language.dart';
import 'package:students_app/core/localization/translations.dart';
import 'package:students_app/core/providers/shared_prefs_provider.dart';
import 'package:students_app/features/settings/application/settings_controller.dart';

// ─── Degree option model ──────────────────────────────────────────────────────

class _Degree {
  const _Degree(this.labelKey, this.months);
  final String labelKey;
  final int months;
}

const _degrees = [
  _Degree('degree_ba3', 36),
  _Degree('degree_law35', 42),
  _Degree('degree_bsc4', 48),
  _Degree('degree_barch5', 60),
  _Degree('degree_medicine6', 72),
  _Degree('degree_ma2', 24),
  _Degree('degree_mba2', 24),
  _Degree('degree_phd4', 48),
];

DateTime _addMonths(DateTime d, int months) {
  final total = d.month + months;
  final yearDelta = (total - 1) ~/ 12;
  final finalMonth = ((total - 1) % 12) + 1;
  return DateTime(d.year + yearDelta, finalMonth, 1);
}

// ─── Main onboarding screen ───────────────────────────────────────────────────

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  // 0=welcome, 1=countdowns, 2=todo, 3=schedule, 4=study-setup, 5=ready
  static const _totalPages = 6;
  static const _studySetupIndex = 4;

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

    // Regular pages (study setup page is injected at index 4)
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
      // index 4 is the study-setup page (handled separately)
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
            // Skip button row
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
                  if (index == _studySetupIndex) {
                    return _StudySetupPage(l10n: l10n);
                  }
                  // Map index → pages list (study page slot shifts indices)
                  final pagesIndex = index > _studySetupIndex ? index - 1 : index;
                  return _OnboardingPage(data: pages[pagesIndex], l10n: l10n);
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

// ─── Regular onboarding page ──────────────────────────────────────────────────

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
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
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

// ─── Language picker ──────────────────────────────────────────────────────────

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
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Study setup page ─────────────────────────────────────────────────────────

class _StudySetupPage extends ConsumerStatefulWidget {
  const _StudySetupPage({required this.l10n});
  final AppLocalizations l10n;

  @override
  ConsumerState<_StudySetupPage> createState() => _StudySetupPageState();
}

class _StudySetupPageState extends ConsumerState<_StudySetupPage> {
  int? _year;
  int? _semester; // 0 = A (Oct), 1 = B (Mar)
  _Degree? _degree;

  static final _years = List.generate(
    5,
    (i) => DateTime.now().year - i,
  );

  void _tryApply() {
    if (_year == null || _semester == null || _degree == null) return;
    final month = _semester == 0 ? 10 : 3;
    final start = DateTime(_year!, month, 1);
    final end = _addMonths(start, _degree!.months);
    final notifier = ref.read(settingsControllerProvider.notifier);
    notifier.setMainStartDate(start);
    notifier.setMainTargetDate(end);
  }

  String _formatDate(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month]} ${d.year}';
  }

  DateTime? get _estimatedEnd {
    if (_year == null || _semester == null || _degree == null) return null;
    final month = _semester == 0 ? 10 : 3;
    return _addMonths(DateTime(_year!, month, 1), _degree!.months);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final theme = Theme.of(context);
    final end = _estimatedEnd;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('🎯', style: TextStyle(fontSize: 38)),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              l10n.t('onboarding_study_title'),
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              l10n.t('onboarding_study_desc'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 28),

          // ── When did you start? ──────────────────────────────────────────
          _SectionLabel(l10n.t('onboarding_start_when'), theme),
          const SizedBox(height: 10),

          // Year chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _years.map((y) {
              final sel = _year == y;
              return ChoiceChip(
                label: Text('$y'),
                selected: sel,
                onSelected: (_) {
                  setState(() => _year = y);
                  _tryApply();
                },
                selectedColor: theme.colorScheme.primary,
                labelStyle: TextStyle(
                  color: sel
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Semester chips
          Row(
            children: [
              _SemChip(
                label: l10n.t('onboarding_semester_a'),
                selected: _semester == 0,
                theme: theme,
                onTap: () {
                  setState(() => _semester = 0);
                  _tryApply();
                },
              ),
              const SizedBox(width: 10),
              _SemChip(
                label: l10n.t('onboarding_semester_b'),
                selected: _semester == 1,
                theme: theme,
                onTap: () {
                  setState(() => _semester = 1);
                  _tryApply();
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Degree type ───────────────────────────────────────────────────
          _SectionLabel(l10n.t('onboarding_degree_label'), theme),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _degrees.map((d) {
              final sel = _degree == d;
              return ChoiceChip(
                label: Text(l10n.t(d.labelKey)),
                selected: sel,
                onSelected: (_) {
                  setState(() => _degree = d);
                  _tryApply();
                },
                selectedColor: theme.colorScheme.primary,
                labelStyle: TextStyle(
                  color: sel
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),

          // ── Estimated graduation ──────────────────────────────────────────
          if (end != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.school_outlined,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.t('onboarding_graduation_estimate'),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        _formatDate(end),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, this.theme);
  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface.withOpacity(0.75),
      ),
    );
  }
}

class _SemChip extends StatelessWidget {
  const _SemChip({
    required this.label,
    required this.selected,
    required this.theme,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
