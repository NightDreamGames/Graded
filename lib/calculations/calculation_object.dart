// Package imports:
import "package:diacritic/diacritic.dart";

// Project imports:
import "package:graded/calculations/calculator.dart";
import "package:graded/misc/default_values.dart";

abstract class CalculationObject {
  String _name = "";
  String get name => _name;
  set name(String value) {
    _name = value;
    asciiName = removeDiacritics(value.toLowerCase().trim()).replaceAll("[^\\p{ASCII}]", "").replaceAll(RegExp("\\s+"), " ");
  }

  String asciiName = "";
  double weight = DefaultValues.weight;
  double? result;
  double? preciseResult;
  double? get numerator => result;
  double get denominator => DefaultValues.maxGrade;

  String getResult({bool precise = false}) {
    if (result == null) return "-";
    return Calculator.format(precise ? preciseResult : result, roundToMultiplier: precise ? DefaultValues.preciseRoundToMultiplier : 1);
  }
}
