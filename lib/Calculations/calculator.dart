// Package imports:
import 'package:collection/collection.dart';
import 'package:diacritic/diacritic.dart';
import 'package:sprintf/sprintf.dart';

// Project imports:
import 'package:gradely/Calculations/calculation_object.dart';
import '../Misc/storage.dart';
import 'manager.dart';

class Calculator {
  static void sortObjects(List<CalculationObject> data, int sortMode, {int? sortModeOverride}) {
    if (data.length >= 2) {
      switch (sortModeOverride ?? Storage.getPreference<int>("sort_mode$sortMode")) {
        case 0:
          insertionSort(data,
              compare: (CalculationObject a, CalculationObject b) => removeDiacritics(a.name.toLowerCase())
                  .replaceAll("[^\\p{ASCII}]", "")
                  .compareTo(removeDiacritics(b.name.toLowerCase()).replaceAll("[^\\p{ASCII}]", "")));
          break;
        case 1:
          insertionSort(data, compare: (CalculationObject a, CalculationObject b) {
            if (a.result == null && b.result == null) {
              return 0;
            } else if (b.result == null) {
              return 1;
            } else if (a.result == null) {
              return -1;
            }

            return b.result!.compareTo(a.result!);
          });
          break;
        case 2:
          insertionSort(data, compare: (CalculationObject a, CalculationObject b) => b.coefficient.compareTo(a.coefficient));
          break;
      }
    }
  }

  static double? calculate(List<CalculationObject> data, {int bonus = 0}) {
    if (data.isEmpty) {
      return null;
    }

    double numerator = 0;
    double denominator = 0;
    bool empty = true;

    for (CalculationObject c in data) {
      if (c.value1 != null) {
        empty = false;
        numerator += c.value1!;
        denominator += c.value2;
      }
    }

    double result = numerator * (Manager.totalGrades / denominator) + bonus;

    if (!empty) {
      return Calculator.round(result);
    } else {
      return null;
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

  static double? tryParse(String? input) {
    if (input == null) return null;
    return double.tryParse(input.replaceAll(",", ".").replaceAll(" ", ""));
  }

  static String format(double? d, {bool ignoreZero = false}) {
    if (d == null) {
      return "-";
    }

    String result;

    if (d == d.toInt()) {
      result = sprintf("%d", [d.toInt()]);
    } else {
      result = sprintf("%s", [d]);
    }

    if (!ignoreZero && d < 10 && d > 0 && d % 1 == 0) {
      return 0.toString() + result;
    } else {
      return result;
    }
  }
}
