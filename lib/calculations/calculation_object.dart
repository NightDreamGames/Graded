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
    asciiName = removeDiacritics(value.toLowerCase()).replaceAll("[^\\p{ASCII}]", "");
  }

  String asciiName = "";
  double coefficient = 1;
  double? result;
  double? preciseResult;
  double? get numerator => result != null ? result! : null;
  double get denominator => defaultValues["max_grade"] as double;

  String getResult({bool precise = false}) {
    if (result == null) return "-";
    return Calculator.format(precise ? preciseResult : result, roundToMultiplier: precise ? defaultValues["precise_round_to_multiplier"] as int : 1);
  }
}
