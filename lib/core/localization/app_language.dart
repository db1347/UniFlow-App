import 'package:flutter/material.dart';

enum AppLanguage { en, he, ru, ar }

extension AppLanguageX on AppLanguage {
  Locale get locale {
    switch (this) {
      case AppLanguage.en:
        return const Locale('en');
      case AppLanguage.he:
        return const Locale('he');
      case AppLanguage.ru:
        return const Locale('ru');
      case AppLanguage.ar:
        return const Locale('ar');
    }
  }

  TextDirection get textDirection {
    switch (this) {
      case AppLanguage.he:
      case AppLanguage.ar:
        return TextDirection.rtl;
      case AppLanguage.en:
      case AppLanguage.ru:
        return TextDirection.ltr;
    }
  }

  /// The human-readable name shown in the settings UI.
  String get displayName {
    switch (this) {
      case AppLanguage.en:
        return 'English';
      case AppLanguage.he:
        return 'עברית';
      case AppLanguage.ru:
        return 'Русский';
      case AppLanguage.ar:
        return 'العربية';
    }
  }

  String get storageKey => name;
}

AppLanguage languageFromStorage(String? value) {
  if (value == null) return AppLanguage.en;
  return AppLanguage.values.firstWhere(
    (lang) => lang.storageKey == value,
    orElse: () => AppLanguage.en,
  );
}
