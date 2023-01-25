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

    setPreference<String?>("data", elements["data"]);
    setPreference<String?>("default_data", elements["default_data"]);
    setPreference<int?>("data_version", int.tryParse(elements["data_version"] ?? "-1"));
    setPreference<String?>("rounding_mode", elements["rounding_mode"]);

    String theme = "system";
    switch (elements["dark_theme"]) {
      case "on":
        theme = "dark";
        break;
      case "off":
        theme = "light";
        break;
    }
    setPreference<String?>("theme", theme);

    setPreference<String?>("school_system", elements["school_system"]);

    setPreference<int?>("round_to", int.tryParse(elements["round_to"] ?? defaultValues["round_to"].toString()));

    double totalGrades = double.parse(elements["total_grades"] ?? defaultValues["total_grades"].toString());
    if (totalGrades == -1) {
      totalGrades = double.parse(elements["custom_grade"] ?? defaultValues["total_grades"].toString());
    }
    setPreference<double>("total_grades", totalGrades);

    setPreference<bool>("is_first_run", elements["isFirstRun"]?.toLowerCase() == 'true');

    if (existsPreference("period")) {
      elements.update("term", (value) => elements["period"]?.replaceFirst("period", "term") ?? defaultValues["term"]);
    }
    switch (elements["term"]) {
      case "term_trimester":
        setPreference<int>("term", 3);
        break;
      case "term_semester":
        setPreference<int>("term", 2);
        break;
      case "term_year":
        setPreference<int>("term", 1);
        break;
      default:
        setPreference<int>("term", defaultValues["term"]);
        break;
    }

    setPreference<int?>("sort_mode1", int.tryParse(elements["sort_mode"] ?? defaultValues["sort_mode1"].toString()));
    setPreference<int?>("sort_mode1", int.tryParse(elements["sort_mode1"] ?? defaultValues["sort_mode1"].toString()));
    setPreference<int?>("sort_mode2", int.tryParse(elements["sort_mode2"] ?? defaultValues["sort_mode2"].toString()));
    setPreference<int?>("sort_mode3", int.tryParse(elements["sort_mode3"] ?? defaultValues["sort_mode3"].toString()));
    setPreference<int?>("current_term", int.tryParse(elements["current_period"] ?? defaultValues["current_term"].toString()));
    setPreference<int?>("current_term", int.tryParse(elements["current_term"] ?? defaultValues["current_term"].toString()));

    file.delete();
  }

  static Future<void> upgradeDataVersion() async {
    int currentDataVersion = getPreference<int>("data_version");

    if (getPreference<bool>("is_first_run")) {
      try {
        await importPreferences();
      } catch (e) {
        log("Error while importing old data: $e");
      }
    }

    if (currentDataVersion < 2) {
      periodPreferences();
    }

    await deserialize();

    if (currentDataVersion < 5) {
      termCount();

      setPreference("language", defaultValues["language"]);
    }

    if (currentDataVersion < 6) {
      String variant = getPreference("variant");
      String newVariant = "";
      if (variant == "latin") {
        newVariant = "L";
      } else if (variant == "chinese") {
        newVariant = "ZH";
      }
      setPreference("variant", newVariant);

      String year = getPreference("year", defaultValue: "");
      setPreference<int>("year", year.isNotEmpty ? int.parse(year.substring(0, 1)) : -1);

      setPreference("validated_school_system", getPreference("school_system"));
      setPreference("validated_lux_system", getPreference("lux_system"));
      setPreference("validated_year", getPreference("year"));
      setPreference("validated_section", getPreference("section"));
      setPreference("validated_variant", getPreference("variant"));
    }

    setPreference<int>("data_version", dataVersion);
  }

  static void termCount() {
    int newValue = getPreference("term");

    while (Manager.getCurrentYear().terms.length > newValue) {
      Manager.getCurrentYear().terms.removeLast();
    }

    while (Manager.getCurrentYear().terms.length < newValue) {
      Manager.getCurrentYear().terms.add(Term());
    }

    if (Manager.currentTerm >= Manager.getCurrentYear().terms.length) {
      Manager.currentTerm = 0;
      setPreference<int>("current_term", Manager.currentTerm);
    }

    if (newValue == 1) {
      Manager.currentTerm = 0;
    }
    serialize();
  }

  static void periodPreferences() {
    if (!getPreference<bool>("is_first_run") && getPreference<int>("data_version") < 2) {
      if (existsPreference("data")) {
        setPreference<String?>("data", getPreference("data").replaceAll("period", "term").replaceAll("mark", "grade"));
        setPreference<String?>("default_data", getPreference("default_data").replaceAll("period", "term").replaceAll("mark", "grade"));
      }
    }
  }
}
