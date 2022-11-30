// Project imports:
import 'calculation_object.dart';
import 'calculator.dart';

class Test extends CalculationObject {
  @override
  double? value1;
  @override
  double value2 = 0;

  Test(this.value1, this.value2, String name, {bool isEmpty = false}) {
    super.name = name;
    result = isEmpty ? null : Calculator.calculate([this]);
    if (result == null) value1 = null;
  }

  @override
  String toString() {
    if (result != null) {
      return "${Calculator.format(value1)}/${Calculator.format(value2)}";
    } else {
      return "-";
    }
  }

  Test.fromJson(Map<String, dynamic> json) {
    value1 = json['grade1'];
    value2 = json['grade2'];
    name = json['name'];
    result = Calculator.calculate([this]);
    if (result == null) value1 = null;
  }

  Map<String, dynamic> toJson() => {
        "grade1": value1,
        "grade2": value2,
        "name": name,
      };
}
