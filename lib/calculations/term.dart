// Project imports:
import "package:graded/calculations/calculation_object.dart";
import "package:graded/calculations/calculator.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/test.dart";
import "package:graded/misc/default_values.dart";

class Term extends CalculationObject {
  List<Test> tests = [];
  bool isExam = false;
  @override
  double get denominator => getCurrentYear().maxGrade;

  double bonus = 0;

  Term({
    double weight = 1,
    String name = "",
    this.isExam = false,
  }) {
    super.weight = weight;
    super.name = name;
  }

  @override
  void calculate({double speakingWeight = DefaultValues.speakingWeight}) {
    for (final test in tests) {
      test.calculate();
    }

    result = Calculator.calculate(tests, bonus: bonus, speakingWeight: speakingWeight);
    preciseResult = Calculator.calculate(tests, bonus: bonus, precise: true, speakingWeight: speakingWeight);
  }

  void addTest(Test test, {bool calculate = true}) {
    tests.add(test);

    if (calculate) {
      Manager.calculate();
    }
  }

  void removeTest(Test test, {bool calculate = true}) {
    tests.remove(test);
    if (calculate) {
      Manager.calculate();
    }
  }

  void removeTestAt(int position, {bool calculate = true}) {
    tests.removeAt(position);
    if (calculate) {
      Manager.calculate();
    }
  }

  void editTest(Test test, double numerator, double denominator, String name, double weight, {bool isSpeaking = false, int? timestamp}) {
    test.numerator = numerator;
    test.denominator = denominator;
    test.name = name;
    test.weight = weight;
    test.isSpeaking = isSpeaking;
    test.result = Calculator.calculate([test], clamp: false);
    test.timestamp = timestamp ?? test.timestamp;
    Manager.calculate();
  }

  Term.fromJson(Map<String, dynamic> json) {
    final testList = json["tests"] as List;
    tests = testList.map((testJson) {
      return Test.fromJson(testJson as Map<String, dynamic>);
    }).toList();

    weight = json["weight"] as double? ?? DefaultValues.weight;
    isExam = json["isExam"] as bool? ?? DefaultValues.isExam;
    bonus = json["bonus"] as double;
  }

  Map<String, dynamic> toJson() => {
        "weight": weight,
        "isExam": isExam,
        "bonus": bonus,
        "tests": tests,
      };
}
