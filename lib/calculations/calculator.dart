// Dart imports:
import 'dart:math';

// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import '../misc/storage.dart';
import 'calculation_object.dart';
import 'manager.dart';
import 'test.dart';

abstract class SortMode {
  static const int name = 0;
  static const int result = 1;
  static const int coefficient = 2;
  static const int custom = 3;
}

abstract class SortDirection {
  static const int ascending = 1;
  static const int descending = -1;
  static const int notApplicable = 0;
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
  static void sortObjects(List<CalculationObject> data,
      {required int sortType, int? sortModeOverride, int? sortDirectionOverride, List<CalculationObject>? comparisonData}) {
    if (data.length >= 2) {
      int sortMode = getPreference<int>("sort_mode$sortType");
      if (sortModeOverride != null && sortMode != SortMode.custom) {
        sortMode = sortModeOverride;
      }
      int sortDirection = sortDirectionOverride ?? getPreference<int>("sort_direction$sortType");

      switch (sortMode) {
        case SortMode.name:
          insertionSort(data, compare: (CalculationObject a, CalculationObject b) => sortDirection * a.processedName.compareTo(b.processedName));
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

            return sortDirection * a.result!.compareTo(b.result!);
          });
          break;
        case SortMode.coefficient:
          insertionSort(data, compare: (CalculationObject a, CalculationObject b) => sortDirection * a.coefficient.compareTo(b.coefficient));
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

  static double? calculate(Iterable<CalculationObject> data, {int bonus = 0, bool precise = false, double speakingWeight = 1}) {
    if (data.isEmpty || !data.any((element) => element.numerator != null && element.denominator != 0)) {
      return null;
    }

    double totalGrades = getPreference<double>("total_grades");

    double totalNumerator = 0;
    double totalDenominator = 0;
    double totalNumeratorSpeaking = 0;
    double totalDenominatorSpeaking = 0;

    for (CalculationObject c in data) {
      if (c.numerator != null && c.denominator != 0) {
        if (c is Test && c.isSpeaking) {
          totalNumeratorSpeaking += c.numerator! * c.coefficient;
          totalDenominatorSpeaking += c.denominator * c.coefficient;
        } else {
          totalNumerator += c.numerator! * c.coefficient;
          totalDenominator += c.denominator * c.coefficient;
        }
      }
    }

    double result = totalNumerator * (totalGrades / totalDenominator);
    double resultSpeaking = totalNumeratorSpeaking * (totalGrades / totalDenominatorSpeaking);
    if (result.isNaN) result = resultSpeaking;
    if (resultSpeaking.isNaN) resultSpeaking = result;

    double totalResult = (result * speakingWeight + resultSpeaking) / (speakingWeight + 1) + bonus;

    return round(totalResult, roundToOverride: precise ? 100 : null);
  }

  static double round(double n, {String? roundingModeOverride, int? roundToOverride}) {
    String roundingMode = roundingModeOverride ?? getPreference<String>("rounding_mode");
    int roundTo = roundToOverride ?? getPreference<int>("round_to");

    double round = n * roundTo;

    if (roundingMode == RoundingMode.up) {
      return round.ceilToDouble() / roundTo;
    } else if (roundingMode == RoundingMode.down) {
      return round.floorToDouble() / roundTo;
    } else {
      double base = round.floorToDouble();
      double decimals = n - base;

      if (roundingMode == RoundingMode.halfUp) {
        return (decimals < 0.5 ? base : base + 1) / roundTo;
      } else if (roundingMode == RoundingMode.halfDown) {
        return (decimals <= 0.5 ? base : base + 1) / roundTo;
      }
    }

    return n;
  }

  static double? tryParse(String? input) {
    if (input == null) return null;
    return double.tryParse(input.replaceAll(",", ".").replaceAll(" ", ""));
  }

  static String format(double? n, {bool addZero = true, int? roundToOverride}) {
    if (n == null || n == double.nan) {
      return "-";
    }

    String result;

    int nbDecimals = log(roundToOverride ?? getPreference<int>("round_to")) ~/ log(10);
    if (n % 1 != 0) {
      nbDecimals = max(n.toString().split('.')[1].length, nbDecimals);
    }

    result = n.toStringAsFixed(nbDecimals);

    if (addZero && nbDecimals == 0 && n > 0 && n < 10) {
      result = "0$result";
    }
    return result;
  }
}
