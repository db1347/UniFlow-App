import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:students_app/core/constants/emoji_options.dart';
import 'package:students_app/core/localization/translations.dart';
import 'package:students_app/features/countdowns/domain/countdown.dart';
import 'package:students_app/shared/widgets/circular_progress_ring.dart';

class MiniCountdownCard extends ConsumerStatefulWidget {
  const MiniCountdownCard({
    super.key,
    required this.countdown,
    required this.onUpdated,
    required this.onDelete,
  });

  final Countdown countdown;
  final ValueChanged<Countdown> onUpdated;
  final VoidCallback onDelete;

  @override
  ConsumerState<MiniCountdownCard> createState() => _MiniCountdownCardState();
}

class _MiniCountdownCardState extends ConsumerState<MiniCountdownCard> {
  late _MiniSnapshot _snapshot = _calculateSnapshot();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {
        _snapshot = _calculateSnapshot();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  _MiniSnapshot _calculateSnapshot() {
    final now = DateTime.now();
    final daysLeft = widget.countdown.date
        .difference(now)
        .inDays
        .clamp(0, 9999);
    final totalDuration = widget.countdown.date
        .difference(widget.countdown.startDate)
        .inSeconds;
    final elapsed = now.difference(widget.countdown.startDate).inSeconds;
    final progress = totalDuration <= 0
        ? 1.0
        : (elapsed / totalDuration).clamp(0, 1).toDouble();
    return _MiniSnapshot(daysLeft: daysLeft, progress: progress);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(localizationProvider);
    final color =
        _variantColors[widget.countdown.variant] ??
        Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => _openEditSheet(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressRing(
            progress: _snapshot.progress,
            size: 90,
            strokeWidth: 5,
            color: color,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                widget.countdown.emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 120,
            child: Text(
              widget.countdown.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${_snapshot.daysLeft} ${l10n.t('days')}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditSheet(BuildContext context) async {
    final l10n = ref.read(localizationProvider);
    final nameController = TextEditingController(text: widget.countdown.title);
    DateTime targetDate = widget.countdown.date;
    DateTime startDate = widget.countdown.startDate;
    String emoji = widget.countdown.emoji;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.t('editTimer'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: l10n.t('timerTitle'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DatePickerField(
                    label: l10n.t('targetDate'),
                    initialDate: targetDate,
                    onDateSelected: (date) => targetDate = date,
                  ),
                  const SizedBox(height: 12),
                  _DatePickerField(
                    label: l10n.t('startDate'),
                    initialDate: startDate,
                    onDateSelected: (date) => startDate = date,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.t('timerEmoji'),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: emojiOptions.map((symbol) {
                      final isSelected = emoji == symbol;
                      return ChoiceChip(
                        label: Text(symbol),
                        selected: isSelected,
                        onSelected: (_) {
                          setSheetState(() => emoji = symbol);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            if (nameController.text.trim().isEmpty) return;
                            widget.onUpdated(
                              widget.countdown.copyWith(
                                title: nameController.text.trim(),
                                date: targetDate,
                                startDate: startDate,
                                emoji: emoji,
                              ),
                            );
                            Navigator.of(context).pop();
                          },
                          child: Text(l10n.t('save')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _confirmDelete(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = ref.read(localizationProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.t('deleteTimer')),
        content: Text(l10n.t('deleteTimerConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.t('delete')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      widget.onDelete();
    }
  }
}

class _MiniSnapshot {
  const _MiniSnapshot({required this.daysLeft, required this.progress});

  final int daysLeft;
  final double progress;
}

class _DatePickerField extends StatefulWidget {
  const _DatePickerField({
    required this.label,
    required this.initialDate,
    required this.onDateSelected,
  });

  final String label;
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  State<_DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<_DatePickerField> {
  late DateTime _value = widget.initialDate;

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('yyyy-MM-dd').format(_value);
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _value,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() => _value = picked);
          widget.onDateSelected(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: widget.label),
        child: Text(formatted),
      ),
    );
  }
}

const _variantColors = {
  CountdownVariant.red: Color(0xFFE11D48),
  CountdownVariant.blue: Color(0xFF3B82F6),
  CountdownVariant.gold: Color(0xFFF59E0B),
};
