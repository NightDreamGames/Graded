import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;

class ExcelParser {
  static List<List<String>> classes = [[], []];
  static List<Map<String, String>> classMap = [{}, {}];

  static String classicPath = "assets/Classique.xlsx";
  static String generalPath = "assets/General.xlsx";

  static List<bool> loaded = [false, false];

  static Future<Map<String, String>> getClassNames(String system) async {
    int index = system == "classic" ? 0 : 1;
    if (loaded[index]) return classMap[index];

    String file = index == 1 ? generalPath : classicPath;

    ByteData data = await rootBundle.load(file);
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = Excel.decodeBytes(bytes);

    classes[index] = excel.sheets.keys.toList();

    for (var element in classes[index]) {
      if (element.length > 5) {
        classes[index].remove(element);
      }
    }
    print(classes[index]);
    classes[index].sort((a, b) {
      return a.substring(0, 0).compareTo(b.substring(0, 0));
    });
    print(classes[index]);

    for (var e in classes[index]) {
      classMap[index][e] = e;
    }

    loaded[index] = true;
    return classMap[index];
  }
}
