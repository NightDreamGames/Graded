// Project imports:
import '../misc/storage.dart';
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
  double speakingWeight = defaultValues["speaking_weight"];

  Subject(String name, double coefficient, this.speakingWeight, {this.isGroup = false, this.isChild = false}) {
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
    Calculator.sortObjects(children,
        sortType: SortType.subject,
        sortModeOverride: sortModeOverride,
        comparisonData: Manager.termTemplate.firstWhere((element) => element.processedName == processedName).children);

    Calculator.sortObjects(tests, sortType: SortType.test, sortModeOverride: sortModeOverride);
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
    speakingWeight = json['speakingWeight'] ?? defaultValues["speaking_weight"];
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
