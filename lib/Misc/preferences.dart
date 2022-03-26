import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class Preferences {
  static void setPreference(String key, dynamic value) async {
    if (value is int) {
      await Settings.setValue<int>(key, value);
    } else if (value is String) {
      await Settings.setValue<String>(key, value);
    }
  }
}
