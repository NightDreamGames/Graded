import 'dart:developer';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gradely/Misc/storage.dart';

import '../Calculations/manager.dart';
import '../Calculations/subject.dart';
import '../Calculations/year.dart';

class ExcelParser {
  static List<List<String>> classes = [[], []];
  static List<Map<String, String>> classMap = [{}, {}];

  static String classicPath = "assets/Classique.xlsx";
  static String generalPath = "assets/General.xlsx";

  static List<Excel?> excelFiles = [null, null];

  static List<bool> loaded = [false, false];

  static Map<String, String> getYears() {
    return {
      "7e": "7e",
      "6e": "6e",
      "5e": "5e",
      "4e": "4e",
      "3e": "3e",
      "2e": "2e",
      "1e": "1e",
    };
  }

  static Map<String, String> getSections1(String year) {
    //if (Storage.getPreference("school_system", "classic") == "classic")
    return {
      "7e": "7e",
      "6e": "6e",
      "5e": "5e",
      "4e": "4e",
      "3e": "3e",
      "2e": "2e",
      "1e": "1e",
    };
  }

  static Future<Map<String, String>> getClassNames(String system) async {
    int index = system == "classic" ? 0 : 1;
    if (loaded[index]) return classMap[index];

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
    return classMap[index];
  }

  static void fillSubjects() {
    Manager.termTemplate.clear();
    String variant = Storage.getPreference("variant", defaultValues["variant"]);

    int position = 4;

    switch (variant) {
      case "latin":
        position = 6;
        break;
      case "chinese":
        position = 8;
        break;
    }

    int index = Storage.getPreference("lux_system", defaultValues["lux_system"]) == "classic" ? 0 : 1;

    classes[index] = excelFiles[index]!.sheets.keys.toList();

    Sheet sheet = excelFiles[index]!.sheets[Storage.getPreference("class", defaultValues["class"])]!;

    for (int i = 1; i < sheet.maxRows; i++) {
      if (sheet.row(i)[position] != null) {
        String name = sheet.row(i)[0]!.value.toString();
        double coefficient = double.tryParse(sheet.row(i)[position]!.value.toString()) ?? 1;

        Manager.termTemplate.add(Subject(name, coefficient));
      }
    }
  }
}
