// Dart imports:
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

// Package imports:
import 'package:excel/excel.dart';

// Project imports:
import '../Calculations/calculator.dart';
import '../Calculations/manager.dart';
import '../Calculations/subject.dart';
import '../Translations/translations.dart';
import 'compatibility.dart';
import 'storage.dart';

class SetupManager {
  static String classicPath = "assets/class_data/Classique.xlsx";
  static String generalPath = "assets/class_data/General.xlsx";

  static List<Excel?> excelFiles = [null, null];

  static bool loaded = false;

  static Map<String, String> getYears = {
    "7C": "7e",
    "6C": "6e",
    "5C": "5e",
    "4C": "4e",
    "3C": "3e",
    "2C": "2e",
    "1C": "1e",
  };

  static bool hasSections(String year) {
    String luxSystem = Storage.getPreference("lux_system");

    if (luxSystem.isEmpty) {
      return false;
    } else if (luxSystem == "classic") {
      if (year.isEmpty) {
        return false;
      } else if (int.parse(year.substring(0, 1)) <= 3) {
        return true;
      }
      return false;
    } else {
      return false;
      //throw UnimplementedError();
    }
  }

  static Map<String, String> getSections() {
    if (Storage.getPreference("lux_system") == "classic") {
      return {
        "A": Translations.section_classic_a,
        "B": Translations.section_classic_b,
        "C": Translations.section_classic_c,
        "D": Translations.section_classic_d,
        "E": Translations.section_classic_e,
        "F": Translations.section_classic_f,
        "G": Translations.section_classic_g,
        "I": Translations.section_classic_i,
      };
    } else {
      throw UnimplementedError();
    }
  }

  static bool hasVariants(String year) {
    String luxSystem = Storage.getPreference("lux_system");

    if (luxSystem.isEmpty) {
      return false;
    } else if (luxSystem == "classic") {
      if (year.isEmpty) {
        return false;
      }
      return year != "7C";
    } else {
      return false;
      //throw UnimplementedError();
    }
  }

  static Map<String, String> getVariants(String year) {
    String luxSystem = Storage.getPreference("lux_system");

    if (luxSystem.isEmpty) {
      return {};
    } else if (luxSystem == "classic") {
      if (!hasVariants(year)) {
        return {};
      }

      Map<String, String> result = <String, String>{};
      if (year == "1C") {
        result["basic"] = Translations.basic;
        result["latin"] = Translations.latin;
      } else {
        result["basic"] = Translations.basic;
        result["latin"] = Translations.latin;
        result["chinese"] = Translations.chinese;
      }

      return result;
    } else {
      throw UnimplementedError();
    }
  }

  static Future<void> readFiles() async {
    if (loaded) return;

    //TODO Change when general system is supported
    //for (var index = 0; index < 2; index++) {
    for (var index = 0; index < 1; index++) {
      String file = index == 1 ? generalPath : classicPath;

      ByteData data = await rootBundle.load(file);
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      excelFiles[index] = Excel.decodeBytes(bytes);
    }

    loaded = true;
  }

  static Future<void> completeSetup() async {
    if (Storage.getPreference("school_system") == "lux") {
      if (Storage.getPreference("lux_system") == "classic") {
        if (!hasSections(Storage.getPreference("year"))) {
          Storage.setPreference<String>("section", defaultValues["section"]);
        }
        if (!hasVariants(Storage.getPreference("year")) || getVariants(Storage.getPreference("year"))[Storage.getPreference("variant")] == null) {
          Storage.setPreference<String>("variant", defaultValues["variant"]);
        }

        if (Storage.getPreference("year") == "1C") {
          Storage.setPreference("term", 2);
        } else {
          Storage.setPreference("term", 3);
        }
      }

      Storage.setPreference<double>("total_grades", 60);
      Storage.setPreference("rounding_mode", "rounding_up");
      Storage.setPreference("round_to", 1);

      await fillSubjects();
    }

    Compatibility.termCount();
    Manager.clear();
    Manager.calculate();

    Storage.setPreference<bool>("is_first_run", false);
  }

  static Future<void> fillSubjects() async {
    await readFiles();

    Manager.termTemplate.clear();
    String variant = Storage.getPreference("variant");

    int position = 4;

    switch (variant) {
      case "latin":
        position = 6;
        break;
      case "chinese":
        position = 8;
        break;
    }

    int index = Storage.getPreference("lux_system") == "classic" ? 0 : 1;

    String className = Storage.getPreference("year") + Storage.getPreference("section");
    Sheet sheet = excelFiles[index]!.sheets[className]!;

    for (int i = 1; i < sheet.maxRows; i++) {
      if (sheet.row(i)[position] != null) {
        String name = sheet.row(i)[0]!.value.toString();
        double coefficient = Calculator.tryParse(sheet.row(i)[position]!.value.toString()) ?? 1;

        Manager.termTemplate.add(Subject(name, coefficient));
      }
    }
  }
}
