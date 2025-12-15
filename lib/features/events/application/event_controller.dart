import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:students_app/core/providers/shared_prefs_provider.dart';
import 'package:students_app/features/events/domain/calendar_event.dart';

final eventControllerProvider =
    NotifierProvider<EventController, List<CalendarEvent>>(
  EventController.new,
);

class EventController extends Notifier<List<CalendarEvent>> {
  static const _storageKey = 'countdown-app-events';

  @override
  List<CalendarEvent> build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final stored = prefs.getString(_storageKey);
    if (stored == null) {
      return const [];
    }
    final data = jsonDecode(stored) as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(CalendarEvent.fromJson)
        .toList(growable: false);
  }

  void addEvent(CalendarEvent event) {
    state = [...state, event];
    _persist();
  }

  void updateEvent(int id, CalendarEvent event) {
    state = state.map((e) => e.id == id ? event : e).toList();
    _persist();
  }

  void deleteEvent(int id) {
    state = state.where((event) => event.id != id).toList();
    _persist();
  }

  List<CalendarEvent> eventsForDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final List<CalendarEvent> result = [];
    for (final event in state) {
      if (_occursOnDate(event, normalized)) {
        result.add(event);
      }
    }
    return result;
  }

  bool _occursOnDate(CalendarEvent event, DateTime date) {
    final base = DateTime(event.date.year, event.date.month, event.date.day);
    if (base.isAtSameMomentAs(date)) {
      return true;
    }
    if (event.repeat == EventRepeat.none || base.isAfter(date)) {
      return false;
    }

    DateTime checkDate = base;
    var iterations = 0;
    while (!checkDate.isAfter(date) && iterations < 1000) {
      iterations++;
      switch (event.repeat) {
        case EventRepeat.daily:
          checkDate = checkDate.add(const Duration(days: 1));
          break;
        case EventRepeat.weekly:
          checkDate = checkDate.add(const Duration(days: 7));
          break;
        case EventRepeat.monthly:
          checkDate = DateTime(checkDate.year, checkDate.month + 1, checkDate.day);
          break;
        case EventRepeat.yearly:
          checkDate = DateTime(checkDate.year + 1, checkDate.month, checkDate.day);
          break;
        case EventRepeat.none:
          return false;
      }
      if (checkDate.year == date.year &&
          checkDate.month == date.month &&
          checkDate.day == date.day) {
        return true;
      }
    }
    return false;
  }

  void _persist() {
    final prefs = ref.read(sharedPreferencesProvider);
    final payload =
        state.map((event) => event.toJson()).toList(growable: false);
    prefs.setString(_storageKey, jsonEncode(payload));
  }
}
