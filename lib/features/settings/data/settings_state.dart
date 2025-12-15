import 'package:equatable/equatable.dart';
import 'package:students_app/core/localization/app_language.dart';
import 'package:students_app/core/theme/app_theme.dart';

class SettingsState extends Equatable {
  const SettingsState({
    required this.theme,
    required this.language,
    required this.mainTargetDate,
    required this.mainStartDate,
  });

  final ThemeType theme;
  final AppLanguage language;
  final DateTime mainTargetDate;
  final DateTime mainStartDate;

  SettingsState copyWith({
    ThemeType? theme,
    AppLanguage? language,
    DateTime? mainTargetDate,
    DateTime? mainStartDate,
  }) {
    return SettingsState(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      mainTargetDate: mainTargetDate ?? this.mainTargetDate,
      mainStartDate: mainStartDate ?? this.mainStartDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'theme': theme.storageKey,
        'language': language.storageKey,
        'mainTargetDate': mainTargetDate.toIso8601String(),
        'mainStartDate': mainStartDate.toIso8601String(),
      };

  factory SettingsState.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return defaultSettings;
    }
    return SettingsState(
      theme: ThemeTypeStorage.fromStorage(json['theme'] as String?),
      language: languageFromStorage(json['language'] as String?),
      mainTargetDate: DateTime.tryParse(json['mainTargetDate'] as String? ?? '') ??
          defaultSettings.mainTargetDate,
      mainStartDate: DateTime.tryParse(json['mainStartDate'] as String? ?? '') ??
          defaultSettings.mainStartDate,
    );
  }

  static final defaultSettings = SettingsState(
    theme: ThemeType.dark,
    language: AppLanguage.en,
    mainTargetDate: DateTime.utc(2027, 10, 21),
    mainStartDate: DateTime.utc(2024, 1, 1),
  );

  @override
  List<Object> get props => [theme, language, mainTargetDate, mainStartDate];
}
