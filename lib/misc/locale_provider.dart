// Package imports:
import "package:intl/locale.dart" as intl;
import "package:material_ui/material_ui.dart";

// Project imports:
import "package:graded/l10n/generated/l10n.dart";
import "package:graded/misc/default_values.dart";

class LocaleProvider with ChangeNotifier {
  LocaleProvider(String localeName) {
    setLocale(localeName);
  }

  Locale? locale;

  void setLocale(String localeName) {
    final intl.Locale? parsedLocale = localeName != DefaultValues.language ? intl.Locale.tryParse(localeName) : null;
    final Locale? loc = parsedLocale != null ? Locale(parsedLocale.languageCode, parsedLocale.countryCode) : null;

    if (!TranslationsClass.delegate.supportedLocales.contains(loc)) return;
    locale = loc;
    notifyListeners();
  }

  void clearLocale() {
    locale = null;
    notifyListeners();
  }
}
