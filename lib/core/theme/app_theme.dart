import 'package:flutter/material.dart';

enum ThemeType {
  dark,
  glacier,
  harvest,
  lavender,
  brutalist,
  obsidian,
  orchid,
  solar,
  tide,
  verdant,
}

extension ThemeTypeStorage on ThemeType {
  String get storageKey => name;

  static ThemeType fromStorage(String? value) {
    if (value == null) {
      return ThemeType.dark;
    }
    return ThemeType.values.firstWhere(
      (element) => element.storageKey == value,
      orElse: () => ThemeType.dark,
    );
  }
}

class AppTheme {
  static ThemeData themeFor(ThemeType type) {
    final palette = _palettes[type] ?? _palettes[ThemeType.dark]!;
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      secondary: palette.secondary,
      onSecondary: palette.onSecondary,
      error: palette.error,
      onError: palette.onError,
      background: palette.background,
      onBackground: palette.onSurface,
      surface: palette.surface,
      onSurface: palette.onSurface,
      surfaceVariant: palette.muted,
      onSurfaceVariant: palette.onMuted,
      outline: palette.outline,
      outlineVariant: palette.outlineVariant,
      tertiary: palette.secondary,
      onTertiary: palette.onSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      cardColor: palette.surface,
      dividerColor: palette.outline,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surface,
        contentTextStyle: TextStyle(color: palette.onSurface),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: palette.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.onSurface,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.background.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.primary),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surface,
        selectedColor: palette.primary.withOpacity(0.2),
        labelStyle: TextStyle(color: palette.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: palette.outline),
        ),
      ),
    );
  }
}

class _ThemePalette {
  const _ThemePalette({
    required this.background,
    required this.surface,
    required this.onSurface,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.muted,
    required this.onMuted,
    required this.outline,
    required this.outlineVariant,
    required this.error,
    required this.onError,
  });

  final Color background;
  final Color surface;
  final Color onSurface;
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color muted;
  final Color onMuted;
  final Color outline;
  final Color outlineVariant;
  final Color error;
  final Color onError;
}

Color _hsl(double h, double s, double l) {
  return HSLColor.fromAHSL(1, h, s / 100, l / 100).toColor();
}

const _errorHue = 0.0;

