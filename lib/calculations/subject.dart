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
  @override
  double get denominator => getCurrentYear().maxGrade;

  double bonus = 0;
  bool isGroup = false;
  bool isChild = false;
  double speakingWeight = DefaultValues.speakingWeight;

  Subject(String name, double weight, this.speakingWeight, {this.isGroup = false, this.isChild = false}) {
    super.name = name;
    super.weight = weight;
  }

  void calculate() {
    if (isGroup) {
      for (final Subject child in children) {
        child.calculate();
      }

      result = Calculator.calculate(children);
      preciseResult = Calculator.calculate(children, precise: true);
    } else {
      for (final test in tests) {
        test.calculate();
      }

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

  void editTest(int position, double numerator, double denominator, String name, double weight, {bool isSpeaking = false, int? timestamp}) {
    final Test t = tests[position];

    t.numerator = numerator;
    t.denominator = denominator;
    t.name = name;
    t.weight = weight;
    t.isSpeaking = isSpeaking;
    t.result = Calculator.calculate([t], clamp: false);
    t.timestamp = timestamp ?? t.timestamp;
    Manager.calculate();
  }

  void sort({int? sortModeOverride, int? sortDirectionOverride}) {
    Calculator.sortObjects(
      children,
      sortType: SortType.subject,
      sortModeOverride: sortModeOverride,
      sortDirectionOverride: sortDirectionOverride,
      comparisonData: children.isNotEmpty ? getCurrentYear().termTemplate.firstWhere((element) => element.name == name).children : null,
    );

    for (final Subject element in children) {
      element.sort(sortModeOverride: sortModeOverride, sortDirectionOverride: sortDirectionOverride);
    }

    Calculator.sortObjects(tests, sortType: SortType.test, sortModeOverride: sortModeOverride, sortDirectionOverride: sortDirectionOverride);
  }

  Subject.fromSubject(Subject subject) {
    children = subject.children.map((e) => Subject.fromSubject(e)).toList();
    isGroup = subject.isGroup;
    isChild = subject.isChild;
    speakingWeight = subject.speakingWeight;
    name = subject.name;
    weight = subject.weight;
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
    weight = json["coefficient"] as double;
    try {
      bonus = (json["bonus"] as int).toDouble();
    } catch (e) {
      bonus = json["bonus"] as double;
    }
    speakingWeight = json["speakingWeight"] as double? ?? DefaultValues.speakingWeight;
  }

  Map<String, dynamic> toJson() => {
        "tests": tests,
        "children": children,
        "name": name,
        "coefficient": weight,
        "bonus": bonus,
        "type": isGroup,
        "speakingWeight": speakingWeight,
      };
}
