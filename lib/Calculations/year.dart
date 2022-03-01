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

  void addTerms() async {
    int k = 3;

    final prefs = await SharedPreferences.getInstance();
    switch (prefs.getString("term") ?? "term_trimester") {
      case "term_trimester":
        k = 3;
        break;
      case "term_semester":
        k = 2;
        break;
      case "term_year":
        k = 1;
        break;
    }
    for (int i = 0; i < k; i++) {
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
}
