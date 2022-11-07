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

  void sort({int? sortModeOverride}) {
    Calculator.sortSubjects(subjects, "sort_mode1", sortModeOverride: sortModeOverride);
  }

  String getResult() {
    if (result > -1) {
      return Calculator.format(result);
    } else {
      return "-";
    }
  }

  Term.fromJson(Map<String, dynamic> json) {
    if (json['subjects'] != null) {
      var subjectList = json["subjects"] as List;
      List<Subject> s = subjectList.map((subjectJson) => Subject.fromJson(subjectJson)).toList();

      subjects = s;
    }
  }

  Map<String, dynamic> toJson() => {
        "subjects": subjects,
      };
}
