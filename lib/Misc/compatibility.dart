// Dart imports:
import 'dart:async';
import 'dart:developer';
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

// Project imports:
import '../Calculations/manager.dart';
import '../Calculations/term.dart';
import 'storage.dart';

class Compatibility {
  static const dataVersion = 6;

  static Future<void> importPreferences() async {
    Uri uri;

    if (kDebugMode) {
      uri = Uri.file("${(await getApplicationDocumentsDirectory()).parent.path}/shared_prefs/com.NightDreamGames.Grade.ly.debug_preferences.xml");
    } else {
      uri = Uri.file("${(await getApplicationDocumentsDirectory()).parent.path}/shared_prefs/com.NightDreamGames.Grade.ly_preferences.xml");
    }

    if (!await File.fromUri(uri).exists()) return;

    File file = File.fromUri(uri);
    XmlDocument xml = XmlDocument.parse(file.readAsStringSync());

    List<String> keys = <String>[];
    List<String> values = <String>[];

    xml.findAllElements("string").map((e) => e.getAttribute("name")!).forEach(keys.add);
    xml.findAllElements("string").map((e) => e.text).forEach(values.add);

    Map<String, String> elements = {for (int i = 0; i < keys.length; i++) keys[i]: values[i]};

    Storage.setPreference<String?>("data", elements["data"]);
    Storage.setPreference<String?>("default_data", elements["default_data"]);
    Storage.setPreference<int?>("data_version", int.tryParse(elements["data_version"] ?? "-1"));
    Storage.setPreference<String?>("rounding_mode", elements["rounding_mode"]);

    String theme = "system";
    switch (elements["dark_theme"]) {
      case "on":
        theme = "dark";
        break;
      case "off":
        theme = "light";
        break;
    }
    Storage.setPreference<String?>("theme", theme);

    Storage.setPreference<String?>("school_system", elements["school_system"]);

    Storage.setPreference<int?>("round_to", int.tryParse(elements["round_to"] ?? defaultValues["round_to"].toString()));

    double totalGrades = double.parse(elements["total_grades"] ?? defaultValues["total_grades"].toString());
    if (totalGrades == -1) {
      totalGrades = double.parse(elements["custom_grade"] ?? defaultValues["total_grades"].toString());
    }
    Storage.setPreference<double>("total_grades", totalGrades);

    Storage.setPreference<bool>("is_first_run", elements["isFirstRun"]?.toLowerCase() == 'true');

    if (Storage.existsPreference("period")) {
      elements.update("term", (value) => elements["period"]?.replaceFirst("period", "term") ?? defaultValues["term"]);
    }
    switch (elements["term"]) {
      case "term_trimester":
        Storage.setPreference<int>("term", 3);
        break;
      case "term_semester":
        Storage.setPreference<int>("term", 2);
        break;
      case "term_year":
        Storage.setPreference<int>("term", 1);
        break;
      default:
        Storage.setPreference<int>("term", defaultValues["term"]);
        break;
    }

    Storage.setPreference<int?>("sort_mode1", int.tryParse(elements["sort_mode"] ?? defaultValues["sort_mode1"].toString()));
    Storage.setPreference<int?>("sort_mode1", int.tryParse(elements["sort_mode1"] ?? defaultValues["sort_mode1"].toString()));
    Storage.setPreference<int?>("sort_mode2", int.tryParse(elements["sort_mode2"] ?? defaultValues["sort_mode2"].toString()));
    Storage.setPreference<int?>("sort_mode3", int.tryParse(elements["sort_mode3"] ?? defaultValues["sort_mode3"].toString()));
    Storage.setPreference<int?>("current_term", int.tryParse(elements["current_period"] ?? defaultValues["current_term"].toString()));
    Storage.setPreference<int?>("current_term", int.tryParse(elements["current_term"] ?? defaultValues["current_term"].toString()));

    file.delete();
  }

  static Future<void> upgradeDataVersion() async {
    int currentDataVersion = Storage.getPreference<int>("data_version");

    if (Storage.getPreference<bool>("is_first_run")) {
      try {
        await importPreferences();
      } catch (e) {
        log("Error while importing old data: $e");
      }
    }

    if (currentDataVersion < 2) {
      periodPreferences();
    }

    await Storage.deserialize();

    if (currentDataVersion < 5) {
      termCount();

      Storage.setPreference("language", defaultValues["language"]);
    }

    if (currentDataVersion < 6) {
      Storage.setPreference("validated_school_system", Storage.getPreference("school_system"));
      Storage.setPreference("validated_lux_system", Storage.getPreference("lux_system"));
      Storage.setPreference("validated_year", Storage.getPreference("year"));
      Storage.setPreference("validated_section", Storage.getPreference("section"));
      Storage.setPreference("validated_variant", Storage.getPreference("variant"));
    }

    Storage.setPreference<int>("data_version", dataVersion);
  }

  static void termCount() {
    int newValue = Storage.getPreference("term");

    while (Manager.getCurrentYear().terms.length > newValue) {
      Manager.getCurrentYear().terms.removeLast();
    }

    while (Manager.getCurrentYear().terms.length < newValue) {
      Manager.getCurrentYear().terms.add(Term());
    }

    if (Manager.currentTerm >= Manager.getCurrentYear().terms.length) {
      Manager.currentTerm = 0;
      Storage.setPreference<int>("current_term", Manager.currentTerm);
    }

    if (newValue == 1) {
      Manager.currentTerm = 0;
    }
    Storage.serialize();
  }

  static void periodPreferences() {
    if (!Storage.getPreference<bool>("is_first_run") && Storage.getPreference<int>("data_version") < 2) {
      if (Storage.existsPreference("data")) {
        Storage.setPreference<String?>("data", Storage.getPreference("data").replaceAll("period", "term").replaceAll("mark", "grade"));
        Storage.setPreference<String?>(
            "default_data", Storage.getPreference("default_data").replaceAll("period", "term").replaceAll("mark", "grade"));
      }
    }
  }
}
