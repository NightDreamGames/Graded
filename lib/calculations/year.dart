// Project imports:
import "package:graded/calculations/calculation_object.dart";
import "package:graded/calculations/calculator.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/term.dart";
import "package:graded/misc/default_values.dart";

class Year extends CalculationObject {
  List<Term> terms = [];

  Year() {
    Manager.calculate();
  }

  void calculate() {
    for (final Term t in terms) {
      t.calculate();
    }

    double examCoefficient = defaultValues["exam_coefficient"] as double;
    int notEmptyTerms = terms.where((element) => element.result != null && !element.isExam).length;

    for (final Term t in terms) {
      if (t.isExam) {
        t.coefficient = examCoefficient * notEmptyTerms;
      }
    }

    result = Calculator.calculate(terms);
    preciseResult = Calculator.calculate(terms, precise: true);
  }

  Year.fromJson(Map<String, dynamic> json) {
    final termList = json["terms"] as List;
    List<Term> t = termList.map((termJson) => Term.fromJson(termJson as Map<String, dynamic>)).toList();

    terms = t;
  }

  Map<String, dynamic> toJson() => {
        "terms": terms,
      };
}