final Map<ThemeType, _ThemePalette> _palettes = {
  ThemeType.dark: _ThemePalette(
    background: _hsl(0, 0, 9),
    surface: _hsl(0, 0, 14),
    onSurface: _hsl(0, 0, 98),
    primary: _hsl(217, 91, 60),
    onPrimary: _hsl(210, 40, 98),
    secondary: _hsl(0, 0, 45),
    onSecondary: _hsl(0, 0, 98),
    muted: _hsl(0, 0, 32),
    onMuted: _hsl(0, 0, 90),
    outline: _hsl(0, 0, 32),
    outlineVariant: _hsl(0, 0, 45),
    error: _hsl(0, 84, 60),
    onError: _hsl(0, 85, 97),
  ),
  ThemeType.glacier: _ThemePalette(
    background: _hsl(200, 30, 10),
    surface: _hsl(200, 25, 15),
    onSurface: _hsl(200, 20, 98),
    primary: _hsl(200, 80, 55),
    onPrimary: _hsl(200, 20, 98),
    secondary: _hsl(200, 20, 30),
    onSecondary: _hsl(200, 20, 98),
    muted: _hsl(200, 20, 35),
    onMuted: _hsl(200, 20, 80),
    outline: _hsl(200, 20, 25),
    outlineVariant: _hsl(200, 20, 35),
    error: _hsl(_errorHue, 84, 60),
    onError: _hsl(_errorHue, 85, 97),
  ),
  ThemeType.harvest: _ThemePalette(
    background: _hsl(30, 20, 10),
    surface: _hsl(30, 25, 15),
    onSurface: _hsl(30, 20, 98),
    primary: _hsl(35, 90, 55),
    onPrimary: _hsl(30, 20, 10),
    secondary: _hsl(30, 20, 30),
    onSecondary: _hsl(30, 20, 98),
    muted: _hsl(30, 20, 35),
    onMuted: _hsl(30, 20, 80),
    outline: _hsl(30, 20, 25),
    outlineVariant: _hsl(30, 20, 35),
    error: _hsl(_errorHue, 84, 60),
    onError: _hsl(_errorHue, 85, 97),
  ),
  ThemeType.lavender: _ThemePalette(
    background: _hsl(260, 20, 10),
    surface: _hsl(260, 25, 15),
    onSurface: _hsl(260, 20, 98),
    primary: _hsl(260, 70, 65),
    onPrimary: _hsl(260, 20, 98),
    secondary: _hsl(260, 20, 30),
    onSecondary: _hsl(260, 20, 98),
    muted: _hsl(260, 20, 35),
    onMuted: _hsl(260, 20, 80),
    outline: _hsl(260, 20, 25),
    outlineVariant: _hsl(260, 20, 35),
    error: _hsl(_errorHue, 84, 60),
    onError: _hsl(_errorHue, 85, 97),
  ),
  ThemeType.brutalist: _ThemePalette(
    background: _hsl(0, 0, 5),
    surface: _hsl(0, 0, 10),
    onSurface: _hsl(0, 0, 95),
    primary: _hsl(0, 0, 80),
    onPrimary: _hsl(0, 0, 5),
    secondary: _hsl(0, 0, 25),
    onSecondary: _hsl(0, 0, 95),
    muted: _hsl(0, 0, 30),
    onMuted: _hsl(0, 0, 70),
    outline: _hsl(0, 0, 20),
    outlineVariant: _hsl(0, 0, 30),
    error: _hsl(_errorHue, 84, 60),
    onError: _hsl(_errorHue, 85, 97),
  ),
  ThemeType.obsidian: _ThemePalette(
    background: _hsl(240, 10, 6),
    surface: _hsl(240, 10, 10),
    onSurface: _hsl(240, 10, 95),
    primary: _hsl(240, 60, 60),
    onPrimary: _hsl(240, 10, 98),
    secondary: _hsl(240, 10, 25),
    onSecondary: _hsl(240, 10, 95),
    muted: _hsl(240, 10, 30),
    onMuted: _hsl(240, 10, 70),
    outline: _hsl(240, 10, 18),
    outlineVariant: _hsl(240, 10, 30),
    error: _hsl(_errorHue, 84, 60),
    onError: _hsl(_errorHue, 85, 97),
  ),
  ThemeType.orchid: _ThemePalette(
    background: _hsl(330, 20, 10),
    surface: _hsl(330, 25, 15),
    onSurface: _hsl(330, 20, 98),
    primary: _hsl(330, 80, 60),
    onPrimary: _hsl(330, 20, 98),
    secondary: _hsl(330, 20, 30),
    onSecondary: _hsl(330, 20, 98),
    muted: _hsl(330, 20, 35),
    onMuted: _hsl(330, 20, 80),
    outline: _hsl(330, 20, 25),
    outlineVariant: _hsl(330, 20, 35),
    error: _hsl(_errorHue, 84, 60),
    onError: _hsl(_errorHue, 85, 97),
  ),
  ThemeType.solar: _ThemePalette(
    background: _hsl(45, 30, 10),
    surface: _hsl(45, 25, 15),
    onSurface: _hsl(45, 20, 98),
    primary: _hsl(45, 95, 55),
    onPrimary: _hsl(45, 30, 10),
    secondary: _hsl(45, 20, 30),
    onSecondary: _hsl(45, 20, 98),
    muted: _hsl(45, 20, 35),
    onMuted: _hsl(45, 20, 80),
    outline: _hsl(45, 20, 25),
    outlineVariant: _hsl(45, 20, 35),
    error: _hsl(_errorHue, 84, 60),
    onError: _hsl(_errorHue, 85, 97),
  ),
  ThemeType.tide: _ThemePalette(
    background: _hsl(180, 25, 10),
    surface: _hsl(180, 25, 15),
    onSurface: _hsl(180, 20, 98),
    primary: _hsl(180, 70, 50),
    onPrimary: _hsl(180, 25, 10),
    secondary: _hsl(180, 20, 30),
    onSecondary: _hsl(180, 20, 98),
    muted: _hsl(180, 20, 35),
    onMuted: _hsl(180, 20, 80),
    outline: _hsl(180, 20, 25),
    outlineVariant: _hsl(180, 20, 35),
    error: _hsl(_errorHue, 84, 60),
    onError: _hsl(_errorHue, 85, 97),
  ),
  ThemeType.verdant: _ThemePalette(
    background: _hsl(140, 25, 10),
    surface: _hsl(140, 25, 15),
    onSurface: _hsl(140, 20, 98),
    primary: _hsl(140, 70, 50),
    onPrimary: _hsl(140, 25, 10),
    secondary: _hsl(140, 20, 30),
    onSecondary: _hsl(140, 20, 98),
    muted: _hsl(140, 20, 35),
    onMuted: _hsl(140, 20, 80),
    outline: _hsl(140, 20, 25),
    outlineVariant: _hsl(140, 20, 35),
    error: _hsl(_errorHue, 84, 60),
    onError: _hsl(_errorHue, 85, 97),
  ),
};
