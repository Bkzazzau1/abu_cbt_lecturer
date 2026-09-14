import 'package:flutter/material.dart';

class KslasTheme {
  const KslasTheme._();

  static ThemeData light() {
    const seed = Color(0xFF145C4A);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ).copyWith(
          primary: seed,
          secondary: const Color(0xFFB77821),
          tertiary: const Color(0xFF315C8A),
          surface: const Color(0xFFF7F8F6),
        );

    return _base(scheme);
  }

  static ThemeData dark() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF62B79D),
          brightness: Brightness.dark,
        ).copyWith(
          secondary: const Color(0xFFE2A852),
          tertiary: const Color(0xFF89B8E5),
        );

    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(44, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        minWidth: 76,
        groupAlignment: -0.86,
      ),
    );
  }
}
