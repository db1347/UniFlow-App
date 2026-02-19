import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:students_app/core/localization/translations.dart';
import 'package:students_app/core/utils/color_utils.dart';
import 'package:students_app/features/countdowns/application/countdown_controller.dart';
import 'package:students_app/features/countdowns/domain/countdown.dart';
import 'package:students_app/features/events/application/event_controller.dart';
import 'package:students_app/features/events/domain/calendar_event.dart';
import 'package:students_app/features/todos/application/todo_controller.dart';
import 'package:students_app/features/todos/domain/task.dart';
import 'package:students_app/shared/widgets/app_header.dart';
import 'package:students_app/shared/widgets/bottom_nav.dart';

enum CalendarViewMode { day, week, month }

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarViewMode _viewMode = CalendarViewMode.month;
  DateTime _currentDate = DateTime.now();
  bool _fabExpanded = false;
  OverlayEntry? _dayPreviewEntry;
  ValueNotifier<bool>? _dayPreviewVisible;
  int _dayPreviewToken = 0;
  final int _initialPage =
      1000; // Start in the middle to allow scrolling both ways
  late final PageController _pageController = PageController(
    initialPage: _initialPage,
  );

  // Event form state
  // Semester plan state
  final List<_SemesterClass> _semesterClasses = [];
  DateTime? _semesterEndDate;

  @override
  void dispose() {
    _hideDayPreview(immediate: true);
    _pageController.dispose();
    super.dispose();
  }

  void _hideDayPreview({bool immediate = false}) {
    if (_dayPreviewEntry == null) return;

    final token = _dayPreviewToken;
    _dayPreviewVisible?.value = false;

    if (immediate) {
      _dayPreviewEntry?.remove();
      _dayPreviewEntry = null;
      _dayPreviewVisible?.dispose();
      _dayPreviewVisible = null;
      return;
    }

    Future.delayed(const Duration(milliseconds: 320), () {
      if (_dayPreviewToken != token) return;
      _dayPreviewEntry?.remove();
      _dayPreviewEntry = null;
      _dayPreviewVisible?.dispose();
      _dayPreviewVisible = null;
    });
  }

  void _showDayPreview({
    required BuildContext cellContext,
    required DateTime day,
    required List<_CalendarItem> items,
    required AppLocalizations l10n,
  }) {
    _dayPreviewToken++;
    _hideDayPreview(immediate: true);
    final overlay = Overlay.of(cellContext);
    if (overlay == null) return;

    final box = cellContext.findRenderObject() as RenderBox?;
    if (box == null) return;

    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    final overlaySize = overlayBox?.size ?? MediaQuery.of(cellContext).size;

    final double maxWidth = (overlaySize.width - 24).clamp(200.0, 320.0);
    final double maxHeight = (overlaySize.height * 0.4).clamp(160.0, 320.0);
    final double width = maxWidth;

    double left = offset.dx + (size.width / 2) - (width / 2);
    left = left.clamp(12.0, overlaySize.width - width - 12.0);

    double top = offset.dy - maxHeight - 8;
    if (top < 12.0) {
      top = offset.dy + size.height + 8;
    }

    final title = DateFormat.MMMd(
      Localizations.localeOf(cellContext).toLanguageTag(),
    ).format(day);

    _dayPreviewVisible = ValueNotifier<bool>(false);

    final popupChild = Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(cellContext).colorScheme.surface,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  cellContext,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (items.isEmpty)
                Text(
                  l10n.t('noEvents'),
                  style: Theme.of(cellContext).textTheme.bodySmall,
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final meta = <String>[];
                      if (item.time != null) {
                        meta.add(item.time!);
                      }
                      if (item.durationLabel != null) {
                        meta.add(item.durationLabel!);
                      }
                      if (item.repeatLabel != null) {
                        meta.add(item.repeatLabel!);
                      }
                      final metaText = meta.isEmpty ? null : meta.join(' • ');

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(
                              color: item.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                if (metaText != null)
                                  Text(
                                    metaText,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    _dayPreviewEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: left,
        top: top,
        width: width,
        child: ValueListenableBuilder<bool>(
          valueListenable: _dayPreviewVisible!,
          builder: (context, visible, child) => AnimatedOpacity(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOut,
            opacity: visible ? 1 : 0,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutBack,
              scale: visible ? 1 : 0.96,
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
          child: popupChild,
        ),
      ),
    );

    overlay.insert(_dayPreviewEntry!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dayPreviewVisible?.value = true;
    });
  }

  DateTime _getDateForPage(int page) {
    final offset = page - _initialPage;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_viewMode) {
      case CalendarViewMode.day:
        return today.add(Duration(days: offset));
      case CalendarViewMode.week:
        return today.add(Duration(days: offset * 7));
      case CalendarViewMode.month:
        return DateTime(now.year, now.month + offset, 1);
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentDate = _getDateForPage(page);
    });
  }

  int _getPageForDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    switch (_viewMode) {
      case CalendarViewMode.day:
        final daysDiff = targetDate.difference(today).inDays;
        return _initialPage + daysDiff;
      case CalendarViewMode.week:
        final weeksDiff = targetDate.difference(today).inDays ~/ 7;
        return _initialPage + weeksDiff;
      case CalendarViewMode.month:
        final monthsDiff =
            (date.year - now.year) * 12 + (date.month - now.month);
        return _initialPage + monthsDiff;
    }
  }

  void _jumpToDate(DateTime date) {
    setState(() {
      _currentDate = date;
    });
    final targetPage = _getPageForDate(date);
    _pageController.jumpToPage(targetPage);
  }

  @override
  Widget build(BuildContext context) {
    final countdowns = ref.watch(countdownControllerProvider);
    final todos = ref.watch(todoControllerProvider);
    final events = ref.watch(eventControllerProvider);
    final l10n = ref.watch(localizationProvider);
    final media = MediaQuery.of(context);
    final double fabExtra = _fabExpanded ? 160.0 : 96.0;
    // Keep outer padding modest so the calendar has enough vertical space.
    // The GridView itself has bottom padding to keep cells visible above
    // the FAB and bottom navigation, so we only need a small outer gap here.
    final double bottomPad = (16.0 + media.viewPadding.bottom + 8.0).clamp(
      12.0,
      media.size.height * 0.2,
    );
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
                child: Stack(
                  children: [
                    // Dynamic bottom padding is computed above to avoid hardcoding a value
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
                      child: Column(
                        children: [
                          _ViewModeSelector(
                            viewMode: _viewMode,
                            l10n: l10n,
                            onChanged: (mode) {
                              setState(() => _viewMode = mode);
                              // Reset to middle page when changing view mode
                              _pageController.jumpToPage(_initialPage);
                            },
                          ),
                          const SizedBox(height: 16),
                          _NavigationHeader(
                            currentDate: _currentDate,
                            viewMode: _viewMode,
                            l10n: l10n,
                            onPrevious: _goToPrevious,
                            onNext: _goToNext,
                            onToday: () {
                              setState(() => _currentDate = DateTime.now());
                              // Reset to middle page when going to today
                              _pageController.jumpToPage(_initialPage);
                            },
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              onPageChanged: _onPageChanged,
                              itemBuilder: (context, index) {
                                final pageDate = _getDateForPage(index);
                                return _buildContent(
                                  context: context,
                                  l10n: l10n,
                                  countdowns: countdowns,
                                  tasks: todos.tasks,
                                  events: events,
                                  date: pageDate,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 24,
                      bottom: 24,
                      child: _FabMenu(
                        expanded: _fabExpanded,
                        onToggle: () =>
                            setState(() => _fabExpanded = !_fabExpanded),
                        onAddEvent: () {
                          setState(() => _fabExpanded = false);
                          _openCreateEvent();
                        },
                        onPlanSemester: () {
                          setState(() => _fabExpanded = false);
                          _openSemesterPlanner();
                        },
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

  DateTime? _parseIcsDateSimple(String raw) {
    final s = raw.trim();
    try {
      if (s.contains('T')) {
        final parts = s.split('T');
        final datePart = parts[0];
        var timePart = parts[1];
        timePart = timePart.replaceAll(RegExp(r'Z|\+.*|-.*'), '');
        if (datePart.length >= 8 && timePart.length >= 4) {
          final year = int.parse(datePart.substring(0, 4));
          final month = int.parse(datePart.substring(4, 6));
          final day = int.parse(datePart.substring(6, 8));
          final hour = int.parse(timePart.substring(0, 2));
          final minute = int.parse(timePart.substring(2, 4));
          final second = timePart.length >= 6
              ? int.parse(timePart.substring(4, 6))
              : 0;
          return DateTime(year, month, day, hour, minute, second);
        }
      } else if (RegExp(r'^\d{8} ?$').hasMatch(s) || s.length == 8) {
        final year = int.parse(s.substring(0, 4));
        final month = int.parse(s.substring(4, 6));
        final day = int.parse(s.substring(6, 8));
        return DateTime(year, month, day);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  void _goToPrevious() {
    if (_pageController.hasClients) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildContent({
    required BuildContext context,
    required AppLocalizations l10n,
    required List<Countdown> countdowns,
    required List<Task> tasks,
    required List<CalendarEvent> events,
    required DateTime date,
  }) {
    switch (_viewMode) {
      case CalendarViewMode.day:
        return _buildDayView(
          context: context,
          date: date,
          countdowns: countdowns,
          tasks: tasks,
          events: events,
          l10n: l10n,
        );
      case CalendarViewMode.week:
        return _buildWeekView(
          context: context,
          date: date,
          countdowns: countdowns,
          tasks: tasks,
          l10n: l10n,
        );
      case CalendarViewMode.month:
        return _buildMonthView(
          context: context,
          date: date,
          countdowns: countdowns,
          tasks: tasks,
          l10n: l10n,
        );
    }
  }

  Widget _buildDayView({
    required BuildContext context,
    required DateTime date,
    required List<Countdown> countdowns,
    required List<Task> tasks,
    required List<CalendarEvent> events,
    required AppLocalizations l10n,
  }) {
    final items = _itemsForDate(
      date: date,
      countdowns: countdowns,
      tasks: tasks,
      context: context,
      l10n: l10n,
    );
    final eventMap = {for (final event in events) event.id: event};

    if (items.isEmpty) {
      return Center(
        child: Text(
          l10n.t('noEvents'),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            if (item.eventId != null && eventMap[item.eventId] != null) {
              _openEditEvent(eventMap[item.eventId]!);
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: item.color.withOpacity(0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.icon, color: item.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              decoration: item.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          if (item.time != null)
                            _InfoChip(label: item.time!, color: item.color),
                          if (item.durationLabel != null)
                            _InfoChip(
                              label: item.durationLabel!,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          _InfoChip(
                            label: l10n.t(item.typeLabel),
                            color: item.color,
                          ),
                          if (item.repeatLabel != null)
                            _InfoChip(
                              label: item.repeatLabel!,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Add timer button for calendar events
                if (item.eventId != null && item.typeLabel == 'calendar')
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: IconButton(
                      icon: const Icon(Icons.timer_outlined),
                      onPressed: () {
                        final event = eventMap[item.eventId];
                        if (event != null) {
                          final countdownNotifier = ref.read(
                            countdownControllerProvider.notifier,
                          );
                          countdownNotifier.addCountdown(
                            title: event.title,
                            targetDate: event.date,
                            startDate: DateTime.now(),
                            emoji: '⏱️',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.t('timerAdded')),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      tooltip: l10n.t('addAsTimer'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeekView({
    required BuildContext context,
    required DateTime date,
    required List<Countdown> countdowns,
    required List<Task> tasks,
    required AppLocalizations l10n,
  }) {
    final start = _startOfWeek(date);
    final days = List.generate(7, (index) => start.add(Duration(days: index)));
    final hours = List.generate(18, (index) => 5 + index);
    const cellHeight = 56.0;
    final columnHeight = hours.length * cellHeight;

    final eventNotifier = ref.read(eventControllerProvider.notifier);

    return Column(
      children: [
        Row(
          children: days.map((day) {
            final isToday = _isSameDay(day, DateTime.now());
            final label = DateFormat.E().format(day);
            final number = DateFormat.d().format(day);
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  _viewMode = CalendarViewMode.day;
                  _jumpToDate(day);
                },
                child: Column(
                  children: [
                    Text(label, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isToday
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                      ),
                      child: Text(
                        number,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isToday
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 48,
                  child: Column(
                    children: hours
                        .map(
                          (hour) => SizedBox(
                            height: cellHeight,
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Text('$hour:00'),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                ...days.map((day) {
                  final eventsForDay = eventNotifier
                      .eventsForDate(day)
                      .where((event) => event.time != null)
                      .toList();
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (details) {
                        final offset = details.localPosition.dy.clamp(
                          0,
                          columnHeight,
                        );
                        final hour = 5 + (offset ~/ cellHeight);
                        _openCreateEvent(date: day, initialHour: hour);
                      },
                      child: SizedBox(
                        height: columnHeight,
                        child: Stack(
                          children: [
                            ...List.generate(
                              hours.length,
                              (index) => Positioned(
                                top: index * cellHeight,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: cellHeight,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.1),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ...eventsForDay.map((event) {
                              final startHour = _hourFromString(event.time!);
                              final durationHours = (event.duration / 60)
                                  .clamp(1, 8)
                                  .toDouble();
                              final top = (startHour - 5) * cellHeight;
                              return Positioned(
                                top: top,
                                left: 4,
                                right: 4,
                                height: durationHours * cellHeight,
                                child: GestureDetector(
                                  onTap: () => _openEditEvent(event),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: colorFromHex(event.colorHex),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      event.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthView({
    required BuildContext context,
    required DateTime date,
    required List<Countdown> countdowns,
    required List<Task> tasks,
    required AppLocalizations l10n,
  }) {
    final firstDay = DateTime(date.year, date.month, 1);
    final start = firstDay.subtract(Duration(days: firstDay.weekday % 7));
    // Show a fixed 5-week (35-day) month view to keep the month
    // layout consistent and prevent a sixth week from appearing.
    final totalDays = 35;
    final days = List.generate(
      totalDays,
      (index) => start.add(Duration(days: index)),
    );

    return Column(
      children: [
        Row(
          children: _weekDays(l10n)
              .map(
                (label) => Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        // Use LayoutBuilder to compute a childAspectRatio so 5 rows fit the
        // available space and are fully visible without scrolling.
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Fixed 5-row grid (no sixth week). Keep layout simple
              // and non-scrollable so the month always occupies the same
              // vertical space.
              const int rows = 5;
              const double spacing = 8.0;
              final double totalVerticalSpacing = (rows - 1) * spacing;

              // Recompute media/fabExtra locally so the grid has bottom
              // padding large enough to avoid being obscured by the FAB
              // or bottom navigation.
              final media = MediaQuery.of(context);
              final double fabExtra = _fabExpanded ? 160.0 : 96.0;

              final double cellHeight =
                  (constraints.maxHeight - totalVerticalSpacing) / rows;

              final double totalHorizontalSpacing = (7 - 1) * spacing;
              final double cellWidth =
                  (constraints.maxWidth - totalHorizontalSpacing) / 7;
              final double childAspectRatio = cellWidth / cellHeight;

              final Widget grid = GridView.builder(
                padding: EdgeInsets.only(
                  bottom:
                      fabExtra +
                      media.viewPadding.bottom +
                      kBottomNavigationBarHeight +
                      40,
                ),
                // Non-scrollable fixed grid
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];

                  final isToday = _isSameDay(day, DateTime.now());
                  final inMonth = day.month == date.month;
                  final items = _itemsForDate(
                    date: day,
                    countdowns: countdowns,
                    tasks: tasks,
                    context: context,
                    l10n: l10n,
                  );
                  return Builder(
                    builder: (cellContext) => GestureDetector(
                      onTap: () {
                        _viewMode = CalendarViewMode.day;
                        _jumpToDate(day);
                      },
                      onLongPressStart: (_) => _showDayPreview(
                        cellContext: cellContext,
                        day: day,
                        items: items,
                        l10n: l10n,
                      ),
                      onLongPressEnd: (_) => _hideDayPreview(),
                      onLongPressCancel: _hideDayPreview,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isToday
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).colorScheme.outline.withOpacity(0.2),
                          ),
                          color: inMonth
                              ? Theme.of(context).colorScheme.surface
                              : Theme.of(
                                  context,
                                ).colorScheme.surface.withOpacity(0.5),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${day.day}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            // Use a small fixed gap + a Flexible container for the dots
                            // so they can shrink if the available height is very small
                            // and avoid tiny pixel overflow due to rounding.
                            const SizedBox(height: 2),
                            Flexible(
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Wrap(
                                  spacing: 2,
                                  runSpacing: 2,
                                  children: items
                                      .take(3)
                                      .map(
                                        (item) => Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: item.color,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );

              return grid;
            },
          ),
        ),
      ],
    );
  }

  void _openCreateEvent({DateTime? date, int? initialHour}) {
    final l10n = ref.read(localizationProvider);
    final controller = ref.read(eventControllerProvider.notifier);
    final titleController = TextEditingController();
    DateTime selectedDate = date ?? _currentDate;
    TimeOfDay selectedTime = TimeOfDay(hour: initialHour ?? 9, minute: 0);
    int duration = 60;
    EventRepeat repeat = EventRepeat.none;
    Color color = _colorOptions.first.color;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom:
              math.max(
                MediaQuery.of(context).viewInsets.bottom,
                MediaQuery.of(context).viewPadding.bottom,
              ) +
              16,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.t('createEvent'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: l10n.t('eventTitle')),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.t('targetDate')),
                  subtitle: Text(
                    '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setSheetState(() => selectedDate = picked);
                      }
                    },
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.t('time')),
                  subtitle: Text(selectedTime.format(context)),
                  trailing: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setSheetState(() => selectedTime = picked);
                      }
                    },
                  ),
                ),
                DropdownButtonFormField<int>(
                  value: duration,
                  decoration: InputDecoration(labelText: l10n.t('duration')),
                  onChanged: (value) =>
                      setSheetState(() => duration = value ?? 60),
                  items: _durationOptions.entries
                      .map(
                        (entry) => DropdownMenuItem<int>(
                          value: entry.key,
                          child: Text(entry.value(l10n)),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<EventRepeat>(
                  value: repeat,
                  decoration: InputDecoration(labelText: l10n.t('recurrence')),
                  onChanged: (value) =>
                      setSheetState(() => repeat = value ?? EventRepeat.none),
                  items: EventRepeat.values
                      .map(
                        (value) => DropdownMenuItem<EventRepeat>(
                          value: value,
                          child: Text(_repeatLabel(value, l10n)),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.t('color'),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                Wrap(
                  spacing: 12,
                  children: _colorOptions.map((option) {
                    final isSelected = option.color == color;
                    return GestureDetector(
                      onTap: () => setSheetState(() => color = option.color),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: option.color,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onSurface
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      return;
                    }
                    final event = CalendarEvent(
                      id: DateTime.now().millisecondsSinceEpoch,
                      title: titleController.text.trim(),
                      date: DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                      ),
                      time:
                          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                      duration: duration,
                      repeat: repeat,
                      colorHex: hexFromColor(color),
                    );
                    controller.addEvent(event);
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.t('create')),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _importIcsFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ics'],
      );
      if (result == null) return;
      final path = result.files.single.path;
      if (path == null) return;
      final file = File(path);
      final content = await file.readAsString();

      final matches = RegExp(
        r'BEGIN:VEVENT[\s\S]*?END:VEVENT',
        multiLine: true,
        caseSensitive: false,
      ).allMatches(content);
      if (matches.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No events found in .ics file')),
        );
        return;
      }

      final controller = ref.read(eventControllerProvider.notifier);
      var imported = 0;
      var index = 0;
      for (final m in matches) {
        final block = m.group(0) ?? '';
        final summaryMatch = RegExp(
          r'SUMMARY:(.*)$',
          multiLine: true,
        ).firstMatch(block);
        final dtStartMatch = RegExp(
          r'DTSTART(?:;[^:]+)?:([0-9TzZ+-]+)$',
          multiLine: true,
          caseSensitive: false,
        ).firstMatch(block);
        final dtEndMatch = RegExp(
          r'DTEND(?:;[^:]+)?:([0-9TzZ+-]+)$',
          multiLine: true,
          caseSensitive: false,
        ).firstMatch(block);
        final durationMatch = RegExp(
          r'DURATION:(.*)$',
          multiLine: true,
        ).firstMatch(block);

        final title = summaryMatch?.group(1)?.trim() ?? 'Event';
        final dtStartRaw = dtStartMatch?.group(1);
        if (dtStartRaw == null) continue;
        DateTime? start = _parseIcsDateSimple(dtStartRaw);
        if (start == null) continue;

        int durationMinutes = 60;
        if (dtEndMatch?.group(1) != null) {
          final end = _parseIcsDateSimple(dtEndMatch!.group(1)!);
          if (end != null) {
            durationMinutes = end.difference(start).inMinutes.clamp(15, 8 * 60);
          }
        } else if (durationMatch?.group(1) != null) {
          final d = durationMatch!.group(1)!;
          final p = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?').firstMatch(d);
          if (p != null) {
            final hrs = int.tryParse(p.group(1) ?? '0') ?? 0;
            final mins = int.tryParse(p.group(2) ?? '0') ?? 0;
            durationMinutes = (hrs * 60 + mins).clamp(15, 8 * 60);
          }
        }

        final dateOnly = DateTime(start.year, start.month, start.day);
        final timeStr =
            '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';

        final color = _colorOptions[index % _colorOptions.length].color;

        final event = CalendarEvent(
          id: DateTime.now().millisecondsSinceEpoch + index,
          title: title,
          date: dateOnly,
          time: timeStr,
          duration: durationMinutes,
          colorHex: hexFromColor(color),
        );
        controller.addEvent(event);
        imported++;
        index++;
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Imported $imported events')));
      setState(() {});
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }

  DateTime? _parseIcsDate(String raw) {
    // Examples: 20251224T130000Z  or 20251224T130000 or 20251224
    final s = raw.trim();
    try {
      if (s.contains('T')) {
        final parts = s.split('T');
        final datePart = parts[0];
        var timePart = parts[1];
        // strip trailing Z or timezone offsets
        timePart = timePart.replaceAll(RegExp(r'Z|\+.*|-.*'), '');
        final year = int.parse(datePart.substring(0, 4));
        final month = int.parse(datePart.substring(4, 6));
        final day = int.parse(datePart.substring(6, 8));
        final hour = int.parse(timePart.substring(0, 2));
        final minute = int.parse(timePart.substring(2, 4));
        final second = timePart.length >= 6
            ? int.parse(timePart.substring(4, 6))
            : 0;
        return DateTime(year, month, day, hour, minute, second);
      } else if (RegExp(r'^\d{8} $').hasMatch(s) ||
          RegExp(r'^\d{8} ').hasMatch(s) ||
          RegExp(r'^\d{8} \r?\n? ').hasMatch(s)) {
        // fallback: attempt to parse 8-digit date (YYYYMMDD)
        if (s.length >= 8) {
          final year = int.parse(s.substring(0, 4));
          final month = int.parse(s.substring(4, 6));
          final day = int.parse(s.substring(6, 8));
          return DateTime(year, month, day);
        }
      } else if (RegExp(r'^\d{8} ?').hasMatch(s)) {
        if (s.length >= 8) {
          final year = int.parse(s.substring(0, 4));
          final month = int.parse(s.substring(4, 6));
          final day = int.parse(s.substring(6, 8));
          return DateTime(year, month, day);
        }
      } else if (RegExp(r'^\d{8} ').hasMatch(s) == false && s.length == 8) {
        final year = int.parse(s.substring(0, 4));
        final month = int.parse(s.substring(4, 6));
        final day = int.parse(s.substring(6, 8));
        return DateTime(year, month, day);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  void _openEditEvent(CalendarEvent event) {
    final l10n = ref.read(localizationProvider);
    final controller = ref.read(eventControllerProvider.notifier);
    final titleController = TextEditingController(text: event.title);
    DateTime selectedDate = event.date;
    TimeOfDay selectedTime = _timeOfDayFromString(event.time ?? '09:00');
    int duration = event.duration;
    EventRepeat repeat = event.repeat;
    Color color = colorFromHex(event.colorHex);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom:
              math.max(
                MediaQuery.of(context).viewInsets.bottom,
                MediaQuery.of(context).viewPadding.bottom,
              ) +
              16,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.t('editTimer'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: l10n.t('eventTitle')),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.t('targetDate')),
                  subtitle: Text(
                    '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setSheetState(() => selectedDate = picked);
                      }
                    },
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.t('time')),
                  subtitle: Text(selectedTime.format(context)),
                  trailing: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setSheetState(() => selectedTime = picked);
                      }
                    },
                  ),
                ),
                DropdownButtonFormField<int>(
                  value: duration,
                  decoration: InputDecoration(labelText: l10n.t('duration')),
                  onChanged: (value) =>
                      setSheetState(() => duration = value ?? 60),
                  items: _durationOptions.entries
                      .map(
                        (entry) => DropdownMenuItem<int>(
                          value: entry.key,
                          child: Text(entry.value(l10n)),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<EventRepeat>(
                  value: repeat,
                  decoration: InputDecoration(labelText: l10n.t('recurrence')),
                  onChanged: (value) =>
                      setSheetState(() => repeat = value ?? EventRepeat.none),
                  items: EventRepeat.values
                      .map(
                        (value) => DropdownMenuItem<EventRepeat>(
                          value: value,
                          child: Text(_repeatLabel(value, l10n)),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: _colorOptions.map((option) {
                    final isSelected = option.color == color;
                    return GestureDetector(
                      onTap: () => setSheetState(() => color = option.color),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: option.color,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onSurface
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (titleController.text.trim().isEmpty) return;
                          controller.updateEvent(
                            event.id,
                            event.copyWith(
                              title: titleController.text.trim(),
                              date: selectedDate,
                              time:
                                  '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                              duration: duration,
                              repeat: repeat,
                              colorHex: hexFromColor(color),
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
                        _confirmDeleteEvent(event.id);
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _confirmDeleteEvent(int id) {
    final l10n = ref.read(localizationProvider);
    final controller = ref.read(eventControllerProvider.notifier);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.t('deleteTimer')),
        content: Text(l10n.t('deleteTimerConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.t('cancel')),
          ),
          FilledButton(
            onPressed: () {
              controller.deleteEvent(id);
              Navigator.of(context).pop();
            },
            child: Text(l10n.t('delete')),
          ),
        ],
      ),
    );
  }

  void _openSemesterPlanner() {
    final l10n = ref.read(localizationProvider);
    final controller = ref.read(eventControllerProvider.notifier);
    final classNameController = TextEditingController();
    ClassType classType = ClassType.lecture;
    int dayIndex = 0;
    TimeOfDay classTime = const TimeOfDay(hour: 9, minute: 0);
    int duration = 60;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom:
              math.max(
                MediaQuery.of(context).viewInsets.bottom,
                MediaQuery.of(context).viewPadding.bottom,
              ) +
              16,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('semesterSchedule'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.t('semesterEndDate')),
                  subtitle: Text(
                    _semesterEndDate == null
                        ? '-'
                        : '${_semesterEndDate!.year}-${_semesterEndDate!.month.toString().padLeft(2, '0')}-${_semesterEndDate!.day.toString().padLeft(2, '0')}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _semesterEndDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setSheetState(() => _semesterEndDate = picked);
                      }
                    },
                  ),
                ),
                TextField(
                  controller: classNameController,
                  decoration: InputDecoration(labelText: l10n.t('className')),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ClassType>(
                  value: classType,
                  decoration: InputDecoration(labelText: l10n.t('classType')),
                  onChanged: (value) => setSheetState(
                    () => classType = value ?? ClassType.lecture,
                  ),
                  items: ClassType.values
                      .map(
                        (type) => DropdownMenuItem<ClassType>(
                          value: type,
                          child: Text(_classTypeLabel(type, l10n)),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: dayIndex,
                  decoration: InputDecoration(labelText: l10n.t('dayOfWeek')),
                  onChanged: (value) =>
                      setSheetState(() => dayIndex = value ?? 0),
                  items: _weekDays(l10n)
                      .mapIndexed(
                        (index, value) => DropdownMenuItem<int>(
                          value: index,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.t('time')),
                  subtitle: Text(classTime.format(context)),
                  trailing: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: classTime,
                      );
                      if (picked != null) {
                        setSheetState(() => classTime = picked);
                      }
                    },
                  ),
                ),
                DropdownButtonFormField<int>(
                  value: duration,
                  decoration: InputDecoration(labelText: l10n.t('duration')),
                  onChanged: (value) =>
                      setSheetState(() => duration = value ?? 60),
                  items: const [45, 60, 90, 120, 180]
                      .map(
                        (minutes) => DropdownMenuItem<int>(
                          value: minutes,
                          child: Text('$minutes min'),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    if (classNameController.text.trim().isEmpty) return;
                    final cls = _SemesterClass(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: classNameController.text.trim(),
                      type: classType,
                      day: dayIndex,
                      time: classTime,
                      duration: duration,
                    );
                    setSheetState(() {
                      _semesterClasses.add(cls);
                      classNameController.clear();
                      classType = ClassType.lecture;
                      dayIndex = 0;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add),
                      const SizedBox(width: 8),
                      Text(l10n.t('addClass')),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (_semesterClasses.isNotEmpty)
                  SizedBox(
                    height: min(200, _semesterClasses.length * 72),
                    child: ListView.builder(
                      itemCount: _semesterClasses.length,
                      itemBuilder: (context, index) {
                        final cls = _semesterClasses[index];
                        return ListTile(
                          title: Text(cls.name),
                          subtitle: Text(
                            '${_weekDays(l10n)[cls.day]} · ${cls.time.format(context)}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => setSheetState(
                              () => _semesterClasses.removeAt(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.file_open),
                        label: const Text('Import .ICS'),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _importIcsFile(context);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed:
                      _semesterEndDate == null || _semesterClasses.isEmpty
                      ? null
                      : () {
                          final endDate = _semesterEndDate!;
                          for (final cls in _semesterClasses) {
                            var nextDate = _nextWeekday(
                              DateTime.now(),
                              cls.day,
                            );
                            while (!nextDate.isAfter(endDate)) {
                              controller.addEvent(
                                CalendarEvent(
                                  id: DateTime.now()
                                      .add(Duration(milliseconds: cls.hashCode))
                                      .millisecondsSinceEpoch,
                                  title: cls.name,
                                  date: DateTime(
                                    nextDate.year,
                                    nextDate.month,
                                    nextDate.day,
                                  ),
                                  time:
                                      '${cls.time.hour.toString().padLeft(2, '0')}:${cls.time.minute.toString().padLeft(2, '0')}',
                                  duration: cls.duration,
                                  repeat: EventRepeat.none,
                                  colorHex: hexFromColor(
                                    _classTypeColors[cls.type]!,
                                  ),
                                ),
                              );
                              nextDate = nextDate.add(const Duration(days: 7));
                            }
                          }
                          setState(() {
                            _semesterClasses.clear();
                            _semesterEndDate = null;
                          });
                          Navigator.of(context).pop();
                        },
                  child: Text(l10n.t('create')),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<_CalendarItem> _itemsForDate({
    required DateTime date,
    required List<Countdown> countdowns,
    required List<Task> tasks,
    required BuildContext context,
    required AppLocalizations l10n,
  }) {
    final items = <_CalendarItem>[];
    final seenTaskIds = <int>{};
    final theme = Theme.of(context);
    final eventNotifier = ref.read(eventControllerProvider.notifier);
    final eventsForDate = eventNotifier.eventsForDate(date);

    // Track which countdown titles match calendar events
    final countdownTitlesMatchingEvents = <String>{};
    for (final event in eventsForDate) {
      countdownTitlesMatchingEvents.add(event.title);
    }

    for (final countdown in countdowns) {
      if (_isSameDay(countdown.date, date)) {
        // Skip countdowns that were created from calendar events
        if (!countdownTitlesMatchingEvents.contains(countdown.title)) {
          items.add(
            _CalendarItem(
              id: 'timer-${countdown.id}',
              title: '${countdown.emoji} ${countdown.title}',
              typeLabel: 'timer',
              color:
                  _countdownColors[countdown.variant] ??
                  theme.colorScheme.primary,
            ),
          );
        }
        if (countdown.linkedTaskId != null) {
          seenTaskIds.add(countdown.linkedTaskId!);
        }
      }
    }

    for (final task in tasks) {
      if (task.dueDate != null &&
          _isSameDay(task.dueDate!, date) &&
          !seenTaskIds.contains(task.id)) {
        items.add(
          _CalendarItem(
            id: 'task-${task.id}',
            title: task.title,
            typeLabel: 'todo',
            color: task.completed
                ? theme.colorScheme.outline
                : theme.colorScheme.primary,
            completed: task.completed,
            repeatLabel: task.repeat != TaskRepeat.none
                ? _repeatLabel(_repeatFromTask(task.repeat), l10n)
                : null,
          ),
        );
      }
    }

    for (final event in eventsForDate) {
      items.add(
        _CalendarItem(
          id: 'event-${event.id}',
          title: event.title,
          typeLabel: 'calendar',
          color: colorFromHex(event.colorHex),
          time: event.time,
          durationLabel: event.duration > 0
              ? _formatDurationLabel(event.duration)
              : null,
          repeatLabel: event.repeat != EventRepeat.none
              ? _repeatLabel(event.repeat, l10n)
              : null,
          eventId: event.id,
        ),
      );
    }

    items.sort((a, b) {
      if (a.time != null && b.time != null) {
        return a.time!.compareTo(b.time!);
      } else if (a.time != null) {
        return -1;
      } else if (b.time != null) {
        return 1;
      }
      return a.title.compareTo(b.title);
    });

    return items;
  }

  double _hourFromString(String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return hour + minute / 60.0;
  }

  DateTime _startOfWeek(DateTime date) {
    final weekday = date.weekday % 7;
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: weekday));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  TimeOfDay _timeOfDayFromString(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  EventRepeat _repeatFromTask(TaskRepeat repeat) {
    switch (repeat) {
      case TaskRepeat.daily:
        return EventRepeat.daily;
      case TaskRepeat.weekly:
        return EventRepeat.weekly;
      case TaskRepeat.monthly:
        return EventRepeat.monthly;
      case TaskRepeat.none:
        return EventRepeat.none;
    }
  }

  String _repeatLabel(EventRepeat repeat, AppLocalizations l10n) {
    switch (repeat) {
      case EventRepeat.daily:
        return l10n.t('daily');
      case EventRepeat.weekly:
        return l10n.t('weekly');
      case EventRepeat.monthly:
        return l10n.t('monthly');
      case EventRepeat.yearly:
        return l10n.t('yearly');
      case EventRepeat.none:
        return l10n.t('none');
    }
  }

  String _formatDurationLabel(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '${hours}h';
    }
    return '${hours}h ${mins}m';
  }

  DateTime _nextWeekday(DateTime start, int weekday) {
    var date = DateTime(start.year, start.month, start.day);
    while (date.weekday % 7 != weekday) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }
}

class _CalendarItem {
  _CalendarItem({
    required this.id,
    required this.title,
    required this.typeLabel,
    required this.color,
    this.completed = false,
    this.time,
    this.durationLabel,
    this.repeatLabel,
    this.eventId,
  });

  final String id;
  final String title;
  final String typeLabel;
  final Color color;
  final bool completed;
  final String? time;
  final String? durationLabel;
  final String? repeatLabel;
  final int? eventId;

  IconData get icon {
    switch (typeLabel) {
      case 'timer':
        return Icons.timer_outlined;
      case 'calendar':
        return Icons.event;
      default:
        return Icons.check_circle_outline;
    }
  }
}

class _ViewModeSelector extends StatelessWidget {
  const _ViewModeSelector({
    required this.viewMode,
    required this.onChanged,
    required this.l10n,
  });

  final CalendarViewMode viewMode;
  final ValueChanged<CalendarViewMode> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: CalendarViewMode.values.map((mode) {
        final selected = viewMode == mode;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: OutlinedButton(
              onPressed: () => onChanged(mode),
              style: OutlinedButton.styleFrom(
                backgroundColor: selected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),
              child: Text(
                _viewLabel(mode),
                style: TextStyle(
                  color: selected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _viewLabel(CalendarViewMode mode) {
    switch (mode) {
      case CalendarViewMode.day:
        return l10n.t('day');
      case CalendarViewMode.week:
        return l10n.t('week');
      case CalendarViewMode.month:
        return l10n.t('month');
    }
  }
}

class _NavigationHeader extends StatelessWidget {
  const _NavigationHeader({
    required this.currentDate,
    required this.viewMode,
    required this.l10n,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  final DateTime currentDate;
  final CalendarViewMode viewMode;
  final AppLocalizations l10n;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    String label;
    switch (viewMode) {
      case CalendarViewMode.day:
        label = DateFormat.yMMMMEEEEd().format(currentDate);
        break;
      case CalendarViewMode.week:
        final start = DateFormat.yMMMd().format(
          currentDate.subtract(Duration(days: currentDate.weekday % 7)),
        );
        final end = DateFormat.yMMMd().format(
          currentDate.add(const Duration(days: 6)),
        );
        label = '$start - $end';
        break;
      case CalendarViewMode.month:
        label = DateFormat.yMMMM().format(currentDate);
        break;
    }

    return Row(
      children: [
        IconButton(onPressed: onPrevious, icon: const Icon(Icons.chevron_left)),
        Expanded(
          child: Column(
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(onPressed: onToday, child: Text(l10n.t('today'))),
            ],
          ),
        ),
        IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
      ],
    );
  }
}

class _FabMenu extends StatelessWidget {
  const _FabMenu({
    required this.expanded,
    required this.onToggle,
    required this.onAddEvent,
    required this.onPlanSemester,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onAddEvent;
  final VoidCallback onPlanSemester;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (expanded) ...[
          FloatingActionButton.small(
            heroTag: 'semester',
            onPressed: onPlanSemester,
            child: const Icon(Icons.school),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.small(
            heroTag: 'event',
            onPressed: onAddEvent,
            child: const Icon(Icons.calendar_month),
          ),
          const SizedBox(height: 12),
        ],
        FloatingActionButton(
          onPressed: onToggle,
          child: Icon(expanded ? Icons.close : Icons.add),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

class _ColorOption {
  const _ColorOption(this.label, this.color);

  final String label;
  final Color color;
}

class _SemesterClass {
  _SemesterClass({
    required this.id,
    required this.name,
    required this.type,
    required this.day,
    required this.time,
    required this.duration,
  });

  final String id;
  final String name;
  final ClassType type;
  final int day;
  final TimeOfDay time;
  final int duration;
}

enum ClassType { lecture, tutorial, reinforcement, other }

List<String> _weekDays(AppLocalizations l10n) => [
  l10n.t('sun'),
  l10n.t('mon'),
  l10n.t('tue'),
  l10n.t('wed'),
  l10n.t('thu'),
  l10n.t('fri'),
  l10n.t('sat'),
];

String _classTypeLabel(ClassType type, AppLocalizations l10n) {
  switch (type) {
    case ClassType.lecture:
      return l10n.t('lecture');
    case ClassType.tutorial:
      return l10n.t('tutorial');
    case ClassType.reinforcement:
      return l10n.t('reinforcement');
    case ClassType.other:
      return l10n.t('other');
  }
}

const _colorOptions = [
  _ColorOption('Purple', Color(0xFFA855F7)),
  _ColorOption('Blue', Color(0xFF3B82F6)),
  _ColorOption('Green', Color(0xFF22C55E)),
  _ColorOption('Red', Color(0xFFEF4444)),
  _ColorOption('Orange', Color(0xFFF97316)),
  _ColorOption('Pink', Color(0xFFEC4899)),
  _ColorOption('Teal', Color(0xFF14B8A6)),
  _ColorOption('Gold', Color(0xFFFACC15)),
];

const _countdownColors = {
  CountdownVariant.red: Color(0xFFEF4444),
  CountdownVariant.blue: Color(0xFF3B82F6),
  CountdownVariant.gold: Color(0xFFF59E0B),
};

final Map<int, String Function(AppLocalizations)> _durationOptions = {
  15: (l10n) => l10n.t('minutes15'),
  30: (l10n) => l10n.t('minutes30'),
  45: (l10n) => l10n.t('minutes45'),
  60: (l10n) => l10n.t('hour1'),
  90: (l10n) => l10n.t('hours15'),
  120: (l10n) => l10n.t('hours2'),
  180: (l10n) => l10n.t('hours3'),
  240: (l10n) => l10n.t('hours4'),
  360: (l10n) => l10n.t('hours6'),
  480: (l10n) => l10n.t('hours8'),
};

const _classTypeColors = {
  ClassType.lecture: Color(0xFF3B82F6),
  ClassType.tutorial: Color(0xFF22C55E),
  ClassType.reinforcement: Color(0xFFF97316),
  ClassType.other: Color(0xFF8B5CF6),
};

// Additional helper widgets and classes go here...
