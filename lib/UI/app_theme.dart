import "package:flutter/material.dart";

class AppTheme {
  static ThemeData lightTheme(ColorScheme? lightColorScheme) {
    ColorScheme scheme = lightColorScheme ?? ColorScheme.fromSeed(seedColor: const Color(0xFF61A9E0));

    return ThemeData.from(
      colorScheme: scheme,
      useMaterial3: true,
    );
  }

  static ThemeData darkTheme(ColorScheme? darkColorScheme) {
    ColorScheme scheme = darkColorScheme ?? ColorScheme.fromSeed(seedColor: const Color(0xFF61A9E0), brightness: Brightness.dark);

    return ThemeData.from(
      colorScheme: scheme,
      useMaterial3: true,
    );
  }
}
