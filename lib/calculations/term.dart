// Project imports:
import "package:graded/calculations/calculation_object.dart";
import "package:graded/calculations/calculator.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/misc/enums.dart";

class Term extends CalculationObject {
  List<Subject> subjects = [];
  bool isExam = false;
  bool isYearOverview = false;
  @override
  double get denominator => getCurrentYear().maxGrade;

  Term({
    double weight = 1,
    String name = "",
    this.isExam = false,
    this.isYearOverview = false,
  }) {
    super.weight = weight;
    super.name = name;

    populateSubjects();
  }

  void populateSubjects() {
    subjects.clear();

    if (getCurrentYear().termTemplate.isEmpty) return;

    for (final Subject s in getCurrentYear().termTemplate) {
      if (!s.isGroup) {
        subjects.add(Subject.fromSubject(s));
      } else {
        final Subject group = Subject.fromSubject(s);
        subjects.add(group);
        for (final Subject child in s.children) {
          group.children.add(Subject.fromSubject(child));
        }
      }
    }
  }

  void calculate() {
    for (final Subject s in subjects) {
      s.calculate();
    }

    final List<Subject> toBeCalculated = [...subjects];
    for (int i = 0; i < toBeCalculated.length; i++) {
      if (toBeCalculated[i].weight == 0) {
        toBeCalculated.addAll(toBeCalculated[i].children);
        toBeCalculated.removeAt(i);
        i--;
      }
    }

    result = Calculator.calculate(toBeCalculated);
    preciseResult = Calculator.calculate(toBeCalculated, precise: true);
  }

  void sort({int? sortModeOverride, int? sortDirectionOverride}) {
    for (final Subject subject in subjects) {
      subject.sort(sortModeOverride: sortModeOverride, sortDirectionOverride: sortDirectionOverride);
    }

    Calculator.sortObjects(
      subjects,
      sortType: SortType.subject,
      sortModeOverride: sortModeOverride,
      sortDirectionOverride: sortDirectionOverride,
    );
  }

  @override
  String getResult({bool precise = false}) {
    if (subjects.every((element) => element.getResult() == "-")) return "-";
    return super.getResult(precise: precise);
  }

  Term.fromJson(Map<String, dynamic> json) {
    if (json["subjects"] == null) return;

    final subjectList = json["subjects"] as List;
    final List<Subject> s = subjectList.map((subjectJson) {
      return Subject.fromJson(subjectJson as Map<String, dynamic>);
    }).toList();

    subjects = s;
    weight = json["coefficient"] as double? ?? 1;
    isExam = json["isExam"] as bool? ?? false;
  }

  Map<String, dynamic> toJson() => {
        "subjects": subjects,
        "coefficient": weight,
        "isExam": isExam,
      };
}
