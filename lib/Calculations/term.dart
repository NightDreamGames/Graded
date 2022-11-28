// Package imports:
import 'package:tuple/tuple.dart';

// Project imports:
import 'calculator.dart';
import 'manager.dart';
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
  }

  void calculate() {
    List<Tuple2<double, double>> data = [];

    for (Subject s in subjects) {
      s.calculate();
      data.add(Tuple2(s.result, s.coefficient));
    }

    result = Calculator.calculate(data);
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
    Calculator.sortObjects(subjects, 1, sortModeOverride: sortModeOverride);
  }

  String getResult() {
    bool empty = true;
    for (Subject s in subjects) {
      if (s.getResult() != "-") {
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
