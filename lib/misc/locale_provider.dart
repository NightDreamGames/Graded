// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../localization/generated/l10n.dart';

class LocaleProvider with ChangeNotifier {
  LocaleProvider({this.locale});

  Locale? locale;

  void setLocale(Locale loc) {
    if (!TranslationsClass.delegate.supportedLocales.contains(loc)) return;
    locale = loc;
    notifyListeners();
  }

  void clearLocale() {
    locale = null;
    notifyListeners();
  }
}
