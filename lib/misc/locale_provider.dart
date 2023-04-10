// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../translations/translations.dart';

class LocaleProvider with ChangeNotifier {
  LocaleProvider({this.locale});

  Locale? locale;

  void setLocale(Locale loc) {
    if (!TranslationsDelegate.supportedLocals.contains(loc)) return;
    locale = loc;
    notifyListeners();
  }

  void clearLocale() {
    locale = null;
    notifyListeners();
  }
}
