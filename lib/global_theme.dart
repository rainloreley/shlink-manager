import 'package:flutter/material.dart';

class GlobalTheme {
  static final Color _lightFocusColor = Colors.black.withAlpha(30);
  static final Color _darkFocusColor = Colors.white.withAlpha(30);
  static ThemeData lightThemeData(ColorScheme? dynamicColorScheme) {
    return themeData(lightColorScheme, dynamicColorScheme, _lightFocusColor);
  }

  static ThemeData darkThemeData(ColorScheme? dynamicColorScheme) {
    return themeData(darkColorScheme, dynamicColorScheme, _darkFocusColor);
  }

  static ThemeData themeData(
      ColorScheme colorScheme, ColorScheme? dynamic, Color focusColor) {
    return ThemeData(
        colorScheme: colorScheme,
        canvasColor: colorScheme.surface,
        scaffoldBackgroundColor: colorScheme.surface,
        highlightColor: Colors.transparent,
        dividerColor: colorScheme.shadow,
        focusColor: focusColor,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            elevation: 0));
  }

  static ColorScheme get lightColorScheme {
    return ColorScheme(
      primary: Color(0xff747ab5),
      onPrimary: Colors.white,
      secondary: Color(0x335d63a6), // Color(0xFFDDE0E0),
      onSecondary: Color(0xFF322942),
      tertiary: Colors.grey[300],
      onTertiary: Colors.grey[700],
      surfaceContainer: (Colors.grey[100])!,
      outline: (Colors.grey[500])!,
      shadow: (Colors.grey[300])!,
      error: (Colors.red[400])!,
      onError: Colors.white,
      surface: Color(0xFFFAFBFB),
      onSurface: Color(0xFF241E30),
      brightness: Brightness.light,
    );
  }

  static ColorScheme get darkColorScheme {
    return ColorScheme(
      primary: Color(0xff5d63a6),
      secondary: Colors.blue.shade500,
      secondaryContainer: Color(0xff1c1c1c),
      surface: Colors.black,
      surfaceContainer: Color(0xff0f0f0f),
      onSurfaceVariant: Colors.grey[400],
      tertiary: Colors.grey[900],
      onTertiary: Colors.grey,
      outline: (Colors.grey[700])!,
      shadow: (Colors.grey[800])!,
      error: (Colors.red[400])!,
      onError: Colors.white,
      onPrimary: Colors.white,
      onSecondary: (Colors.grey[400])!,
      onSurface: Colors.white,
      brightness: Brightness.dark,
    );
  }
}
