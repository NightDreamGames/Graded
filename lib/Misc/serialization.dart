import 'dart:convert';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

import '../Calculations/manager.dart';
import '../Calculations/subject.dart';
import '../Calculations/year.dart';
import 'preferences.dart';

class Serialization {
  // TODO find replacement
  static void serialize() {
    String json = jsonEncode(Manager.years);
    print(json);
    Preferences.setPreference("data", jsonEncode(Manager.years));
    Preferences.setPreference("default_data", jsonEncode(Manager.termTemplate));
  }

  static String serializeString(Map<String, dynamic> map) {
    return jsonEncode(map);
  }

  static void deserialize() {
    if (Settings.containsKey("data")!) {
      List<dynamic> data = jsonDecode(Settings.getValue("data", ""));
      Manager.years = data.cast<Year>();

      List<dynamic> termTemplate = jsonDecode(Settings.getValue("default_data", ""));
      Manager.termTemplate = termTemplate.cast<Subject>();
    }

    /*if (Preferences.existsPreference("data")) {
            Manager.years = gson.fromJson(Preferences.getPreference("data", ""), new TypeToken<ArrayList<Year>>() {
            }.getType());

            Manager.termTemplate = gson.fromJson(Preferences.getPreference("default_data", ""), new TypeToken<ArrayList<Subject>>() {
            }.getType());


        }*/
  }
}
