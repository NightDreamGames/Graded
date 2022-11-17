// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:dynamic_color/dynamic_color.dart";

class AppTheme {
  static ColorScheme? lightColorScheme;
  static ColorScheme? darkColorScheme;

  static ThemeData getTheme(Brightness brightness) {
    if (lightColorScheme == null) {
      DynamicColorBuilder(
        builder: (ColorScheme? light, ColorScheme? dark) {
          lightColorScheme = lightColorScheme;
          darkColorScheme = darkColorScheme;

          return Container();
        },
      );
    }

    ColorScheme scheme = brightness == Brightness.light ? lightTheme() : darkTheme();

    return ThemeData.from(
      colorScheme: scheme,
      useMaterial3: true,
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
