import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:gradely/Misc/storage.dart';
import 'package:xml/xml.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../Calculations/manager.dart';
import '../Calculations/term.dart';

//TODO handle data_version
class Compatibility {
  static Future<void> importPreferences() async {
    //TODO change file path
    var uri = Uri.file((await getApplicationDocumentsDirectory()).parent.path + "/shared_prefs/com.NightDreamGames.Grade.ly.debug_preferences.xml");

    if (!await File.fromUri(uri).exists()) return;

    File file = File.fromUri(uri);
    XmlDocument xml = XmlDocument.parse(file.readAsStringSync());

    //TODO remove test statement
    /*String xmlString = '''<?xml version="1.0" encoding="utf-8" standalone="yes" ?>
    <map>

    </map>''';

    XmlDocument xml = XmlDocument.parse(xmlString);
    */

    List<String> keys = <String>[];
    List<String> values = <String>[];

    xml.findAllElements("string").map((e) => e.getAttribute("name")!).forEach(keys.add);
    xml.findAllElements("string").map((e) => e.text).forEach(values.add);

    var elements = {for (int i = 0; i < keys.length; i++) keys[i]: values[i]};

    Storage.setPreference("data", elements["data"]);
    Storage.setPreference("default_data", elements["default_data"]);
    Storage.setPreference("data_version", int.tryParse(elements["data_version"] ?? "-1"));
    Storage.setPreference("rounding_mode", elements["rounding_mode"]);
    Storage.setPreference("language", elements["language"]);
    Storage.setPreference("dark_theme", elements["dark_theme"]);
    Storage.setPreference("variant", elements["variant"]);
    Storage.setPreference("school_system", elements["school_system"]);
    Storage.setPreference("class", elements["class"]);

    Storage.setPreference("round_to", int.tryParse(elements["round_to"] ?? defaultValues["round_to"].toString()));

    double totalGrades = double.parse(elements["total_grades"] ?? defaultValues["total_grades"].toString());
    if (totalGrades == -1) {
      totalGrades = double.parse(elements["custom_grade"] ?? defaultValues["total_grades"].toString());
    }
    Storage.setPreference("total_grades", totalGrades);

    Storage.setPreference("isFirstRun", elements["isFirstRun"]?.toLowerCase() == 'true');

    if (Storage.existsPreference("period")) {
      elements.update("term", (value) => elements["period"]?.replaceFirst("period", "term") ?? defaultValues["term"]);
    }
    switch (elements["term"]) {
      case "term_trimester":
        Storage.setPreference("term", 3);
        break;
      case "term_semester":
        Storage.setPreference("term", 2);
        break;
      case "term_year":
        Storage.setPreference("term", 1);
        break;
      default:
        Storage.setPreference("term", defaultValues["term"]);
        break;
    }

    Storage.setPreference("sort_mode1", int.tryParse(elements["sort_mode"] ?? defaultValues["sort_mode1"].toString()));
    Storage.setPreference("sort_mode1", int.tryParse(elements["sort_mode1"] ?? defaultValues["sort_mode1"].toString()));
    Storage.setPreference("sort_mode2", int.tryParse(elements["sort_mode2"] ?? defaultValues["sort_mode2"].toString()));
    Storage.setPreference("sort_mode3", int.tryParse(elements["sort_mode3"] ?? defaultValues["sort_mode3"].toString()));
    Storage.setPreference("current_term", int.tryParse(elements["current_period"] ?? defaultValues["current_term"].toString()));
    Storage.setPreference("current_term", int.tryParse(elements["current_term"] ?? defaultValues["current_term"].toString()));

    upgradeDataVersion();

    file.delete();
  }

  static void upgradeDataVersion() {
    if (Storage.getPreference<int>("data_version", -1) < 2) {
      termCount(newValue: Storage.getPreference("term", defaultValues["term"]));
      periodPreferences();
    }

    Storage.setPreference("data_version", DATA_VERSION);
  }

  static void termCount({int newValue = 0}) {
    while (Manager.getCurrentYear().terms.length > newValue) {
      Manager.getCurrentYear().terms.removeLast();
    }

    while (Manager.getCurrentYear().terms.length < newValue) {
      Manager.getCurrentYear().terms.add(Term());
    }

    if (Manager.currentTerm >= Manager.getCurrentYear().terms.length) {
      Manager.currentTerm = 0;
      Storage.setPreference("current_term", Manager.currentTerm);
    }

    Manager.calculate();
    Storage.serialize();
  }

  static void periodPreferences() {
    if (!Storage.getPreference<bool>("isFirstRun", true) && Storage.getPreference<int>("data_version", -1) < 2) {
      if (Storage.existsPreference("data")) {
        Storage.setPreference("data", Storage.getPreference("data", "").replaceAll("period", "term").replaceAll("mark", "grade"));
        Storage.setPreference("default_data", Storage.getPreference("default_data", "").replaceAll("period", "term").replaceAll("mark", "grade"));
      }
    }
  }
}

