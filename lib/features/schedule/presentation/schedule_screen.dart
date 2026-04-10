import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:students_app/core/localization/translations.dart';
import 'package:students_app/features/schedule/application/schedule_controller.dart';
import 'package:students_app/features/schedule/domain/schedule_entry.dart';
import 'package:students_app/shared/widgets/app_header.dart';
import 'package:students_app/shared/widgets/bottom_nav.dart';
import 'package:students_app/shared/widgets/hint_banner.dart';

// ─── Layout constants ─────────────────────────────────────────────────────────

const _startHour = 8;
const _endHour = 22;
const _hourHeight = 56.0;
const _timeColWidth = 44.0;
const _dayColWidth = 88.0;

const _presetColors = [
  Color(0xFF2196F3),
  Color(0xFF00BCD4),
  Color(0xFF4CAF50),
  Color(0xFFFF9800),
  Color(0xFFF44336),
  Color(0xFF9C27B0),
  Color(0xFFE91E63),
  Color(0xFF795548),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  bool _weeklyView = true;
  int _selectedDay = DateTime.now().weekday % 7; // 0 = Sun

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(localizationProvider);
    final entries = ref.watch(scheduleControllerProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/');
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppHeader(),
              const HintBanner(hintKey: 'hint_schedule'),
              _Header(
                title: l10n.t('schedule'),
                weeklyView: _weeklyView,
                onToggle: (v) => setState(() => _weeklyView = v),
                l10n: l10n,
              ),
              if (!_weeklyView)
                _DaySelector(
                  selected: _selectedDay,
                  onSelect: (d) => setState(() => _selectedDay = d),
                  l10n: l10n,
                ),
              Expanded(
                child: _weeklyView
                    ? _WeeklyGrid(
                        entries: entries,
                        onTapEntry: (e) => _openSheet(entry: e),
                      )
                    : _DailyList(
                        entries: entries
                            .where((e) => e.dayOfWeek == _selectedDay)
                            .toList()
                          ..sort(
                            (a, b) =>
                                a.startMinute.compareTo(b.startMinute),
                          ),
                        onTap: (e) => _openSheet(entry: e),
                        l10n: l10n,
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openSheet(),
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: const BottomNav(),
      ),
    );
  }

  Future<void> _openSheet({ScheduleEntry? entry}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _EntrySheet(
        entry: entry,
        initialDay: _weeklyView ? 0 : _selectedDay,
        onSave: (e) {
          if (entry == null) {
            ref.read(scheduleControllerProvider.notifier).addEntry(e);
          } else {
            ref.read(scheduleControllerProvider.notifier).updateEntry(e);
          }
        },
        onDelete: entry == null
            ? null
            : () =>
                ref
                    .read(scheduleControllerProvider.notifier)
                    .deleteEntry(entry.id),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.weeklyView,
    required this.onToggle,
    required this.l10n,
  });

  final String title;
  final bool weeklyView;
  final ValueChanged<bool> onToggle;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ViewChip(
                  label: l10n.t('weekly'),
                  active: weeklyView,
                  onTap: () => onToggle(true),
                ),
                _ViewChip(
                  label: l10n.t('daily'),
                  active: !weeklyView,
                  onTap: () => onToggle(false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewChip extends StatelessWidget {
  const _ViewChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: active ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: active ? cs.onPrimary : cs.onSurfaceVariant,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ─── Day selector ─────────────────────────────────────────────────────────────

class _DaySelector extends StatelessWidget {
  const _DaySelector({
    required this.selected,
    required this.onSelect,
    required this.l10n,
  });

  final int selected;
  final ValueChanged<int> onSelect;
  final AppLocalizations l10n;

  static const _shortKeys = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 7,
        itemBuilder: (_, i) {
          final active = i == selected;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: active ? cs.primary : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                l10n.t(_shortKeys[i]),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: active ? cs.onPrimary : cs.onSurfaceVariant,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Weekly grid ─────────────────────────────────────────────────────────────

class _WeeklyGrid extends StatelessWidget {
  const _WeeklyGrid({
    required this.entries,
    required this.onTapEntry,
  });

  final List<ScheduleEntry> entries;
  final ValueChanged<ScheduleEntry> onTapEntry;

  static const _dayShort = ['א׳', 'ב׳', 'ג׳', 'ד׳', 'ה׳', 'ו׳', 'ש׳'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalHours = _endHour - _startHour;
    final gridHeight = totalHours * _hourHeight;
    final totalWidth = _timeColWidth + 7 * _dayColWidth;

    // Horizontal scroll wraps a fixed-width SizedBox so the Column inside
    // always receives bounded width constraints. Vertical scroll is handled
    // by the SingleChildScrollView inside the SizedBox.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: totalWidth,
        child: SingleChildScrollView(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header row
            Row(
              children: [
                SizedBox(width: _timeColWidth),
                ...List.generate(7, (day) {
                  final hasEntries =
                      entries.any((e) => e.dayOfWeek == day);
                  return SizedBox(
                    width: _dayColWidth,
                    height: 32,
                    child: Center(
                      child: Text(
                        _dayShort[day],
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: hasEntries
                              ? cs.primary
                              : cs.onSurface.withOpacity(0.4),
                          fontWeight: hasEntries
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            Divider(height: 1, color: cs.outline.withOpacity(0.2)),
            // Grid body
            SizedBox(
              height: gridHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time labels column
                  SizedBox(
                    width: _timeColWidth,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: List.generate(totalHours, (i) {
                        return Positioned(
                          top: i * _hourHeight - 7,
                          left: 0,
                          right: 0,
                          child: Text(
                            '${_startHour + i}:00',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: cs.onSurface.withOpacity(0.4),
                                ),
                          ),
                        );
                      }),
                    ),
                  ),
                  // Day columns
                  ...List.generate(7, (day) {
                    final dayEntries = entries
                        .where((e) => e.dayOfWeek == day)
                        .toList();
                    return SizedBox(
                      width: _dayColWidth,
                      height: gridHeight,
                      child: Stack(
                        children: [
                          // Hour lines
                          ...List.generate(
                            totalHours,
                            (i) => Positioned(
                              top: i * _hourHeight,
                              left: 0,
                              right: 0,
                              child: Divider(
                                height: 1,
                                color: cs.outline.withOpacity(0.1),
                              ),
                            ),
                          ),
                          // Entry blocks
                          ...dayEntries.map(
                            (e) => _EntryBlock(
                              entry: e,
                              onTap: () => onTapEntry(e),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
        ),  // inner SingleChildScrollView
      ),
    );
  }
}

class _EntryBlock extends StatelessWidget {
  const _EntryBlock({required this.entry, required this.onTap});

  final ScheduleEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final top = (entry.startMinute / 60 - _startHour) * _hourHeight;
    final height =
        ((entry.endMinute - entry.startMinute) / 60) * _hourHeight;
    final color = Color(entry.colorValue);

    return Positioned(
      top: top.clamp(0.0, double.infinity),
      left: 2,
      right: 2,
      height: height.clamp(18.0, double.infinity),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.85),
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              if (height > 36 && entry.location != null)
                Text(
                  entry.location!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Daily list ───────────────────────────────────────────────────────────────

class _DailyList extends StatelessWidget {
  const _DailyList({
    required this.entries,
    required this.onTap,
    required this.l10n,
  });

  final List<ScheduleEntry> entries;
  final ValueChanged<ScheduleEntry> onTap;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 56,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.t('noSchedule'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      itemCount: entries.length,
      itemBuilder: (_, i) {
        final e = entries[i];
        final color = Color(e.colorValue);
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: InkWell(
            onTap: () => onTap(e),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.title,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${e.formattedStart} – ${e.formattedEnd}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        if (e.location != null) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.5),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                e.location!,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  _TypeBadge(type: e.type, color: color, l10n: l10n),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({
    required this.type,
    required this.color,
    required this.l10n,
  });

  final ClassType type;
  final Color color;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final key = switch (type) {
      ClassType.lecture => 'lecture',
      ClassType.tutorial => 'tutorial',
      ClassType.lab => 'lab',
      ClassType.other => 'other',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        l10n.t(key),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Add / Edit sheet ─────────────────────────────────────────────────────────

class _EntrySheet extends ConsumerStatefulWidget {
  const _EntrySheet({
    this.entry,
    required this.initialDay,
    required this.onSave,
    this.onDelete,
  });

  final ScheduleEntry? entry;
  final int initialDay;
  final ValueChanged<ScheduleEntry> onSave;
  final VoidCallback? onDelete;

  @override
  ConsumerState<_EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends ConsumerState<_EntrySheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _locationCtrl;
  late int _day;
  late TimeOfDay _start;
  late TimeOfDay _end;
  late Color _color;
  late ClassType _type;

  static const _dayLabelKeys = [
    'sunday',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _locationCtrl = TextEditingController(text: e?.location ?? '');
    _day = e?.dayOfWeek ?? widget.initialDay;
    _start = e?.startTime ?? const TimeOfDay(hour: 9, minute: 0);
    _end = e?.endTime ?? const TimeOfDay(hour: 10, minute: 0);
    _color = Color(e?.colorValue ?? _presetColors.first.value);
    _type = e?.type ?? ClassType.lecture;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  int _toMin(TimeOfDay t) => t.hour * 60 + t.minute;

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(localizationProvider);
    final isEdit = widget.entry != null;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sheet title + delete
            Row(
              children: [
                Expanded(
                  child: Text(
                    isEdit ? l10n.t('editEntry') : l10n.t('addEntry'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (isEdit)
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: cs.error),
                    onPressed: () {
                      widget.onDelete?.call();
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Course name
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: l10n.t('courseName'),
                hintText: l10n.t('enterCourseName'),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),

            // Day chips
            Text(l10n.t('day'), style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (_, i) {
                  final active = i == _day;
                  return GestureDetector(
                    onTap: () => setState(() => _day = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: active ? cs.primary : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        l10n.t(_dayLabelKeys[i]),
                        style: TextStyle(
                          color:
                              active ? cs.onPrimary : cs.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight:
                              active ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Time row
            Row(
              children: [
                Expanded(
                  child: _TimeTile(
                    label: l10n.t('startTime'),
                    time: _start,
                    formatted: _fmtTime(_start),
                    onPick: (t) => setState(() {
                      _start = t;
                      if (_toMin(t) >= _toMin(_end)) {
                        _end = TimeOfDay(
                          hour: (t.hour + 1).clamp(0, 23),
                          minute: t.minute,
                        );
                      }
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimeTile(
                    label: l10n.t('endTime'),
                    time: _end,
                    formatted: _fmtTime(_end),
                    onPick: (t) => setState(() => _end = t),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Location
            TextField(
              controller: _locationCtrl,
              decoration: InputDecoration(
                labelText: l10n.t('optionalLocation'),
                hintText: l10n.t('locationHint'),
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 12),

            // Class type
            DropdownButtonFormField<ClassType>(
              value: _type,
              decoration: InputDecoration(labelText: l10n.t('classType')),
              items: ClassType.values
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(_typeLabel(t, l10n)),
                    ),
                  )
                  .toList(),
              onChanged: (v) =>
                  setState(() => _type = v ?? ClassType.lecture),
            ),
            const SizedBox(height: 12),

            // Color picker
            Text(
              l10n.t('colorLabel'),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _presetColors.map((c) {
                final selected = _color.value == c.value;
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: cs.onSurface, width: 2.5)
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Save button
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(isEdit ? l10n.t('save') : l10n.t('add')),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(ClassType t, AppLocalizations l10n) {
    return switch (t) {
      ClassType.lecture => l10n.t('lecture'),
      ClassType.tutorial => l10n.t('tutorial'),
      ClassType.lab => l10n.t('lab'),
      ClassType.other => l10n.t('other'),
    };
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) return;
    final startMin = _toMin(_start);
    final endMin = _toMin(_end);
    if (endMin <= startMin) return;

    final e = ScheduleEntry(
      id: widget.entry?.id ??
          ref.read(scheduleControllerProvider.notifier).nextId,
      title: _titleCtrl.text.trim(),
      dayOfWeek: _day,
      startMinute: startMin,
      endMinute: endMin,
      colorValue: _color.value,
      location: _locationCtrl.text.trim().isEmpty
          ? null
          : _locationCtrl.text.trim(),
      type: _type,
    );
    widget.onSave(e);
    Navigator.of(context).pop();
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.label,
    required this.time,
    required this.formatted,
    required this.onPick,
  });

  final String label;
  final TimeOfDay time;
  final String formatted;
  final ValueChanged<TimeOfDay> onPick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
        if (picked != null) onPick(picked);
      },
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.access_time, size: 18),
        ),
        child: Text(
          formatted,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
