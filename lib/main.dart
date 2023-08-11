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
import "package:graded/calculations/subject.dart";
import "package:graded/calculations/term.dart";
import "package:graded/localization/generated/l10n.dart";
import "package:graded/localization/material_localization/lb_intl.dart";
import "package:graded/localization/translations.dart";
import "package:graded/misc/default_values.dart";
import "package:graded/misc/enums.dart";
import "package:graded/misc/locale_provider.dart";
import "package:graded/misc/storage.dart";
import "package:graded/ui/routes/home_route.dart";
import "package:graded/ui/routes/main_route.dart";
import "package:graded/ui/routes/settings_route.dart";
import "package:graded/ui/routes/setup_route.dart";
import "package:graded/ui/routes/subject_edit_route.dart";
import "package:graded/ui/routes/subject_route.dart";
import "package:graded/ui/routes/year_route.dart";
import "package:graded/ui/settings/flutter_settings_screens.dart";
import "package:graded/ui/utilities/app_theme.dart";

final GlobalKey appContainerKey = GlobalKey();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Settings.init();

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
            onGenerateRoute: createRoute,
            onGenerateInitialRoutes: (initialRoute) {
              Manager.init();

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

  int tabAmount = getPreference<int>("term");
  if (getPreference<int>("validated_year") == 1) tabAmount++;
  if (tabAmount > 1) tabAmount++;

  switch (settings.name) {
    case "setup_first":
      route = const SetupPage(dismissible: false);
    case "/setup":
      route = const SetupPage();
    case "/settings":
      route = const SettingsPage();
    case "/subject_edit":
      CreationType type = (settings.arguments as CreationType?) ?? CreationType.edit;
      route = SubjectEditRoute(creationType: type);
    case "/subject":
      if (settings.arguments == null) {
        throw ArgumentError("No arguments passed to route");
      }

      List<Subject?> arguments = settings.arguments! as List<Subject?>;
      Subject? parent = arguments[0];
      Subject subject = arguments[1]!;

      List<Widget> children = List.generate(tabAmount, (index) {
        Term term = getTerm(index);
        Subject? newParent = parent != null ? term.subjects.firstWhere((element) => element.name == parent.name) : null;
        Subject newSubject = newParent != null
            ? newParent.children.firstWhere((element) => element.name == subject.name)
            : term.subjects.firstWhere((element) => element.name == subject.name);

        return SubjectRoute(key: GlobalKey(), term: term, parent: newParent, subject: newSubject);
      });

      route = RouteWidget(
        routeType: RouteType.subject,
        title: subject.name,
        children: children,
      );
    case "/years":
      route = const YearRoute();
    case "/":
    default:
      List<Widget> children = List.generate(
        tabAmount,
        (index) => HomePage(key: GlobalKey(), term: getTerm(index)),
      );

      route = RouteWidget(
        routeType: RouteType.home,
        title: translations.subjects,
        children: children,
      );
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
}

Future<void> setOptimalDisplayMode() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

  if (!Platform.isAndroid || androidInfo.version.sdkInt < 23) return;

  await FlutterDisplayMode.setHighRefreshRate();
}
