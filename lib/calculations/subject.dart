// Project imports:
import "package:graded/calculations/calculation_object.dart";
import "package:graded/calculations/calculator.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/test.dart";
import "package:graded/misc/default_values.dart";
import "package:graded/ui/utilities/ordered_collection.dart";

class Subject extends CalculationObject {
  OrderedCollection<Subject> children = OrderedCollection.newTreeSet();
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

  Subject.fromSubject(Subject subject) {
    children = OrderedCollection.newTreeSet(subject.children.map((e) => Subject.fromSubject(e)));
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
      children = OrderedCollection.newTreeSet(childrenList.map((childJson) => Subject.fromJson(childJson as Map<String, dynamic>)..isChild = true));
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
        "name": name,
        "coefficient": weight,
        "speakingWeight": speakingWeight,
        "bonus": bonus,
        "type": isGroup,
        "children": children.toList(),
        "tests": tests,
      };

  int compareTo(Subject other) => name.hashCode - other.name.hashCode;
}
