// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:animations/animations.dart";

class AppTheme {
  static ColorScheme? lightColorScheme;
  static ColorScheme? darkColorScheme;

  static ThemeData getTheme(Brightness brightness, ColorScheme? light, ColorScheme? dark) {
    lightColorScheme = light;
    darkColorScheme = dark;

    final ColorScheme colorScheme = brightness == Brightness.light ? lightTheme() : darkTheme();

    final ThemeData theme = ThemeData.from(
      colorScheme: colorScheme,
      useMaterial3: true,
    );

    return theme.copyWith(
      textTheme: theme.textTheme
          .apply(
            fontFamily: "RobotoMono",
          )
          .copyWith(
            titleLarge: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            headlineMedium: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 42,
            ),
          ),
      primaryTextTheme: theme.textTheme.apply(
        fontFamily: "RobotoMono",
      ),
      listTileTheme: theme.listTileTheme.copyWith(
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
        iconColor: colorScheme.secondary,
      ),
      expansionTileTheme: theme.expansionTileTheme.copyWith(
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: colorScheme.primary,
        collapsedIconColor: colorScheme.onSurface.withOpacity(0.5),
      ),
      dividerTheme: theme.dividerTheme.copyWith(
        thickness: 0.5,
        space: 1,
        indent: 16,
        endIndent: 16,
        color: colorScheme.surfaceVariant,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: SharedAxisTransitionBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: theme.appBarTheme.copyWith(
        centerTitle: false,
      ),
      iconTheme: theme.iconTheme.copyWith(
        color: colorScheme.secondary,
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary),
          borderRadius: BorderRadius.circular(16.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 2, color: colorScheme.primary),
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error),
          borderRadius: BorderRadius.circular(16.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 2, color: colorScheme.error),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      //platform: TargetPlatform.iOS,
    );
  }

  static ColorScheme lightTheme() {
    final ColorScheme scheme = lightColorScheme ?? ColorScheme.fromSeed(seedColor: const Color(0xFF2196f3));
    //scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF2196f3), brightness: Brightness.light);
    //scheme = const ColorScheme.light();

    return scheme;
  }

  static ColorScheme darkTheme() {
    final ColorScheme scheme = darkColorScheme ?? ColorScheme.fromSeed(seedColor: const Color(0xFF2196f3), brightness: Brightness.dark);
    //scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF2196f3), brightness: Brightness.dark);
    //scheme = const ColorScheme.dark();

    return scheme;
  }
}

class SharedAxisTransitionBuilder extends PageTransitionsBuilder {
  const SharedAxisTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget? child,
  ) {
    return SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      transitionType: SharedAxisTransitionType.horizontal,
      child: child,
    );
  }
}
