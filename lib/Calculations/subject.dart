// Project imports:
import 'calculation_object.dart';
import 'calculator.dart';
import 'manager.dart';
import 'test.dart';

class Subject extends CalculationObject {
  List<Test> tests = [];

  @override
  double? get value1 => result != null ? coefficient * result! : null;
  @override
  double get value2 => coefficient * Manager.totalGrades;
  int bonus = 0;

  Subject(String name, double coefficient) {
    super.name = name;
    super.coefficient = coefficient;
  }

  void calculate() {
    result = Calculator.calculate(tests, bonus: bonus);
  }

  void addTest(Test test, {bool calculate = true}) {
    tests.add(test);
    if (calculate) {
      Manager.calculate();
    }
  }

  void removeTest(int position, {bool calculate = true}) {
    tests.removeAt(position);
    if (calculate) Manager.calculate();
  }

  void editTest(int position, double grade1, double grade2, String name) {
    tests[position].value1 = grade1;
    tests[position].value2 = grade2;
    tests[position].name = name;
    tests[position].result = Calculator.calculate([this]);
    Manager.calculate();
  }

  void changeBonus(int direction) {
    if ((bonus + direction).abs() < 10) {
      bonus += direction;
      Manager.calculate();
    }
  }

  void sort() {
    Calculator.sortObjects(tests, 2);
  }

  String getResult() {
    if (result == null) {
      return "-";
    } else {
      return Calculator.format(result);
    }
  }

  Subject.fromJson(Map<String, dynamic> json) {
    if (json['tests'] != null) {
      var testList = json["tests"] as List;
      List<Test> t = testList.map((testJson) => Test.fromJson(testJson)).toList();

      tests = t;
    }

    name = json['name'];
    coefficient = json['coefficient'];
    bonus = json['bonus'];
  }

  Map<String, dynamic> toJson() => {
        "tests": tests,
        "name": name,
        "coefficient": coefficient,
        "bonus": bonus,
      };
}
