// Package imports:
import "package:diacritic/diacritic.dart";

// Project imports:
import "package:graded/calculations/calculator.dart";
import "package:graded/misc/storage.dart";

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
  double get denominator => getPreference<double>("total_grades");

  String getResult({bool precise = false}) {
    if (result == null) return "-";
    return Calculator.format(precise ? preciseResult : result, roundToOverride: precise ? 100 : null);
  }
}
