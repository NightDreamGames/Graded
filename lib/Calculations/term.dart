// Project imports:
import 'calculation_object.dart';
import 'calculator.dart';
import 'manager.dart';
import 'subject.dart';

class Term extends CalculationObject {
  List<Subject> subjects = [];

  Term({double coefficient = 1, String name = ""}) {
    super.coefficient = coefficient;
    super.name = name;

    if (Manager.termTemplate.isNotEmpty) {
      for (Subject s in Manager.termTemplate) {
        if (!s.isGroup) {
          subjects.add(Subject(s.name, s.coefficient));
        } else {
          Subject group = Subject(s.name, s.coefficient, isGroup: true);
          subjects.add(group);
          for (Subject s1 in s.children) {
            group.children.add(Subject(s1.name, s1.coefficient));
          }
        }
      }
    }

    //TODO remove test code
    subjects.add(Subject("Group", 1, isGroup: true)..children.addAll([Subject("Subject1", 1), Subject("Subject2", 1)]));
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
    if (subjects.every((element) => element.getResult() == "-") || result == null) {
      return "-";
    } else {
      return Calculator.format(result);
    }
  }

  Term.fromJson(Map<String, dynamic> json) {
    if (json['subjects'] != null) {
      var subjectList = json["subjects"] as List;
      List<Subject> s = subjectList.map((subjectJson) {
        return Subject.fromJson(subjectJson);
      }).toList();

      subjects = s;
    }
  }

  Map<String, dynamic> toJson() => {
        "subjects": subjects,
      };
}
