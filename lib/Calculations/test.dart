// Project imports:
import 'calculation_object.dart';
import 'calculator.dart';

class Test extends CalculationObject {
  @override
  double? numerator;
  @override
  double denominator = 0;

  Test(this.numerator, this.denominator, {String name = "", double coefficient = 1, bool isEmpty = false}) {
    super.name = name;
    super.coefficient = coefficient;
    result = isEmpty ? null : Calculator.calculate([this]);
    if (result == null) numerator = null;
  }

  @override
  String toString() {
    if (result != null) {
      return "${Calculator.format(numerator)}/${Calculator.format(denominator, roundToOverride: 1)}";
    } else {
      return "-";
    }
  }

  @override
  String getResult({bool precise = false}) {
    if (result == null) {
      return "-";
    } else {
      return Calculator.format(result);
    }
  }

  Test.fromJson(Map<String, dynamic> json) {
    numerator = json['grade1'];
    denominator = json['grade2'];
    name = json['name'];
    coefficient = json['coefficient'] ?? 1;
    result = Calculator.calculate([this]);
    if (result == null) numerator = null;
  }

  Map<String, dynamic> toJson() => {
        "grade1": numerator,
        "grade2": denominator,
        "name": name,
        "coefficient": coefficient,
      };
}
