import 'package:flutter/material.dart';

enum AppLanguage { en, he }

extension AppLanguageX on AppLanguage {
  Locale get locale {
    switch (this) {
      case AppLanguage.en:
        return const Locale('en');
      case AppLanguage.he:
        return const Locale('he');
    }
  }

  TextDirection get textDirection =>
      this == AppLanguage.he ? TextDirection.rtl : TextDirection.ltr;

  String get storageKey => name;
}

AppLanguage languageFromStorage(String? value) {
  if (value == null) {
    return AppLanguage.en;
  }
  return AppLanguage.values.firstWhere(
    (lang) => lang.storageKey == value,
    orElse: () => AppLanguage.en,
  );
}
