import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:students_app/features/todos/domain/task.dart';
import 'package:students_app/core/localization/translations.dart';

/// A reusable, Android-friendly To-do list widget.
///
/// Features:
/// - Dismiss-to-delete with confirmation
/// - Toggle complete via icon button
/// - Shows due date and repeat icon
class TodoListWidget extends StatelessWidget {
  const TodoListWidget({
    super.key,
    required this.tasks,
    required this.localeCode,
    required this.l10n,
    required this.onToggle,
    required this.onDelete,
    this.emptyMessage,
  });

  final List<Task> tasks;
  final String localeCode;
  final AppLocalizations l10n;
  final ValueChanged<Task> onToggle;
  final ValueChanged<Task> onDelete;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM d', localeCode);

    if (tasks.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          emptyMessage ?? l10n.t('noTasks'),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: tasks.map((task) {
        return Dismissible(
          key: ValueKey(task.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: Theme.of(context).colorScheme.error,
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          confirmDismiss: (_) async {
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
              onDelete(task);
            }
            return confirmed == true;
          },
          child: Card(
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(12),
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                decoration: task.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (task.dueDate != null) ...[
                              const Icon(Icons.calendar_today, size: 14),
                              const SizedBox(width: 4),
                              Text(dateFormatter.format(task.dueDate!)),
                            ],
                            if (task.repeat != TaskRepeat.none) ...[
                              const SizedBox(width: 12),
                              const Icon(Icons.repeat, size: 14),
                              const SizedBox(width: 4),
                              Text(_repeatLabel(task.repeat, l10n)),
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
        );
      }).toList(),
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
