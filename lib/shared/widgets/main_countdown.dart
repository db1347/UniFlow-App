import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:students_app/core/localization/app_language.dart';
import 'package:students_app/core/localization/translations.dart';
import 'package:students_app/shared/widgets/circular_progress_ring.dart';

class MainCountdown extends ConsumerStatefulWidget {
  const MainCountdown({
    super.key,
    required this.targetDate,
    required this.startDate,
    required this.language,
    this.label,
  });

  final DateTime targetDate;
  final DateTime startDate;
  final AppLanguage language;
  final String? label;

  @override
  @override
  ConsumerState<MainCountdown> createState() => _MainCountdownState();
}

class _MainCountdownState extends ConsumerState<MainCountdown> {
  late _TimeUnit _unit = _TimeUnit.days;
  late _TimeSnapshot _snapshot = _computeSnapshot();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _snapshot = _computeSnapshot();
      });
    });
  }

  @override
  void didUpdateWidget(covariant MainCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetDate != widget.targetDate ||
        oldWidget.startDate != widget.startDate) {
      setState(() {
        _snapshot = _computeSnapshot();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  _TimeSnapshot _computeSnapshot() {
    final now = DateTime.now();
    final difference = widget.targetDate
        .difference(now)
        .clamp(Duration.zero, Duration(days: 100000));
    final totalSeconds = difference.inSeconds;
    final totalMinutes = difference.inMinutes;
    final totalHours = difference.inHours;
    final totalDays = difference.inDays;
    final totalDuration = widget.targetDate
        .difference(widget.startDate)
        .inSeconds;
    final elapsed = now.difference(widget.startDate).inSeconds;
    final progress = totalDuration <= 0
        ? 1.0
        : (elapsed / totalDuration).clamp(0, 1).toDouble();

    return _TimeSnapshot(
      days: totalDays,
      hours: totalHours,
      minutes: totalMinutes,
      seconds: totalSeconds,
      progress: progress,
    );
  }

  void _cycleUnit() {
    setState(() {
      _unit = _TimeUnit.values[(_unit.index + 1) % _TimeUnit.values.length];
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(localizationProvider);
    final localeCode = widget.language == AppLanguage.he ? 'he_IL' : 'en_GB';
    final formattedDate = DateFormat(
      'dd.MM.yyyy',
      localeCode,
    ).format(widget.targetDate);
    final value = switch (_unit) {
      _TimeUnit.days => _snapshot.days,
      _TimeUnit.hours => _snapshot.hours,
      _TimeUnit.minutes => _snapshot.minutes,
      _TimeUnit.seconds => _snapshot.seconds,
    };

    final label = switch (_unit) {
      _TimeUnit.days => value == 1 ? l10n.t('day_singular') : l10n.t('days'),
      _TimeUnit.hours => value == 1 ? l10n.t('hour_singular') : l10n.t('hours'),
      _TimeUnit.minutes =>
        value == 1 ? l10n.t('minute_singular') : l10n.t('minutes'),
      _TimeUnit.seconds =>
        value == 1 ? l10n.t('second_singular') : l10n.t('seconds'),
    };

    return GestureDetector(
      onTap: _cycleUnit,
      child: CircularProgressRing(
        progress: _snapshot.progress,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formattedDate,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: Theme.of(
                context,
              ).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            if (widget.label != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.label!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

extension on Duration {
  Duration clamp(Duration min, Duration max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }
}

class _TimeSnapshot {
  const _TimeSnapshot({
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.progress,
  });

  final int days;
  final int hours;
  final int minutes;
  final int seconds;
  final double progress;
}

enum _TimeUnit { days, hours, minutes, seconds }
