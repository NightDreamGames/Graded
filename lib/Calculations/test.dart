// Project imports:
import 'package:gradely/Calculations/calculator.dart';
import 'sort_interface.dart';

class Test implements SortInterface {
  double grade1 = 0;
  double grade2 = 0;
  @override
  String name = "";
  @override
  double get result => grade1 / grade2;
  @override
  double get coefficient => 0;

  Test(
    this.grade1,
    this.grade2,
    this.name,
  );

  @override
  String toString() {
    return "${Calculator.format(grade1)}/${Calculator.format(grade2)}";
  }

  Test.fromJson(Map<String, dynamic> json)
      : grade1 = json['grade1'],
        grade2 = json['grade2'],
        name = json['name'];

  Map<String, dynamic> toJson() => {
        "grade1": grade1,
        "grade2": grade2,
        "name": name,
      };
}
