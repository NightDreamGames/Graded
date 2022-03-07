import 'manager.dart';
import 'calculator.dart';
import 'test.dart';
import "../Misc/serialization.dart";

class Subject {
  List<Test> tests = [];

  String name = "";
  double coefficient = 1;
  double result = 0;
  int bonus = 0;

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
      Calculator.round(o).then((value) => result = value);
    }
  }

  void createTest(double grade, double total, String name) {
    tests.add(Test(grade, total, name));
    Manager.calculate();
    Serialization.Serialize();
  }

  void addTest(Test test) {
    tests.add(test);
    Manager.calculate();
    Serialization.Serialize();
  }

  void removeTest(int position) {
    tests.removeAt(position);
    Manager.calculate();
    Serialization.Serialize();
  }

  void editTest(int position, double grade1, double grade2, String name) {
    tests[position].grade1 = grade1;
    tests[position].grade2 = grade2;
    tests[position].name = name;
    Manager.calculate();
    Serialization.Serialize();
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
      a.add(Calculator.format(tests[i].grade1) + "/" + Calculator.format(tests[i].grade2));
    }

    return a;
  }

  void changeBonus(int direction) {
    if ((bonus + direction).abs() < 10) {
      bonus += direction;
      Manager.calculate();
      Serialization.Serialize();
    }
  }

  void sort() {
    Calculator.sort2(tests);
  }

  String getResult() {
    if (result > -1) {
      return result.toString();
    } else {
      return "-";
    }
  }
}
