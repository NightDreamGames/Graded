// Dart imports:
import "dart:math";

// Package imports:
import "package:collection/collection.dart";

// Project imports:
import "package:graded/calculations/calculation_object.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/calculations/test.dart";
import "package:graded/misc/default_values.dart";
import "package:graded/misc/enums.dart";
import "package:graded/misc/storage.dart";
import "package:graded/ui/utilities/grade_mapping_value.dart";

class Calculator {
  static List<T> sortObjects<T extends CalculationObject>(
    Iterable<T> data, {
    required int sortType,
    int? sortModeOverride,
    int? sortDirectionOverride,
    int? termIndex,
  }) {
    if (data.length < 2) return data.toList();

    final List<T> result = data.toList();

    final int sortDirection = sortDirectionOverride ?? getPreference<int>("sortDirection$sortType");
    int sortMode = getPreference<int>("sortMode$sortType");
    if (sortModeOverride != null) sortMode = sortModeOverride;

    switch (sortMode) {
      case SortMode.name:
        insertionSort(
          result,
          compare: (a, b) {
            int result = compareNatural(a.asciiName, b.asciiName);
            if (result == 0) {
              result = compareNatural(a.name, b.name);
            }
            return sortDirection * result;
          },
        );
      case SortMode.result:
        insertionSort(
          result,
          compare: (a, b) {
            double? getResult(CalculationObject c) {
              if (c is Subject && termIndex != null) {
                return c.getTermResult(termIndex, precise: true);
              } else {
                return c.preciseResult;
              }
            }

            if (getResult(a) == null && getResult(b) == null) {
              return 0;
            } else if (getResult(b) == null) {
              return -1;
            } else if (getResult(a) == null) {
              return 1;
            }

            return sortDirection * getResult(a)!.compareTo(getResult(b)!);
          },
        );
      case SortMode.weight:
        insertionSort(result, compare: (a, b) => sortDirection * a.weight.compareTo(b.weight));
      case SortMode.timestamp:
        if (result.first is! Test) throw UnimplementedError("Timestamp sorting is only implemented for tests");

        insertionSort(
          result,
          compare: (a, b) {
            int result = (a as Test).timestamp.compareTo((b as Test).timestamp);
            if (result == 0) {
              result = a.asciiName.compareTo(b.asciiName);
            }
            return sortDirection * result;
          },
        );
      case SortMode.custom:
        return sortDirection == SortDirection.descending ? result.reversed.toList() : result;
      default:
        throw const FormatException("Invalid");
    }

    return result;
  }

  static double? calculate(
    Iterable<CalculationObject> data, {
    double bonus = 0,
    bool precise = false,
    bool clamp = true,
    double speakingWeight = 1,
  }) {
    final bool isNullFilled = data.every((element) => element.numerator == null || element.denominator == 0);

    if (data.isEmpty || isNullFilled) return null;

    final double maxGrade = Manager.years.isNotEmpty ? getCurrentYear().maxGrade : getPreference<double>("maxGrade");
    final bool scaleUpTests = Manager.years.isNotEmpty ? getCurrentYear().scaleUpTests : getPreference<bool>("scaleUpTests");

    double totalNumerator = 0;
    double totalDenominator = 0;
    double totalNumeratorSpeaking = 0;
    double totalDenominatorSpeaking = 0;

    for (final CalculationObject c in data.where((element) => element.numerator != null && element.denominator != 0)) {
      final double maxGradeMultiplier = scaleUpTests ? maxGrade / c.denominator : 1;

      final double weightedNumerator = c.numerator! * c.weight * maxGradeMultiplier;
      final double weightedDenominator = c.denominator * c.weight * maxGradeMultiplier;

      if (c is Test && c.isSpeaking) {
        totalNumeratorSpeaking += weightedNumerator;
        totalDenominatorSpeaking += weightedDenominator;
      } else {
        totalNumerator += weightedNumerator;
        totalDenominator += weightedDenominator;
      }
    }

    double result = totalNumerator * (maxGrade / totalDenominator);
    double resultSpeaking = totalNumeratorSpeaking * (maxGrade / totalDenominatorSpeaking);
    if (result.isNaN) result = resultSpeaking;
    if (resultSpeaking.isNaN) resultSpeaking = result;

    double totalResult = (result * speakingWeight + resultSpeaking) / (speakingWeight + 1) + bonus;

    totalResult = round(totalResult, roundToMultiplier: precise ? DefaultValues.preciseRoundToMultiplier : 1);
    if (clamp && !precise) totalResult = totalResult.clamp(0, maxGrade);

    return totalResult;
  }

