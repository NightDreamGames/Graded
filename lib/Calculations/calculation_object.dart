// Project imports:
import 'manager.dart';

abstract class CalculationObject {
  String name = "";
  double coefficient = 1;
  double? result;
  double? get value1 => result;
  double get value2 => Manager.totalGrades;
}
