import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:students_app/core/providers/shared_prefs_provider.dart';
import 'package:students_app/features/countdowns/domain/countdown.dart';

final countdownControllerProvider =
    NotifierProvider<CountdownController, List<Countdown>>(
  CountdownController.new,
);

class CountdownController extends Notifier<List<Countdown>> {
  static const _storageKey = 'countdown-app-countdowns';

  @override
  List<Countdown> build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final stored = prefs.getString(_storageKey);
    if (stored != null) {
      final data = jsonDecode(stored) as List<dynamic>;
      return data
          .cast<Map<String, dynamic>>()
          .map(Countdown.fromJson)
          .toList(growable: false);
    }
    return [];
  }

  Countdown addCountdown({
    required String title,
    required DateTime targetDate,
    required DateTime startDate,
    required String emoji,
    int? linkedTaskId,
  }) {
    final variant = _nextVariant;
    final countdown = Countdown(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      date: targetDate,
      startDate: startDate,
      emoji: emoji,
      variant: variant,
      linkedTaskId: linkedTaskId,
    );
    state = [...state, countdown];
    _persist();
    return countdown;
  }

  void updateCountdown(int id, Countdown updated) {
    state = state
        .map((countdown) => countdown.id == id ? updated : countdown)
        .toList();
    _persist();
  }

  void deleteCountdown(int id) {
    state = state.where((countdown) => countdown.id != id).toList();
    _persist();
  }

  CountdownVariant get _nextVariant {
    if (state.isEmpty) {
      return CountdownVariant.red;
    }
    final variants = CountdownVariant.values;
    final nextIndex = state.length % variants.length;
    return variants[nextIndex];
  }

  void _persist() {
    final prefs = ref.read(sharedPreferencesProvider);
    final payload =
        state.map((countdown) => countdown.toJson()).toList(growable: false);
    prefs.setString(_storageKey, jsonEncode(payload));
  }

}
