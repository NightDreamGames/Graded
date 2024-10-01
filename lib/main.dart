// Flutter imports:
import "package:flutter/material.dart";
import "package:flutter/services.dart";

// Package imports:
import "package:device_info_plus/device_info_plus.dart";
import "package:dynamic_color/dynamic_color.dart";
import "package:flutter_displaymode/flutter_displaymode.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:provider/provider.dart";

// Project imports:
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/localization/generated/l10n.dart";
import "package:graded/localization/material_localization/lb_intl.dart";
import "package:graded/localization/translations.dart";
import "package:graded/misc/default_values.dart";
import "package:graded/misc/enums.dart";
import "package:graded/misc/locale_provider.dart";
import "package:graded/misc/storage.dart";
import "package:graded/ui/routes/main_route.dart";
import "package:graded/ui/routes/settings_route.dart";
import "package:graded/ui/routes/setup_route.dart";
import "package:graded/ui/routes/subject_edit_route.dart";
import "package:graded/ui/routes/year_route.dart";
import "package:graded/ui/settings/flutter_settings_screens.dart";
import "package:graded/ui/utilities/app_theme.dart";
import "package:graded/ui/utilities/haptics.dart";
import "package:graded/ui/utilities/misc_utilities.dart";

final GlobalKey appContainerKey = GlobalKey();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
GlobalKey<RouteWidgetState> mainRouteKey = GlobalKey();
final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Settings.init();
  Manager.init();

  String initialRoute = "/";

  if (getPreference<bool>("isFirstRun")) {
    initialRoute = "/setupFirst";
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

    final ThemeMode brightness = ThemeMode.values.byName(getPreference<String>("theme"));
    final String localeName = getPreference<String>("language");

    return ChangeNotifierProvider(
      create: (context) => LocaleProvider(localeName),
      child: Consumer<LocaleProvider>(
        builder: (context, provider, _) => DynamicColorBuilder(
          builder: (ColorScheme? light, ColorScheme? dark) => MaterialApp(
            navigatorKey: navigatorKey,
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
                initializeDateFormatting(deviceLocale?.languageCode);
                return deviceLocale;
              }

              initializeDateFormatting(DefaultValues.language);
              return const Locale("en", "GB");
            },
            locale: provider.locale,
            debugShowCheckedModeBanner: false,
            initialRoute: widget.initialRoute,
            onGenerateRoute: (RouteSettings settings) {
              lightHaptics();
              return createRoute(settings);
            },
            onGenerateInitialRoutes: (initialRoute) {
              return [
                createRoute(RouteSettings(name: initialRoute)),
              ];
            },
          ),
        ),
      ),
    );
  }
}

Route<dynamic> createRoute(RouteSettings settings) {
  Widget route;

  switch (settings.name) {
    case "/setupFirst":
      route = const SetupPage(dismissible: false);
    case "/setup":
      route = const SetupPage();
    case "/settings":
      route = const SettingsPage();
    case "/subjectEdit":
      final CreationType type = (settings.arguments as CreationType?) ?? CreationType.edit;
      route = SubjectEditRoute(creationType: type);
    case "/subject":
    case "/chart":
      if (settings.arguments == null) {
        throw ArgumentError("No arguments passed to route");
      }

      final List<Subject?> arguments = settings.arguments! as List<Subject?>;
      final Subject subject = arguments[1]!;

      route = RouteWidget(
        routeType: settings.name == "/subject" ? RouteType.subject : RouteType.chart,
        title: subject.name,
        arguments: arguments,
      );
    case "/years":
      route = const YearRoute();
    case "/":
    default:
      mainRouteKey = GlobalKey();
      route = RouteWidget(
        key: mainRouteKey,
        routeType: RouteType.home,
        title: translations.subjectOther,
      );
      break;
  }

  return MaterialPageRoute(
    builder: (context) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setSystemStyle(Theme.of(context));
      });

      return Material(
        child: route,
      );
    },
    settings: settings,
  );
}

Future<void> setOptimalDisplayMode() async {
  if (!isAndroid) return;
  final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
  if (androidInfo.version.sdkInt < 23) return;

  await FlutterDisplayMode.setHighRefreshRate();
}

Future<void> setSystemStyle(ThemeData theme) async {
  if (isAndroid) {
    final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    final bool edgeToEdge = androidInfo.version.sdkInt >= 29;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: edgeToEdge ? Colors.transparent : theme.colorScheme.surface,
        systemNavigationBarDividerColor: edgeToEdge ? Colors.transparent : theme.colorScheme.surface,
        systemNavigationBarContrastEnforced: true,
        systemNavigationBarIconBrightness: theme.brightness == Brightness.light ? Brightness.dark : Brightness.light,
      ),
    );
  } else {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
  }
}
