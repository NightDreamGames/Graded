// Project imports:
import 'calculation_object.dart';
import 'calculator.dart';
import 'manager.dart';
import 'test.dart';

class Subject extends CalculationObject {
  List<Subject> children = [];
  List<Test> tests = [];

  int bonus = 0;
  bool isGroup = false;
  bool isChild = false;

  Subject(String name, double coefficient, {this.isGroup = false, this.isChild = false}) {
    super.name = name;
    super.coefficient = coefficient;
  }

  void calculate() {
    if (isGroup) {
      if (isGroup) {
        for (Subject element in children) {
          element.calculate();
        }
      }

      result = Calculator.calculate(children);
    } else {
      result = Calculator.calculate(tests, bonus: bonus);
    }
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
    Test t = tests[position];

    t.value1 = grade1;
    t.value2 = grade2;
    t.name = name;
    t.result = Calculator.calculate([this]);
    Manager.calculate();
  }

  void changeBonus(int direction) {
    if ((bonus + direction).abs() < 10) {
      bonus += direction;
      Manager.calculate();
    }
  }

  void sort({int? sortModeOverride}) {
    if (children.isNotEmpty) {
      Calculator.sortObjects(children,
          sortType: SortType.subject,
          sortModeOverride: sortModeOverride,
          comparisonData: Manager.termTemplate.firstWhere((element) => element.processedName == processedName).children);
    }
    Calculator.sortObjects(tests, sortType: SortType.test, sortModeOverride: sortModeOverride);
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
      var testsList = json["tests"] as List;
      tests = testsList.map((testJson) => Test.fromJson(testJson)).toList();
    }
    if (json['children'] != null) {
      var childrenList = json["children"] as List;
      children = childrenList.map((childJson) => Subject.fromJson(childJson)..isChild = true).toList();
    }

    isGroup = json['type'] != null && json['type'];
    name = json['name'];
    coefficient = json['coefficient'];
    bonus = json['bonus'];
  }

  Map<String, dynamic> toJson() => {
        "tests": tests,
        "children": children,
        "name": name,
        "coefficient": coefficient,
        "bonus": bonus,
        "type": isGroup,
      };
}
