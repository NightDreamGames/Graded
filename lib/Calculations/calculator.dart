// Dart imports:
import 'dart:math';

// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import '../Misc/storage.dart';
import 'calculation_object.dart';
import 'manager.dart';

abstract class SortMode {
  static const int name = 0;
  static const int result = 1;
  static const int coefficient = 2;
  static const int custom = 3;
}

abstract class SortType {
  static const int subject = 1;
  static const int test = 2;
}

abstract class RoundingMode {
  static const String up = "rounding_up";
  static const String down = "rounding_down";
  static const String halfUp = "rounding_half_up";
  static const String halfDown = "rounding_half_down";
}

class Calculator {
  static void sortObjects(List<CalculationObject> data, {required int sortType, int? sortModeOverride, List<CalculationObject>? comparisonData}) {
    if (data.length >= 2) {
      int sortMode = getPreference<int>("sort_mode$sortType");
      if (sortModeOverride != null && sortMode != SortMode.custom) {
        sortMode = sortModeOverride;
      }

      switch (sortMode) {
        case SortMode.name:
          insertionSort(data, compare: (CalculationObject a, CalculationObject b) => a.processedName.compareTo(b.processedName));
          break;
        case SortMode.result:
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
        case SortMode.coefficient:
          insertionSort(data, compare: (CalculationObject a, CalculationObject b) => b.coefficient.compareTo(a.coefficient));
          break;
        case SortMode.custom:
          var compare = comparisonData ?? Manager.termTemplate;
          data.sort((a, b) {
            return compare.indexWhere((element) => a.processedName == element.processedName) -
                compare.indexWhere((element) => b.processedName == element.processedName);
          });
          break;
      }
    }
  }

  static double? calculate(List<CalculationObject> data, {int bonus = 0, bool precise = false}) {
    if (data.isEmpty) {
      return null;
    }

    bool empty = true;
    double totalNumerator = 0;
    double totalDenominator = 0;

    for (CalculationObject c in data) {
      if (c.numerator != null && c.denominator != 0) {
        empty = false;
        totalNumerator += c.numerator! * c.coefficient;
        totalDenominator += c.denominator * c.coefficient;
      }
    }

    double result = totalNumerator * (getPreference<double>("total_grades") / totalDenominator) + bonus;

    return empty ? null : round(result, roundToOverride: precise ? 100 : null);
  }

  static double round(double n, {int? roundToOverride}) {
    String roundingMode = getPreference<String>("rounding_mode");
    int roundTo = roundToOverride ?? getPreference<int>("round_to");

    double a = n * roundTo;

    if (roundingMode == RoundingMode.up) {
      return a.ceilToDouble() / roundTo;
    } else if (roundingMode == RoundingMode.down) {
      return a.floorToDouble() / roundTo;
    } else {
      double i = a.floorToDouble();
      double f = n - i;

      if (roundingMode == RoundingMode.halfUp) {
        return (f < 0.5 ? i : i + 1) / roundTo;
      } else if (roundingMode == RoundingMode.halfDown) {
        return (f <= 0.5 ? i : i + 1) / roundTo;
      }
    }

    return n;
  }

  static double? tryParse(String? input) {
    if (input == null) return null;
    return double.tryParse(input.replaceAll(",", ".").replaceAll(" ", ""));
  }

  static String format(double? n, {bool addZero = true, int? roundToOverride}) {
    if (n == null) {
      return "-";
    }

    String result;

    int decimals = log(roundToOverride ?? getPreference<int>("round_to")) ~/ log(10);
    if (n % 1 != 0) {
      decimals = max(n.toString().split('.')[1].length, decimals);
    }

    result = n.toStringAsFixed(decimals);

    if (addZero && decimals == 0 && n > 0 && n < 10) {
      result = "0$result";
    }
    return result;
  }
}
