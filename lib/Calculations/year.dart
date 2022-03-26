import 'package:gradely/Calculations/manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'calculator.dart';
import 'term.dart';

class Year {
  final List<Term> terms = [];

  double result = 0;

  Year() {
    addTerms();

    calculate();
  }

  void addTerms() {
    for (int i = 0; i < Manager.maxTerm; i++) {
      terms.add(Term());
    }
  }

  void calculate() {
    List<double> results = [];
    List<double> coefficients = [];

    for (Term t in terms) {
      t.calculate();

      results.add(t.result);
      coefficients.add(1.0);
    }

    result = Calculator.calculate(results, coefficients);
  }

  String getResult() {
    if (result > -1) {
      return Calculator.format(result);
    } else {
      return "-";
    }
  }
}
