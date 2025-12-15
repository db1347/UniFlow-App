import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:students_app/core/localization/app_language.dart';
import 'package:students_app/core/providers/shared_prefs_provider.dart';
import 'package:students_app/core/theme/app_theme.dart';
import 'package:students_app/features/settings/data/settings_state.dart';

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(
  SettingsController.new,
);

class SettingsController extends Notifier<SettingsState> {
  static const _storageKey = 'app-settings';

  @override
  SettingsState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final stored = prefs.getString(_storageKey);
    if (stored == null) {
      return SettingsState.defaultSettings;
    }
    final map = jsonDecode(stored) as Map<String, dynamic>;
    return SettingsState.fromJson(map);
  }

  void setTheme(ThemeType theme) {
    state = state.copyWith(theme: theme);
    _persist();
  }

  void setLanguage(AppLanguage language) {
    state = state.copyWith(language: language);
    _persist();
  }

  void setMainTargetDate(DateTime date) {
    state = state.copyWith(mainTargetDate: date);
    _persist();
  }

  void setMainStartDate(DateTime date) {
    state = state.copyWith(mainStartDate: date);
    _persist();
  }

  void _persist() {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }
}
