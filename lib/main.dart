// Dart imports:
import "dart:io" show Platform;

// Flutter imports:
import "package:flutter/material.dart";
import "package:flutter/services.dart";

// Package imports:
import "package:device_info_plus/device_info_plus.dart";
import "package:dynamic_color/dynamic_color.dart";
import "package:flutter_displaymode/flutter_displaymode.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:provider/provider.dart";

// Project imports:
import "package:graded/calculations/manager.dart";
import "package:graded/localization/generated/l10n.dart";
import "package:graded/localization/material_localization/lb_intl.dart";
import "package:graded/misc/default_values.dart";
import "package:graded/misc/locale_provider.dart";
import "package:graded/misc/storage.dart";
import "package:graded/ui/routes/home_route.dart";
import "package:graded/ui/routes/settings_route.dart";
import "package:graded/ui/routes/setup_route.dart";
import "package:graded/ui/routes/subject_edit_route.dart";
import "package:graded/ui/routes/subject_route.dart";
import "package:graded/ui/settings/flutter_settings_screens.dart";
import "package:graded/ui/utilities/app_theme.dart";

final GlobalKey appContainerKey = GlobalKey();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Settings.init();
  await Manager.init();

  String initialRoute = "/";

  if (getPreference<bool>("is_first_run")) {
    initialRoute = "setup_first";
  }

  runApp(
    AppContainer(initialRoute: initialRoute, key: appContainerKey),
  );
}

class AppContainer extends StatefulWidget {
  const AppContainer({
    super.key,
    required this.initialRoute,
  });

  final String initialRoute;

  @override
  State<AppContainer> createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> {
  @override
  Widget build(BuildContext context) {
    setOptimalDisplayMode();

    ThemeMode brightness = ThemeMode.values.byName(getPreference<String>("theme"));
    String localeName = getPreference<String>("language");

    return ChangeNotifierProvider(
      create: (context) => LocaleProvider(locale: localeName != defaultValues["language"] ? Locale(localeName) : null),
      child: Consumer<LocaleProvider>(
        builder: (context, provider, _) => DynamicColorBuilder(
          builder: (ColorScheme? light, ColorScheme? dark) => MaterialApp(
            theme: AppTheme.getTheme(Brightness.light, light, dark),
            darkTheme: AppTheme.getTheme(Brightness.dark, light, dark),
            themeMode: brightness,
            localizationsDelegates: const [
              AppLocalizationDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              LbMaterialLocalizations.delegate,
              LbCupertinoLocalizations.delegate,
            ],
            supportedLocales: TranslationsClass.delegate.supportedLocales,
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              if (supportedLocales.map((e) => e.languageCode).contains(deviceLocale?.languageCode)) {
                return deviceLocale;
              }
              return const Locale("en", "");
            },
            locale: provider.locale,
            debugShowCheckedModeBanner: false,
            initialRoute: widget.initialRoute,
            onGenerateRoute: (settings) {
              Widget route;

              switch (settings.name) {
                case "/":
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
                case "setup_first":
                  route = const SetupPage(dismissible: false);
                  break;
                case "/subject_edit":
                  route = const SubjectEditRoute();
                  break;
                default:
                  route = const HomePage();
                  break;
              }

              return MaterialPageRoute(
                builder: (context) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    SystemChrome.setSystemUIOverlayStyle(
                      SystemUiOverlayStyle(
                        systemNavigationBarColor: Theme.of(context).colorScheme.surface,
                        systemNavigationBarIconBrightness: Theme.of(context).brightness == Brightness.light ? Brightness.dark : Brightness.light,
                        systemNavigationBarDividerColor: Theme.of(context).colorScheme.surface,
                      ),
                    );
                  });

                  return Material(
                    child: SafeArea(top: false, left: false, right: false, child: route),
                  );
                },
                settings: settings,
              );
            },
          ),
        ),
      ),
    );
  }
}

Future<void> setOptimalDisplayMode() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

  if (!Platform.isAndroid || androidInfo.version.sdkInt < 23) return;

  await FlutterDisplayMode.setHighRefreshRate();
}