  static double round(double n, {String? roundingModeOverride, int? roundToOverride, int roundToMultiplier = 1}) {
    final String roundingMode = roundingModeOverride ?? (Manager.years.isNotEmpty ? getCurrentYear().roundingMode : getPreference("roundingMode"));
    int roundTo = roundToOverride ?? (Manager.years.isNotEmpty ? getCurrentYear().roundTo : getPreference<int>("roundTo"));
    roundTo *= roundToMultiplier;

    final double round = n * roundTo;

    switch (roundingMode) {
      case RoundingMode.up:
        return round.ceilToDouble() / roundTo;
      case RoundingMode.down:
        return round.floorToDouble() / roundTo;
      case RoundingMode.halfUp:
        return round.roundToDouble() / roundTo;
      case RoundingMode.halfDown:
        final double base = round.truncateToDouble();
        final double decimals = n - base;
        final int sign = n < 0 ? -1 : 1;

        return (decimals <= 0.5 ? base : base + 1 * sign) / roundTo;
      default:
        throw const FormatException("Invalid");
    }
  }

  static double? tryParse(String? input) {
    if (input == null) return null;
    return double.tryParse(input.replaceAll(",", ".").replaceAll(" ", ""));
  }

  static String format(
    double? n, {
    bool leadingZero = true,
    int? roundToOverride,
    int roundToMultiplier = 1,
    bool showPlusSign = false,
  }) {
    if (n == null || n.isNaN) {
      return "-";
    }

    int roundTo = roundToOverride ?? (Manager.years.isNotEmpty ? getCurrentYear().roundTo : getPreference<int>("roundTo"));
    roundTo *= roundToMultiplier;

    String result;

    int nbDecimals = (log(roundTo) / log(10)).round();
    if (n % 1 != 0) {
      nbDecimals = max(n.toString().split(".")[1].length, nbDecimals);
    }

    result = n.toStringAsFixed(nbDecimals);

    if (leadingZero && getPreference<bool>("leadingZero") && n >= 1 && n < 10) {
      result = "0$result";
    }
    if (showPlusSign && n >= 0) {
      result = "+$result";
    }

    return result;
  }

  static List<Test> getSortedTestData(List<Test> tests) {
    return sortObjects<Test>(tests, sortType: SortType.test);
  }

  static (List<Subject>, List<List<Subject>>) getSortedSubjectData(List<Subject> subjects, {int? termIndex}) {
    final List<Subject> subjectData = sortObjects<Subject>(
      subjects,
      sortType: SortType.subject,
      termIndex: termIndex,
    );
    final List<List<Subject>> childrenData = subjectData.map((element) {
      if (element.children.isEmpty) return <Subject>[];
      return sortObjects<Subject>(
        element.children,
        sortType: SortType.subject,
        termIndex: termIndex,
      );
    }).toList();

    return (subjectData, childrenData);
  }

  static GradeMapping? getGradeMapping(double? n) {
    if (n == null || n.isNaN) return null;

    for (final gradeMapping in getCurrentYear().gradeMappings) {
      if (n >= gradeMapping.min && n <= gradeMapping.max) {
        return gradeMapping;
      }
    }

    return null;
  }
}
