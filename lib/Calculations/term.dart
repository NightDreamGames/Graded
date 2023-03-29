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
          subjects.add(Subject(s.name, s.coefficient, s.speakingWeight));
        } else {
          Subject group = Subject(s.name, s.coefficient, s.speakingWeight, isGroup: true);
          subjects.add(group);
          for (Subject s1 in s.children) {
            group.children.add(Subject(s1.name, s1.coefficient, s1.speakingWeight));
          }
        }
      }
    }
  }

  void calculate() {
    for (Subject s in subjects) {
      s.calculate();
    }

    List<Subject> toBeCalculated = [...subjects];
    for (int i = 0; i < toBeCalculated.length; i++) {
      if (toBeCalculated[i].coefficient == 0) {
        toBeCalculated.addAll(toBeCalculated[i].children);
        toBeCalculated.removeAt(i);
        i--;
      }
    }

    result = Calculator.calculate(toBeCalculated);
    preciseResult = Calculator.calculate(toBeCalculated, precise: true);
  }

  void sort({int? sortModeOverride}) {
    Calculator.sortObjects(subjects, sortType: SortType.subject, sortModeOverride: sortModeOverride);
  }

  @override
  String getResult({bool precise = false}) {
    if (subjects.every((element) => element.getResult() == "-")) {
      return "-";
    }
    return super.getResult(precise: precise);
  }

  Term.fromJson(Map<String, dynamic> json) {
    if (json['subjects'] != null) {
      var subjectList = json["subjects"] as List;
      List<Subject> s = subjectList.map((subjectJson) {
        return Subject.fromJson(subjectJson);
      }).toList();

      subjects = s;
      coefficient = json['coefficient'] ?? 1;
    }
  }

  Map<String, dynamic> toJson() => {
        "subjects": subjects,
        "coefficient": coefficient,
      };
}
