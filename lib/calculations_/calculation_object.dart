// Package imports:
import 'package:diacritic/diacritic.dart';

// Project imports:
import '../Misc/storage.dart';
import 'calculator.dart';

abstract class CalculationObject {
  String _name = "";
  String get name => _name;
  set name(String value) {
    _name = value;
    processedName = removeDiacritics(name.toLowerCase()).replaceAll("[^\\p{ASCII}]", "");
  }

  String processedName = "";
  double coefficient = 1;
  double? result;
  double? preciseResult;
  double? get numerator => result != null ? result! : null;
  double get denominator => getPreference<double>("total_grades");

  String getResult({bool precise = false}) {
    if (result == null) {
      return "-";
    } else {
      return Calculator.format(precise ? preciseResult : result, roundToOverride: precise ? 100 : null);
    }
  }
}
