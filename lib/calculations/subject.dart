// Project imports:
import "package:graded/calculations/calculation_object.dart";
import "package:graded/calculations/calculator.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/test.dart";
import "package:graded/misc/default_values.dart";
import "package:graded/misc/enums.dart";

class Subject extends CalculationObject {
  List<Subject> children = [];
  List<Test> tests = [];

  int bonus = 0;
  bool isGroup = false;
  bool isChild = false;
  double speakingWeight = defaultValues["speaking_weight"] as double;

  Subject(String name, double coefficient, this.speakingWeight, {this.isGroup = false, this.isChild = false}) {
    super.name = name;
    super.coefficient = coefficient;
  }

  void calculate() {
    if (isGroup) {
      if (isGroup) {
        for (final Subject element in children) {
          element.calculate();
        }
      }

      result = Calculator.calculate(children);
      preciseResult = Calculator.calculate(children, precise: true);
    } else {
      result = Calculator.calculate(tests, bonus: bonus, speakingWeight: speakingWeight);
      preciseResult = Calculator.calculate(tests, bonus: bonus, precise: true, speakingWeight: speakingWeight);
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
    if (calculate) {
      Manager.calculate();
    }
  }

  void editTest(int position, double numerator, double denominator, String name, {bool isSpeaking = false}) {
    Test t = tests[position];

    t.numerator = numerator;
    t.denominator = denominator;
    t.name = name;
    t.isSpeaking = isSpeaking;
    t.result = Calculator.calculate([t]);
    Manager.calculate();
  }

  void changeBonus(int direction) {
    if ((bonus + direction).abs() >= 10) return;

    bonus += direction;
    Manager.calculate();
  }

  void sort({int? sortModeOverride}) {
    Calculator.sortObjects(
      children,
      sortType: SortType.subject,
      sortModeOverride: sortModeOverride,
      comparisonData: Manager.termTemplate.firstWhere((element) => element.processedName == processedName).children,
    );

    Calculator.sortObjects(tests, sortType: SortType.test, sortModeOverride: sortModeOverride);
  }

  Subject.fromJson(Map<String, dynamic> json) {
    if (json["tests"] != null) {
      final testsList = json["tests"] as List;
      tests = testsList.map((testJson) => Test.fromJson(testJson as Map<String, dynamic>)).toList();
    }
    if (json["children"] != null) {
      final childrenList = json["children"] as List;
      children = childrenList.map((childJson) => Subject.fromJson(childJson as Map<String, dynamic>)..isChild = true).toList();
    }

    isGroup = json["type"] != null && json["type"] as bool;
    name = json["name"] as String;
    coefficient = json["coefficient"] as double;
    bonus = json["bonus"] as int;
    speakingWeight = json["speakingWeight"] as double? ?? defaultValues["speaking_weight"] as double;
  }

  Map<String, dynamic> toJson() => {
        "tests": tests,
        "children": children,
        "name": name,
        "coefficient": coefficient,
        "bonus": bonus,
        "type": isGroup,
        "speakingWeight": speakingWeight,
      };
}
