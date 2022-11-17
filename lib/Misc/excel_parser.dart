// Dart imports:
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:excel/excel.dart';

// Project imports:
import 'package:gradely/Misc/storage.dart';
import '../Calculations/manager.dart';
import '../Calculations/subject.dart';
import '../Translation/translations.dart';

class ExcelParser {
  static List<List<String>> classes = [[], []];
  static List<Map<String, String>> classMap = [{}, {}];

  static String classicPath = "assets/Classique.xlsx";
  static String generalPath = "assets/General.xlsx";

  static List<Excel?> excelFiles = [null, null];

  static List<bool> loaded = [false, false];

  static Map<String, String> years = {
    "7C": "7e",
    "6C": "6e",
    "5C": "5e",
    "4C": "4e",
    "3C": "3e",
    "2C": "2e",
    "1C": "1e",
  };

  static Map<String, String> getSections(BuildContext context) {
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

  static void fillClassNames() async {
    String system = Storage.getPreference("lux_system");

    int index = system == "classic" ? 0 : 1;
    if (loaded[index]) return;

    String file = index == 1 ? generalPath : classicPath;

    ByteData data = await rootBundle.load(file);
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    excelFiles[index] = Excel.decodeBytes(bytes);

    classes[index] = excelFiles[index]!.sheets.keys.toList();

    for (int i = 0; i < classes[index].length; i++) {
      if (classes[index][i].length > 5) {
        classes[index].removeAt(i);
        i--;
      }
    }

    List<String> tmpClasses = [];
    tmpClasses.addAll(classes[index]);
    classes[index].clear();
    classes[index].addAll(tmpClasses.reversed);

    /*print(classes[index]);
    classes[index].sort((a, b) {
      return b.compareTo(a);
    });
    print(classes[index]);*/

    for (var e in classes[index]) {
      classMap[index][e] = e;
    }

    loaded[index] = true;
  }

  static void fillSubjects() {
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

    classes[index] = excelFiles[index]!.sheets.keys.toList();

    String className = Storage.getPreference("year") + Storage.getPreference("section");
    Sheet sheet = excelFiles[index]!.sheets[className]!;

    for (int i = 1; i < sheet.maxRows; i++) {
      if (sheet.row(i)[position] != null) {
        String name = sheet.row(i)[0]!.value.toString();
        double coefficient = double.tryParse(sheet.row(i)[position]!.value.toString()) ?? 1;

        Manager.termTemplate.add(Subject(name, coefficient));
      }
    }
  }
}
