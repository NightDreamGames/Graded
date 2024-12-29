// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:animations/animations.dart";
import "package:dynamic_color/dynamic_color.dart";
import "package:flex_color_scheme/flex_color_scheme.dart";

// Project imports:
import "package:graded/misc/storage.dart";
import "package:graded/ui/widgets/better_predictive_transition.dart";

class AppTheme {
  static ColorScheme? lightColorScheme;
  static ColorScheme? darkColorScheme;
  static late bool hasDynamicColor;

  static ThemeData getTheme(Brightness brightness, ColorScheme? light, ColorScheme? dark) {
    lightColorScheme = light;
    darkColorScheme = dark;
    hasDynamicColor = light != null;

    ColorScheme colorScheme = brightness == Brightness.light ? lightTheme() : darkTheme();

    ThemeData theme;
    String? fontFamily = getPreference<String>("font");
    if (fontFamily == "system") fontFamily = null;

    if (brightness == Brightness.light) {
      theme = FlexColorScheme.light(
        colorScheme: colorScheme,
        fontFamily: fontFamily,
        subThemesData: const FlexSubThemesData(
          popupMenuRadius: 8,
        ),
      ).toTheme;
    } else {
      theme = FlexColorScheme.dark(
        colorScheme: colorScheme,
        fontFamily: fontFamily,
        darkIsTrueBlack: getPreference<bool>("amoled"),
        subThemesData: const FlexSubThemesData(
          popupMenuRadius: 8,
        ),
      ).toTheme;
    }

    colorScheme = theme.colorScheme;

    final TextTheme textTheme = theme.textTheme.copyWith(
      titleLarge: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      headlineSmall: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      headlineMedium: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
      headlineLarge: theme.textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
      displaySmall: theme.textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 40,
      ),
      displayMedium: theme.textTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 45,
      ),
      displayLarge: theme.textTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 57,
      ),
    );

    return theme.copyWith(
      textTheme: textTheme,
      listTileTheme: theme.listTileTheme.copyWith(
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
        iconColor: colorScheme.secondary,
      ),
      expansionTileTheme: theme.expansionTileTheme.copyWith(
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: colorScheme.primary,
        collapsedIconColor: colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      cardTheme: theme.cardTheme.copyWith(
        clipBehavior: Clip.antiAlias,
      ),
      dividerTheme: theme.dividerTheme.copyWith(
        thickness: 0.5,
        space: 1,
        indent: 16,
        endIndent: 16,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: BetterPredictiveBackPageTransitionsBuilder(),
          TargetPlatform.windows: SharedAxisTransitionBuilder(),
          TargetPlatform.linux: SharedAxisTransitionBuilder(),
          TargetPlatform.fuchsia: SharedAxisTransitionBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      iconTheme: theme.iconTheme.copyWith(
        color: colorScheme.secondary,
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        filled: false,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 2, color: colorScheme.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 2, color: colorScheme.error),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      tabBarTheme: theme.tabBarTheme.copyWith(
        tabAlignment: TabAlignment.start,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.fixed,
        backgroundColor: ElevationOverlay.applySurfaceTint(colorScheme.inverseSurface, colorScheme.surfaceTint, 3),
        contentTextStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        actionTextColor: colorScheme.inversePrimary,
      ),
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: false,
      ),
      switchTheme: theme.switchTheme.copyWith(
        thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return const Icon(Icons.check);
            }
            return null;
          },
        ),
      ),
      //platform: TargetPlatform.iOS,
    );
  }

  static ColorScheme lightTheme() {
    if (lightColorScheme != null && getPreference<bool>("dynamicColor")) {
      final ColorScheme lightBase = ColorScheme.fromSeed(seedColor: lightColorScheme!.primary);
      final List<Color> lightAdditionalColors = _extractAdditionalColors(lightBase);
      final ColorScheme lightScheme = _insertAdditionalColors(lightBase, lightAdditionalColors);

      return lightScheme.harmonized();
    } else {
      final seedColor = Color(getPreference<int>("customColor"));
      return ColorScheme.fromSeed(seedColor: seedColor);
    }
  }

  static ColorScheme darkTheme() {
    if (darkColorScheme != null && getPreference<bool>("dynamicColor")) {
      final ColorScheme darkBase = ColorScheme.fromSeed(seedColor: darkColorScheme!.primary, brightness: Brightness.dark);
      final List<Color> darkAdditionalColors = _extractAdditionalColors(darkBase);
      final ColorScheme darkScheme = _insertAdditionalColors(darkBase, darkAdditionalColors);

      return darkScheme.harmonized();
    } else {
      final seedColor = Color(getPreference<int>("customColor"));
      return ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.dark);
    }
  }
}

List<Color> _extractAdditionalColors(ColorScheme scheme) => [
      scheme.surface,
      scheme.surfaceDim,
      scheme.surfaceBright,
      scheme.surfaceContainerLowest,
      scheme.surfaceContainerLow,
      scheme.surfaceContainer,
      scheme.surfaceContainerHigh,
      scheme.surfaceContainerHighest,
    ];

ColorScheme _insertAdditionalColors(ColorScheme scheme, List<Color> additionalColors) => scheme.copyWith(
      surface: additionalColors[0],
      surfaceDim: additionalColors[1],
      surfaceBright: additionalColors[2],
      surfaceContainerLowest: additionalColors[3],
      surfaceContainerLow: additionalColors[4],
      surfaceContainer: additionalColors[5],
      surfaceContainerHigh: additionalColors[6],
      surfaceContainerHighest: additionalColors[7],
    );

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
