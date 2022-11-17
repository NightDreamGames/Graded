// Package imports:
import 'package:diacritic/diacritic.dart';
import 'package:sprintf/sprintf.dart';

// Project imports:
import '../Misc/storage.dart';
import 'subject.dart';
import 'test.dart';

class Calculator {
  static void sortSubjects(List<Subject> data, String sortMode, {int? sortModeOverride}) {
    if (data.length >= 2) {
      switch (sortModeOverride ?? Storage.getPreference<int>(sortMode)) {
        case 0:
          data.sort((o1, o2) => removeDiacritics(o1.name.toLowerCase())
              .replaceAll("[^\\p{ASCII}]", "")
              .compareTo(removeDiacritics(o2.name.toLowerCase()).replaceAll("[^\\p{ASCII}]", "")));
          break;
        case 1:
          data.sort((o1, o2) => o2.result.compareTo(o1.result));
          break;
        case 2:
          data.sort((o1, o2) => o2.coefficient.compareTo(o1.coefficient));
          break;
      }
    }
  }

  static void sortTests(List<Test> data) {
    if (data.length >= 2) {
      switch (Storage.getPreference<int>("sort_mode2")) {
        case 0:
          data.sort((o1, o2) => removeDiacritics(o1.name.toLowerCase())
              .replaceAll("[^\\p{ASCII}]", "")
              .compareTo(removeDiacritics(o2.name.toLowerCase()).replaceAll("[^\\p{ASCII}]", "")));
          break;
        case 1:
          data.sort((o1, o2) => (o2.grade1 / o2.grade2).compareTo(o1.grade1 / o1.grade2));
          break;
      }
    }
  }

  static double calculate(List<double> results, List<double> coefficients) {
    if (results.isEmpty) {
      return -1;
    }

    double a = 0;
    double b = 0;

    for (int i = 0; i < results.length; i++) {
      if (results[i] != -1) {
        a += results[i] * coefficients[i];
        b += coefficients[i];
      }
    }

    if (b > 0) {
      return round(a / b);
    } else {
      return -1;
    }
  }

  static double round(double number) {
    String roundingMode = Storage.getPreference<String>("rounding_mode");
    int roundTo = Storage.getPreference<int>("round_to");

    switch (roundingMode) {
      case "rounding_up":
        double a = number * roundTo;
        return a.ceilToDouble() / roundTo;
      case "rounding_down":
        double a = number * roundTo;
        return a.floorToDouble() / roundTo;
      case "rounding_half_up":
        double i = (number * roundTo).floorToDouble();
        double f = number - i;
        return (f < 0.5 ? i : i + 1) / roundTo;
      case "rounding_half_down":
        double i1 = (number * roundTo).floorToDouble();
        double f1 = number - i1;
        return (f1 <= 0.5 ? i1 : i1 + 1) / roundTo;
      default:
        return number;
    }
  }

  static String format(double n, {bool ignoreZero = false}) {
    String a;
    if (n == n.toInt()) {
      a = sprintf("%d", [n.toInt()]);
    } else {
      a = sprintf("%s", [n]);
    }
    if (!ignoreZero && n < 10 && n % 1 == 0) {
      return 0.toString() + a;
    } else {
      return a;
    }
  }
}
