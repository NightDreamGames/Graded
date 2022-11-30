// Project imports:
import 'calculation_object.dart';
import 'calculator.dart';
import 'manager.dart';
import 'subject.dart';

class Term extends CalculationObject {
  List<Subject> subjects = [];

  Term() {
    if (Manager.termTemplate.isNotEmpty) {
      for (Subject s in Manager.termTemplate) {
        subjects.add(Subject(s.name, s.coefficient));
      }
    }
  }

  void calculate() {
    for (Subject s in subjects) {
      s.calculate();
    }

    result = Calculator.calculate(subjects);
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

    if (empty || result == null) {
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
