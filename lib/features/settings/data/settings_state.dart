import 'package:equatable/equatable.dart';
import 'package:students_app/core/localization/app_language.dart';
import 'package:students_app/core/theme/app_theme.dart';

class SettingsState extends Equatable {
  const SettingsState({
    required this.theme,
    required this.language,
    required this.mainTargetDate,
    required this.mainStartDate,
    this.backgroundOpacity = 1.0,
    this.fontSize = 16.0,
  });

  final ThemeType theme;
  final AppLanguage language;
  final DateTime mainTargetDate;
  final DateTime mainStartDate;
  final double backgroundOpacity;
  final double fontSize;

  SettingsState copyWith({
    ThemeType? theme,
    AppLanguage? language,
    DateTime? mainTargetDate,
    DateTime? mainStartDate,
    double? backgroundOpacity,
    double? fontSize,
  }) {
    return SettingsState(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      mainTargetDate: mainTargetDate ?? this.mainTargetDate,
      mainStartDate: mainStartDate ?? this.mainStartDate,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  Map<String, dynamic> toJson() => {
    'theme': theme.storageKey,
    'language': language.storageKey,
    'mainTargetDate': mainTargetDate.toIso8601String(),
    'mainStartDate': mainStartDate.toIso8601String(),
    'backgroundOpacity': backgroundOpacity,
    'fontSize': fontSize,
  };

  factory SettingsState.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return defaultSettings;
    }
    return SettingsState(
      theme: ThemeTypeStorage.fromStorage(json['theme'] as String?),
      language: languageFromStorage(json['language'] as String?),
      mainTargetDate:
          DateTime.tryParse(json['mainTargetDate'] as String? ?? '') ??
          defaultSettings.mainTargetDate,
      mainStartDate:
          DateTime.tryParse(json['mainStartDate'] as String? ?? '') ??
          defaultSettings.mainStartDate,
      backgroundOpacity: (json['backgroundOpacity'] as num?)?.toDouble() ?? 1.0,
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
    );
  }

  static final defaultSettings = SettingsState(
    theme: ThemeType.dark,
    language: AppLanguage.en,
    mainTargetDate: DateTime.utc(2027, 10, 21),
    mainStartDate: DateTime.utc(2024, 1, 1),
    backgroundOpacity: 1.0,
    fontSize: 16.0,
  );

  @override
  List<Object?> get props => [
    theme,
    language,
    mainTargetDate,
    mainStartDate,
    backgroundOpacity,
    fontSize,
  ];
}
