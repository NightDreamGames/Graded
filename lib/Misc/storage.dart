import 'dart:convert';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

import '../Calculations/manager.dart';
import '../Calculations/subject.dart';
import '../Calculations/year.dart';

class Storage {
  static void serialize() {
    setPreference("data", jsonEncode(Manager.years));
    setPreference("default_data", jsonEncode(Manager.termTemplate));
  }

  static String serializeString(Map<String, dynamic> map) {
    return jsonEncode(map);
  }

  static void deserialize() {
    if (existsPreference("data")) {
      var data = jsonDecode(getPreference<String>("data", "")) as List;
      List<Year> _years = data.map((yearJson) => Year.fromJson(yearJson)).toList();
      Manager.years = _years;

      var _termTemplate = jsonDecode(getPreference<String>("default_data", "")) as List;
      List<Subject> __termTemplate = _termTemplate.map((templateJson) => Subject.fromJson(templateJson)).toList();
      Manager.termTemplate = __termTemplate;
    }
  }

  static void setPreference(String key, dynamic value) {
    if (value is int) {
      Settings.setValue<int>(key, value);
    } else if (value is String) {
      Settings.setValue<String>(key, value);
    }
  }

  static T getPreference<T>(String key, dynamic defaultValue) {
    return Settings.getValue<T>(key, defaultValue);
  }

  static bool existsPreference(String key) {
    return Settings.containsKey(key)!;
  }
}
