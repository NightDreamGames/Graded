// Project imports:
import 'calculation_object.dart';
import 'calculator.dart';
import 'manager.dart';
import 'term.dart';

class Year extends CalculationObject {
  List<Term> terms = [];

  Year() {
    addTerms();

    calculate();
  }

  void addTerms() {
    for (int i = 0; i < Manager.maxTerm; i++) {
      terms.add(Term());
    }

    Manager.calculate();
  }

  void calculate() {
    for (Term t in terms) {
      t.calculate();
    }

    result = Calculator.calculate(terms);
  }

  String getResult() {
    if (result != null) {
      return Calculator.format(result);
    } else {
      return "-";
    }
  }

  Year.fromJson(Map<String, dynamic> json) {
    var termList = json["terms"] as List;
    List<Term> t = termList.map((termJson) => Term.fromJson(termJson)).toList();

    terms = t;
  }

  Map<String, dynamic> toJson() => {
        "terms": terms,
      };
}
