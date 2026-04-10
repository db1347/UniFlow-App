import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:students_app/core/providers/shared_prefs_provider.dart';
import 'package:students_app/core/localization/translations.dart';

/// Shows a one-time contextual hint card below the header.
/// Once dismissed it is never shown again (stored in SharedPreferences).
class HintBanner extends ConsumerStatefulWidget {
  const HintBanner({super.key, required this.hintKey});

  /// Unique key used both to look up the translation and to persist dismissal.
  /// e.g. 'hint_todo', 'hint_timer'
  final String hintKey;

  @override
  ConsumerState<HintBanner> createState() => _HintBannerState();
}

class _HintBannerState extends ConsumerState<HintBanner>
    with SingleTickerProviderStateMixin {
  bool _visible = false;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = ref.read(sharedPreferencesProvider);
      final seen = prefs.getBool('hint_seen_${widget.hintKey}') ?? false;
      if (!seen && mounted) {
        setState(() => _visible = true);
        _animController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _dismiss() {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool('hint_seen_${widget.hintKey}', true);
    _animController.reverse().then((_) {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    final l10n = ref.watch(localizationProvider);
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.t(widget.hintKey),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.85),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _dismiss,
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
