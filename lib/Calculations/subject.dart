// Project imports:
import 'calculator.dart';
import 'manager.dart';
import 'sort_interface.dart';
import 'test.dart';

class Subject implements SortInterface {
  List<Test> tests = [];

  @override
  String name = "";
  @override
  double coefficient = 1;
  int bonus = 0;

  @override
  double result = 0;

  Subject(this.name, this.coefficient);

  void calculate() {
    if (tests.isEmpty) {
      result = -1;
      return;
    }

    double a = 0;
    double b = 0;
    for (Test t in tests) {
      a += t.grade1;
      b += t.grade2;
    }

    double o = a * (Manager.totalGrades / b) + bonus;

    if (o < 0) {
      result = 0;
    } else {
      result = Calculator.round(o);
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
    tests[position].grade1 = grade1;
    tests[position].grade2 = grade2;
    tests[position].name = name;
    Manager.calculate();
  }

  List<String> getNames() {
    List<String> a = [];
    for (int i = 0; i < tests.length; i++) {
      a.add(tests[i].name);
    }

    return a;
  }

  List<String> getGrades() {
    List<String> a = [];
    for (int i = 0; i < tests.length; i++) {
      a.add("${Calculator.format(tests[i].grade1)}/${Calculator.format(tests[i].grade2)}");
    }

    return a;
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
    bool empty = true;
    for (Test t in tests) {
      if (!t.empty) {
        empty = false;
        break;
      }
    }

    if (empty || result == -1) {
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
