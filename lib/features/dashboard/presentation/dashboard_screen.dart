import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:students_app/core/constants/emoji_options.dart';
import 'package:students_app/core/localization/translations.dart';
import 'package:students_app/features/countdowns/application/countdown_controller.dart';
import 'package:students_app/features/countdowns/domain/countdown.dart';
import 'package:students_app/features/settings/application/settings_controller.dart';
import 'package:students_app/features/todos/application/todo_controller.dart';
import 'package:students_app/shared/widgets/app_header.dart';
import 'package:students_app/shared/widgets/bottom_nav.dart';
import 'package:students_app/shared/widgets/main_countdown.dart';
import 'package:students_app/shared/widgets/mini_countdown_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isExitDialogVisible = false;

  Future<bool> _showExitDialog() async {
    final l10n = ref.read(localizationProvider);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.t('exitApp')),
        content: Text(l10n.t('exitAppConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.t('yes')),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<bool> _handleWillPop() async {
    if (_isExitDialogVisible) {
      return false;
    }
    _isExitDialogVisible = true;
    if (!mounted) {
      _isExitDialogVisible = false;
      return false;
    }
    final shouldExit = await _showExitDialog();
    if (!mounted) {
      _isExitDialogVisible = false;
      return false;
    }
    _isExitDialogVisible = false;
    if (shouldExit) {
      SystemNavigator.pop();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final countdowns = ref.watch(countdownControllerProvider);
    final todos = ref.watch(todoControllerProvider);
    final l10n = ref.watch(localizationProvider);

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const AppHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MainCountdown(
                        targetDate: settings.mainTargetDate,
                        startDate: settings.mainStartDate,
                        language: settings.language,
                        label: '${l10n.t('until')} ${l10n.t('graduation')}',
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.t('tapToSwitch'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _MiniCountdownList(
                        countdowns: countdowns,
                        onAddPressed: _openAddCountdownSheet,
                        onUpdate: (updated) {
                          ref
                              .read(countdownControllerProvider.notifier)
                              .updateCountdown(updated.id, updated);
                        },
                        onDelete: (id) => ref
                            .read(countdownControllerProvider.notifier)
                            .deleteCountdown(id),
                        l10n: l10n,
                      ),
                      const SizedBox(height: 32),
                      _TodoSummaryCard(
                        todos: todos,
                        l10n: l10n,
                        onViewAll: () => context.go('/todo'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNav(),
      ),
    );
  }

  Future<void> _openAddCountdownSheet() async {
    final l10n = ref.read(localizationProvider);
    final todos = ref.read(todoControllerProvider);
    final countdownNotifier = ref.read(countdownControllerProvider.notifier);
    final titleController = TextEditingController();
    DateTime targetDate = DateTime.now().add(const Duration(days: 7));
    DateTime startDate = DateTime.now();
    String emoji = emojiOptions.first;
    int? linkedTaskId;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom:
                      math.max(
                        MediaQuery.of(context).viewInsets.bottom,
                        MediaQuery.of(context).viewPadding.bottom,
                      ) +
                      24,
                  left: 16,
                  right: 16,
                  top: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('createNewTimer'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (todos.openTasksWithDueDate.isNotEmpty)
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.t('importFromTodo'),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                        ),
                        value: linkedTaskId,
                        items: todos.openTasksWithDueDate
                            .map(
                              (task) => DropdownMenuItem<int>(
                                value: task.id,
                                child: Text(
                                  '${task.title} - ${DateFormat.yMd().format(task.dueDate!)}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setSheetState(() {
                            linkedTaskId = value;
                            if (value != null) {
                              final task = todos.openTasksWithDueDate
                                  .firstWhere((element) => element.id == value);
                              titleController.text = task.title;
                              if (task.dueDate != null) {
                                targetDate = task.dueDate!;
                              }
                            }
                          });
                        },
                      ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: l10n.t('timerTitle'),
                        hintText: l10n.t('enterTimerTitle'),
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
                        final selected = emoji == symbol;
                        return ChoiceChip(
                          label: Text(symbol),
                          selected: selected,
                          onSelected: (_) =>
                              setSheetState(() => emoji = symbol),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) return;
                        countdownNotifier.addCountdown(
                          title: titleController.text.trim(),
                          targetDate: targetDate,
                          startDate: startDate,
                          emoji: emoji,
                          linkedTaskId: linkedTaskId,
                        );
                        Navigator.of(context).pop();
                      },
                      child: Text(l10n.t('create')),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MiniCountdownList extends StatelessWidget {
  const _MiniCountdownList({
    required this.countdowns,
    required this.onAddPressed,
    required this.onUpdate,
    required this.onDelete,
    required this.l10n,
  });

  final List<Countdown> countdowns;
  final VoidCallback onAddPressed;
  final ValueChanged<Countdown> onUpdate;
  final ValueChanged<int> onDelete;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: countdowns.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          if (index == countdowns.length) {
            return _AddTimerButton(onPressed: onAddPressed, l10n: l10n);
          }
          final countdown = countdowns[index];
          return MiniCountdownCard(
            countdown: countdown,
            onUpdated: (updated) => onUpdate(updated),
            onDelete: () => onDelete(countdown.id),
          );
        },
      ),
    );
  }
}

class _AddTimerButton extends StatelessWidget {
  const _AddTimerButton({required this.onPressed, required this.l10n});

  final VoidCallback onPressed;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(999),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                width: 3,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.add,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 110,
            child: Text(
              l10n.t('addTimer'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodoSummaryCard extends StatelessWidget {
  const _TodoSummaryCard({
    required this.todos,
    required this.l10n,
    required this.onViewAll,
  });

  final TodoState todos;
  final AppLocalizations l10n;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final openTasks = todos.openTasks;
    final completedTasks = todos.completedTasks;
    final formatter = DateFormat.yMd();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.t('tasks'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                '${openTasks.length} ${l10n.t('open').toLowerCase()} · ${completedTasks.length} ${l10n.t('done')}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (openTasks.isEmpty)
            Text(
              l10n.t('noOpenTasks'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            )
          else
            ...openTasks
                .take(4)
                .map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.radio_button_unchecked,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            task.title,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        if (task.dueDate != null)
                          Text(
                            formatter.format(task.dueDate!),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                          ),
                      ],
                    ),
                  ),
                ),
          if (openTasks.length > 4)
            Text(
              '+${openTasks.length - 4} ${l10n.t('moreTasks')}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onViewAll,
            child: Text(l10n.t('viewAllTasks')),
          ),
        ],
      ),
    );
  }
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
  late DateTime value = widget.initialDate;

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('yyyy-MM-dd').format(value);
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() => value = picked);
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
