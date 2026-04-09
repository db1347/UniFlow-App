import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:students_app/core/providers/shared_prefs_provider.dart';
import 'package:students_app/features/schedule/domain/schedule_entry.dart';

final scheduleControllerProvider =
    NotifierProvider<ScheduleController, List<ScheduleEntry>>(
      ScheduleController.new,
    );

class ScheduleController extends Notifier<List<ScheduleEntry>> {
  static const _storageKey = 'app-schedule-entries';

  @override
  List<ScheduleEntry> build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final stored = prefs.getString(_storageKey);
    if (stored == null) return [];
    final data = jsonDecode(stored) as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(ScheduleEntry.fromJson)
        .toList();
  }

  void addEntry(ScheduleEntry entry) {
    final next = List<ScheduleEntry>.from(state)..add(entry);
    state = next;
    _save();
  }

  void updateEntry(ScheduleEntry entry) {
    state = [
      for (final e in state) e.id == entry.id ? entry : e,
    ];
    _save();
  }

  void deleteEntry(int id) {
    state = state.where((e) => e.id != id).toList();
    _save();
  }

  List<ScheduleEntry> entriesForDay(int dayOfWeek) {
    return state
        .where((e) => e.dayOfWeek == dayOfWeek)
        .toList()
      ..sort((a, b) => a.startMinute.compareTo(b.startMinute));
  }

  int _nextId() {
    if (state.isEmpty) return 1;
    return state.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  int get nextId => _nextId();

  void _save() {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(_storageKey, jsonEncode(state.map((e) => e.toJson()).toList()));
  }
}
