// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_localizations/flutter_localizations.dart';

// Project imports:
import 'package:gradely/UI/Routes/settings_route.dart';
import 'package:gradely/UI/Routes/setup_route.dart';
import 'package:gradely/UI/Routes/subject_edit_route.dart';
import '/UI/Settings/flutter_settings_screens.dart';
import 'Calculations/manager.dart';
import 'Misc/storage.dart';
import 'Translation/translations.dart';
import 'UI/Routes/home_route.dart';
import 'UI/Utilities/app_theme.dart';

final GlobalKey appContainerKey = GlobalKey();

void main() async {
  await Settings.init();
  await Manager.init();

  String initialRoute = "/home";

  if (Storage.getPreference("is_first_run")) {
    initialRoute = "/setup";
  }

  Manager.calculate();

  runApp(
    AppContainer(initialRoute: initialRoute, key: appContainerKey),
  );
}

class AppContainer extends StatefulWidget {
  const AppContainer({
    Key? key,
    required this.initialRoute,
  }) : super(key: key);

  final String initialRoute;

  @override
  State<AppContainer> createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> {
  @override
  Widget build(BuildContext context) {
    String brightness = Storage.getPreference("theme");

    return MaterialApp(
      theme: AppTheme.getTheme(Brightness.light),
      darkTheme: AppTheme.getTheme(Brightness.dark),
      themeMode: brightness == "system"
          ? ThemeMode.system
          : brightness == "light"
              ? ThemeMode.light
              : ThemeMode.dark,
      localizationsDelegates: const [
        TranslationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: TranslationsDelegate.supportedLocals,
      debugShowCheckedModeBanner: false,
      initialRoute: widget.initialRoute,
      routes: {
        '/home': (context) => const Material(child: HomePage()),
        //'/subject': (context) => Material(child: SubjectRoute()),
        '/settings': (context) => const Material(child: SettingsPage()),
        '/setup': (context) => const Material(child: SetupPage()),
        '/subject_edit': (context) => const Material(child: SubjectEditRoute()),
      },
    );
  }
}
