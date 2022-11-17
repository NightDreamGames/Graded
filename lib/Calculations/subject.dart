// Project imports:
import '../Misc/storage.dart';
import 'calculator.dart';
import 'manager.dart';
import 'test.dart';

class Subject {
  List<Test> tests = [];

  String name = "";
  double coefficient = 1;
  int bonus = 0;

  double result = 0;

  Subject(this.name, this.coefficient) {
    Manager.calculate();
  }

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

  void createTest(double grade, double total, String name) {
    tests.add(Test(grade, total, name));
    Manager.calculate();
    Storage.serialize();
  }

  void addTest(Test test, {bool calculate = true}) {
    tests.add(test);
    if (calculate) {
      Manager.calculate();
    }
    Storage.serialize();
  }

  void removeTest(int position) {
    tests.removeAt(position);
    Manager.calculate();
    Storage.serialize();
  }

  void editTest(int position, double grade1, double grade2, String name) {
    tests[position].grade1 = grade1;
    tests[position].grade2 = grade2;
    tests[position].name = name;
    Manager.calculate();
    Storage.serialize();
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
      Storage.serialize();
    }
  }

  void sort() {
    Calculator.sortTests(tests);
  }

  String getResult() {
    if (result > -1) {
      return Calculator.format(result);
    } else {
      return "-";
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
