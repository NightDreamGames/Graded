import 'manager.dart';
import 'calculator.dart';
import 'subject.dart';

class Term {
  List<Subject> subjects = [];

  double result = 0;

  Term() {
    if (Manager.termTemplate.isNotEmpty) {
      for (Subject s in Manager.termTemplate) {
        subjects.add(Subject(s.name, s.coefficient));
      }
    }

    Manager.calculate();
  }

  void calculate() {
    List<double> results = [];
    List<double> coefficients = [];

    for (Subject s in subjects) {
      s.calculate();

      results.add(s.result);
      coefficients.add(s.coefficient);
    }

    result = Calculator.calculate(results, coefficients);
  }

  List<String> getSubjects() {
    List<String> a = [];
    for (int i = 0; i < subjects.length; i++) {
      a.add(subjects[i].name);
    }
    return a;
  }

  List<String> getGrades() {
    List<String> a = [];
    for (int i = 0; i < subjects.length; i++) {
      a.add((subjects[i].result == -1) ? "-" : Calculator.format(subjects[i].result));
    }
    return a;
  }

  void sort() {
    Calculator.sort1(subjects, "sort_mode1");
  }

  String getResult() {
    if (result > -1) {
      return Calculator.format(result);
    } else {
      return "-";
    }
  }
}
