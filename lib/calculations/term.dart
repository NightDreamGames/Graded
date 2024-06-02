// Project imports:
import "package:graded/calculations/calculation_object.dart";
import "package:graded/calculations/calculator.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/ui/utilities/ordered_collection.dart";

class Term extends CalculationObject {
  OrderedCollection<Subject> subjects = OrderedCollection.newTreeSet();
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
      subjects.add(Subject.fromSubject(s));
    }
  }

  void calculate() {
    for (final Subject s in subjects) {
      s.calculate();
    }

    final List<Subject> toBeCalculated = subjects.toList();
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

    subjects = OrderedCollection.newTreeSet(s);
    weight = json["coefficient"] as double? ?? 1;
    isExam = json["isExam"] as bool? ?? false;
  }

  Map<String, dynamic> toJson() => {
        "coefficient": weight,
        "isExam": isExam,
        "subjects": subjects.toList(),
      };
}
