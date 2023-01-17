// Dart imports:
import 'dart:convert';

// Project imports:
import '../Calculations/manager.dart';
import '../Calculations/subject.dart';
import '../Calculations/year.dart';
import '/UI/Settings/flutter_settings_screens.dart';

final Map<String, dynamic> defaultValues = {
  //System
  "data": "",
  "default_data": "",
  "current_term": 0,
  "last_term": 0,
  "sort_mode1": 0,
  "sort_mode2": 0,
  "sort_mode3": 0,
  "data_version": -1,
  //Calculation settings
  "term": 3,
  "total_grades": 60.0,
  "rounding_mode": "rounding_up",
  "round_to": 1,
  //Setup
  "school_system": "",
  "lux_system": "",
  "year": "",
  "section": "",
  "variant": "basic",
  "is_first_run": true,
  //App settings
  "theme": "system",
  "brightness": "dark",
  "language": "system",
};

class Storage {
  static void serialize() {
    setPreference<String?>("data", jsonEncode(Manager.years));
    setPreference<String?>("default_data", jsonEncode(Manager.termTemplate));
  }

  static String serializeString(Map<String, dynamic> map) {
    return jsonEncode(map);
  }

  static Future<void> deserialize() async {
    if (existsPreference("data")) {
      try {
        var termTemplateList = jsonDecode(getPreference<String>("default_data")) as List;
        Manager.termTemplate = termTemplateList.map((templateJson) => Subject.fromJson(templateJson)).toList();

        var data = jsonDecode(getPreference<String>("data")) as List;
        Manager.years = data.map((yearJson) => Year.fromJson(yearJson)).toList();
      } catch (e) {
        Manager.deserializationError = true;
        Manager.clear();
      }
    }
  }

  static void setPreference<T>(String key, T value) {
    Settings.setValue<T>(key, value);
  }

  static T getPreference<T>(String key, {T? defaultValue}) {
    return Settings.getValue<T>(key, defaultValue ?? defaultValues[key]);
  }

  static bool existsPreference(String key) {
    return Settings.containsKey(key)!;
  }
}
