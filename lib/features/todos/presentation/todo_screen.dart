import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:students_app/core/localization/app_language.dart';
import 'package:students_app/core/localization/translations.dart';
import 'package:students_app/features/settings/application/settings_controller.dart';
import 'package:students_app/features/todos/application/todo_controller.dart';
import 'package:students_app/features/todos/domain/task.dart';
import 'package:students_app/shared/widgets/app_header.dart';
import 'package:students_app/shared/widgets/bottom_nav.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  @override
  Widget build(BuildContext context) {
    final todos = ref.watch(todoControllerProvider);
    final settings = ref.watch(settingsControllerProvider);
    final l10n = ref.watch(localizationProvider);
    final localeCode = settings.language.locale.toLanguageTag();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('todo'),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _openCreateSheet,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.t('addTask')),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _TaskSection(
                      title: '${l10n.t('open')} (${todos.openTasks.length})',
                      isOpenSection: true,
                      tasks: todos.openTasks,
                      localeCode: localeCode,
                      l10n: l10n,
                      onToggle: (task) => ref
                          .read(todoControllerProvider.notifier)
                          .toggleTask(task.id),
                      onDelete: (task) => _confirmDelete(task.id),
                    ),
                    const SizedBox(height: 24),
                    _TaskSection(
                      title:
                          '${l10n.t('completed')} (${todos.completedTasks.length})',
                      isOpenSection: false,
                      tasks: todos.completedTasks,
                      localeCode: localeCode,
                      l10n: l10n,
                      onToggle: (task) => ref
                          .read(todoControllerProvider.notifier)
                          .toggleTask(task.id),
                      onDelete: (task) => _confirmDelete(task.id),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }

  Future<void> _openCreateSheet() async {
    final l10n = ref.read(localizationProvider);
    final todoNotifier = ref.read(todoControllerProvider.notifier);
    final titleController = TextEditingController();
    DateTime? dueDate;
    TaskRepeat repeat = TaskRepeat.none;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.t('createNewTask'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: l10n.t('taskTitle'),
                hintText: l10n.t('enterTaskTitle'),
              ),
            ),
            const SizedBox(height: 12),
            _OptionalDateField(
              label:
                  '${l10n.t('dueDate')} (${l10n.t('optional')})',
              onDateChanged: (date) => dueDate = date,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TaskRepeat>(
              value: repeat,
              onChanged: (value) => repeat = value ?? TaskRepeat.none,
              decoration: InputDecoration(
                labelText: '${l10n.t('repeat')} (${l10n.t('optional')})',
              ),
              items: TaskRepeat.values
                  .map(
                    (value) => DropdownMenuItem<TaskRepeat>(
                      value: value,
                      child: Text(_repeatLabel(value, l10n)),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                todoNotifier.addTask(
                  title: titleController.text.trim(),
                  dueDate: dueDate,
                  repeat: repeat,
                );
                Navigator.of(context).pop();
              },
              child: Text(l10n.t('create')),
            ),
          ],
        ),
      ),
    );
  }

  String _repeatLabel(TaskRepeat repeat, AppLocalizations l10n) {
    switch (repeat) {
      case TaskRepeat.daily:
        return l10n.t('daily');
      case TaskRepeat.weekly:
        return l10n.t('weekly');
      case TaskRepeat.monthly:
        return l10n.t('monthly');
      case TaskRepeat.none:
        return l10n.t('noRepeat');
    }
  }

  Future<void> _confirmDelete(int id) async {
    final l10n = ref.read(localizationProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.t('deleteTask')),
        content: Text(l10n.t('deleteTaskConfirm')),
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
      ref.read(todoControllerProvider.notifier).deleteTask(id);
    }
  }
}

class _TaskSection extends StatelessWidget {
  const _TaskSection({
    required this.title,
    required this.isOpenSection,
    required this.tasks,
    required this.localeCode,
    required this.l10n,
    required this.onToggle,
    required this.onDelete,
  });

  final String title;
  final bool isOpenSection;
  final List<Task> tasks;
  final String localeCode;
  final AppLocalizations l10n;
  final ValueChanged<Task> onToggle;
  final ValueChanged<Task> onDelete;

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM d', localeCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.circle_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (tasks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              isOpenSection ? l10n.t('noOpenTasks') : l10n.t('noCompletedTasks'),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...tasks.map(
            (task) => Card(
              color: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => onToggle(task),
                      icon: Icon(
                        task.completed
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: task.completed
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      decoration: task.completed
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (task.dueDate != null)
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 14),
                                    const SizedBox(width: 4),
                                    Text(dateFormatter.format(task.dueDate!)),
                                  ],
                                ),
                              if (task.repeat != TaskRepeat.none) ...[
                                const SizedBox(width: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.repeat, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      _repeatLabel(task.repeat, l10n),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => onDelete(task),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _repeatLabel(TaskRepeat repeat, AppLocalizations l10n) {
    switch (repeat) {
      case TaskRepeat.daily:
        return l10n.t('daily');
      case TaskRepeat.weekly:
        return l10n.t('weekly');
      case TaskRepeat.monthly:
        return l10n.t('monthly');
      case TaskRepeat.none:
        return l10n.t('noRepeat');
    }
  }
}

class _OptionalDateField extends StatefulWidget {
  const _OptionalDateField({
    required this.label,
    required this.onDateChanged,
  });

  final String label;
  final ValueChanged<DateTime?> onDateChanged;

  @override
  State<_OptionalDateField> createState() => _OptionalDateFieldState();
}

class _OptionalDateFieldState extends State<_OptionalDateField> {
  DateTime? _value;

  @override
  Widget build(BuildContext context) {
    final text =
        _value == null ? '-' : DateFormat('yyyy-MM-dd').format(_value!);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(widget.label),
      subtitle: Text(text),
      trailing: IconButton(
        icon: const Icon(Icons.calendar_month),
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          setState(() => _value = picked);
          widget.onDateChanged(picked);
        },
      ),
    );
  }
}
