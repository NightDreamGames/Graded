// Dart imports:
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animations/animations.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// Project imports:
import '/UI/Settings/flutter_settings_screens.dart';
import 'Calculations/manager.dart';
import 'Misc/locale_provider.dart';
import 'Misc/storage.dart';
import 'Translations/translations.dart';
import 'UI/Routes/home_route.dart';
import 'UI/Routes/settings_route.dart';
import 'UI/Routes/setup_route.dart';
import 'UI/Routes/subject_edit_route.dart';
import 'UI/Routes/subject_route.dart';
import 'UI/Utilities/app_theme.dart';

final GlobalKey appContainerKey = GlobalKey();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Settings.init();
  await Manager.init();

  String initialRoute = "/home";

  if (getPreference("is_first_run")) {
    initialRoute = "/setup_first";
  }

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
    setOptimalDisplayMode();

    String brightness = getPreference("theme");
    String localeName = getPreference("language");

    return ChangeNotifierProvider(
      create: (context) => LocaleProvider(locale: localeName != defaultValues["language"] ? Locale(localeName) : null),
      child: Consumer<LocaleProvider>(
        builder: (context, provider, _) => DynamicColorBuilder(
          builder: (ColorScheme? light, ColorScheme? dark) => MaterialApp(
            theme: AppTheme.getTheme(Brightness.light, light, dark),
            darkTheme: AppTheme.getTheme(Brightness.dark, light, dark),
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
            locale: provider.locale,
            debugShowCheckedModeBanner: false,
            initialRoute: widget.initialRoute,
            onGenerateRoute: (settings) {
              Widget route;

              switch (settings.name) {
                case "/home":
                  route = const HomePage();
                  break;
                case "/subject":
                  route = const SubjectRoute();
                  break;
                case "/settings":
                  route = const SettingsPage();
                  break;
                case "/setup":
                  route = const SetupPage();
                  break;
                case "/setup_first":
                  route = const SetupPage(dismissible: false);
                  break;
                case "/subject_edit":
                  route = const SubjectEditRoute();
                  break;
                default:
                  route = const HomePage();
                  break;
              }

              return buildSharedAxisTransitionPageRoute((_) => Material(child: route), settings: settings);
            },
          ),
        ),
      ),
    );
  }
}

Route buildSharedAxisTransitionPageRoute(Widget Function(BuildContext) builder, {RouteSettings? settings}) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.horizontal,
        child: child,
      );
    },
  );
}

Future<void> setOptimalDisplayMode() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

  if (Platform.isAndroid && androidInfo.version.sdkInt >= 23) {
    await FlutterDisplayMode.setHighRefreshRate();
  }
}
