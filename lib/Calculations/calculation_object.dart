// Package imports:
import 'package:diacritic/diacritic.dart';

// Project imports:
import '../Misc/storage.dart';

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
  double? get value1 => result;
  double get value2 => Storage.getPreference<double>("total_grades");
}