/*
<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<map>
    <string name="sort_mode">1</string>
    <string name="data">[{&quot;result&quot;:19.0,&quot;terms&quot;:[{&quot;result&quot;:19.0,&quot;subjects&quot;:[{&quot;bonus&quot;:0,&quot;coefficient&quot;:3.0,&quot;name&quot;:&quot;Allemand&quot;,&quot;result&quot;:-1.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:3.0,&quot;name&quot;:&quot;Anglais&quot;,&quot;result&quot;:-1.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:2.0,&quot;name&quot;:&quot;Biologie&quot;,&quot;result&quot;:-1.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:2.0,&quot;name&quot;:&quot;Chimie&quot;,&quot;result&quot;:44.0,&quot;tests&quot;:[{&quot;grade1&quot;:85.0,&quot;grade2&quot;:60.0,&quot;name&quot;:&quot;Test 1&quot;},{&quot;grade1&quot;:2.5,&quot;grade2&quot;:60.0,&quot;name&quot;:&quot;Test 2&quot;}]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:2.0,&quot;name&quot;:&quot;Cours à option&quot;,&quot;result&quot;:-1.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:2.0,&quot;name&quot;:&quot;Éducation artistique&quot;,&quot;result&quot;:-1.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:1.0,&quot;name&quot;:&quot;Éducation physique et sportive&quot;,&quot;result&quot;:-1.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:3.0,&quot;name&quot;:&quot;Français&quot;,&quot;result&quot;:1.0,&quot;tests&quot;:[{&quot;grade1&quot;:1.0,&quot;grade2&quot;:60.0,&quot;name&quot;:&quot;Test 1&quot;}]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:2.0,&quot;name&quot;:&quot;Histoire&quot;,&quot;result&quot;:-1.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:3.0,&quot;name&quot;:&quot;Mathématiques&quot;,&quot;result&quot;:-1.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:2.0,&quot;name&quot;:&quot;Physique&quot;,&quot;result&quot;:-1.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:4.0,&quot;name&quot;:&quot;Sciences économiques et sociales&quot;,&quot;result&quot;:-1.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:2.0,&quot;name&quot;:&quot;Vie et société&quot;,&quot;result&quot;:-1.0,&quot;tests&quot;:[]}]},{&quot;result&quot;:-1.0,&quot;subjects&quot;:[{&quot;bonus&quot;:0,&quot;coefficient&quot;:3.0,&quot;name&quot;:&quot;Allemand&quot;,&quot;result&quot;:-1.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:3.0,&quot;name&quot;:&quot;Anglais&quot;,&quot;result&quot;:-1.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:2.0,&quot;name&quot;:&quot;Biologie&quot;,&quot;result&quot;:-1.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:2.0,&quot;name&quot;:&quot;Chimie&quot;,&quot;result&quot;:-1.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:2.0,&quot;name&quot;:&quot;Cours à option&quot;,&quot;result&quot;:-1.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:2.0,&quot;name&quot;:&quot;Éducation artistique&quot;,&quot;result&quot;:-1.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:1.0,&quot;name&quot;:&quot;Éducation physique et sportive&quot;,&quot;result&quot;:-1.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:3.0,&quot;name&quot;:&quot;Français&quot;,&quot;result&quot;:-1.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:2.0,&quot;name&quot;:&quot;Histoire&quot;,&quot;result&quot;:-1.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:3.0,&quot;name&quot;:&quot;Mathématiques&quot;,&quot;result&quot;:-1.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:2.0,&quot;name&quot;:&quot;Physique&quot;,&quot;result&quot;:-1.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:4.0,&quot;name&quot;:&quot;Sciences économiques et sociales&quot;,&quot;result&quot;:-1.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:2.0,&quot;name&quot;:&quot;Vie et société&quot;,&quot;result&quot;:-1.0,&quot;tests&quot;:[]}]}]}]</string>
    <string name="data_version">2</string>
    <string name="rounding_mode">rounding_up</string>
    <string name="language">default</string>
    <string name="dark_theme">auto</string>
    <string name="round_to">1</string>
    <string name="total_grades">-1</string>
    <string name="isFirstRun">false</string>
    <string name="custom_grade">60</string>
    <string name="variant">basic</string>
    <string name="term">term_semester</string>
    <string name="school_system">lux</string>
    <string name="class">3CD</string>
    <string name="default_data">[{&quot;bonus&quot;:0,&quot;coefficient&quot;:3.0,&quot;name&quot;:&quot;Allemand&quot;,&quot;result&quot;:0.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:3.0,&quot;name&quot;:&quot;Anglais&quot;,&quot;result&quot;:0.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:2.0,&quot;name&quot;:&quot;Biologie&quot;,&quot;result&quot;:0.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:2.0,&quot;name&quot;:&quot;Chimie&quot;,&quot;result&quot;:0.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:2.0,&quot;name&quot;:&quot;Cours à option&quot;,&quot;result&quot;:0.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:2.0,&quot;name&quot;:&quot;Éducation artistique&quot;,&quot;result&quot;:0.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:1.0,&quot;name&quot;:&quot;Éducation physique et sportive&quot;,&quot;result&quot;:0.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:3.0,&quot;name&quot;:&quot;Français&quot;,&quot;result&quot;:0.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:2.0,&quot;name&quot;:&quot;Histoire&quot;,&quot;result&quot;:0.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:3.0,&quot;name&quot;:&quot;Mathématiques&quot;,&quot;result&quot;:0.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:2.0,&quot;name&quot;:&quot;Physique&quot;,&quot;result&quot;:0.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:4.0,&quot;name&quot;:&quot;Sciences économiques et sociales&quot;,&quot;result&quot;:0.0,&quot;tests&quot;:[]},{&quot;bonus&quot;:0,&quot;coefficient&quot;:2.0,&quot;name&quot;:&quot;Vie et société&quot;,&quot;result&quot;:0.0,&quot;tests&quot;:[]}]</string>
    <string name="sort_mode1">0</string>
    <string name="current_term">0</string>
</map>
*/
