// Flutter imports:
import "package:flutter/material.dart";

class AppTheme {
  static ColorScheme? lightColorScheme;
  static ColorScheme? darkColorScheme;

  static ThemeData getTheme(Brightness brightness, ColorScheme? light, ColorScheme? dark) {
    lightColorScheme = light;
    darkColorScheme = dark;

    ColorScheme scheme = brightness == Brightness.light ? lightTheme() : darkTheme();

    ThemeData theme = ThemeData.from(
      colorScheme: scheme,
      useMaterial3: true,
    );

    return theme.copyWith(
      textTheme: theme.textTheme.apply(
        fontFamily: 'RobotoMono',
      ),
      primaryTextTheme: theme.textTheme.apply(
        fontFamily: 'RobotoMono',
      ),
      dividerTheme: theme.dividerTheme.copyWith(
        thickness: 0.5,
        space: 1,
        color: theme.colorScheme.surfaceVariant,
      ),
    );
  }

  static ColorScheme lightTheme() {
    ColorScheme scheme = lightColorScheme ?? ColorScheme.fromSeed(seedColor: const Color(0xFF2196f3), brightness: Brightness.light);
    //scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF2196f3), brightness: Brightness.light);
    //scheme = const ColorScheme.light();

    return scheme;
  }

  static ColorScheme darkTheme() {
    ColorScheme scheme = darkColorScheme ?? ColorScheme.fromSeed(seedColor: const Color(0xFF2196f3), brightness: Brightness.dark);
    //scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF2196f3), brightness: Brightness.dark);
    //scheme = const ColorScheme.dark();

    return scheme;
  }
}
