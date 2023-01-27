// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import '../Misc/storage.dart';
import 'calculation_object.dart';

class Calculator {
  static void sortObjects(List<CalculationObject> data, int sortMode, {int? sortModeOverride}) {
    if (data.length >= 2) {
      switch (sortModeOverride ?? getPreference<int>("sort_mode$sortMode")) {
        case 0:
          insertionSort(data, compare: (CalculationObject a, CalculationObject b) => a.processedName.compareTo(b.processedName));
          break;
        case 1:
          insertionSort(data, compare: (CalculationObject a, CalculationObject b) {
            if (a.result == null && b.result == null) {
              return 0;
            } else if (b.result == null) {
              return -1;
            } else if (a.result == null) {
              return 1;
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

    bool empty = true;
    double numerator = 0;
    double denominator = 0;

    for (CalculationObject c in data) {
      if (c.value1 != null && c.value2 != 0) {
        empty = false;
        numerator += c.value1!;
        denominator += c.value2;
      }
    }

    double result = numerator * (getPreference<double>("total_grades") / denominator) + bonus;

    if (!empty) {
      return Calculator.round(result);
    } else {
      return null;
    }
  }

  static double round(double number) {
    String roundingMode = getPreference<String>("rounding_mode");
    int roundTo = getPreference<int>("round_to");

    double a = number * roundTo;

    if (roundingMode == "rounding_up") {
      return a.ceilToDouble() / roundTo;
    } else if (roundingMode == "rounding_down") {
      return a.floorToDouble() / roundTo;
    } else {
      double i = a.floorToDouble();
      double f = number - i;

      if (roundingMode == "rounding_half_up") {
        return (f < 0.5 ? i : i + 1) / roundTo;
      } else if (roundingMode == "rounding_half_down") {
        return (f <= 0.5 ? i : i + 1) / roundTo;
      }
    }

    return number;
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
    if (d % 1 == 0) {
      result = d.toStringAsFixed(0);
    } else {
      result = d.toString();
    }

    if (!ignoreZero && d > 0 && d < 10 && d % 1 == 0) {
      result = "0$result";
    }

    return result;
  }
}
