// Project imports:
import "package:graded/calculations/calculation_object.dart";
import "package:graded/calculations/calculator.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/term.dart";
import "package:graded/calculations/year.dart";
import "package:graded/misc/default_values.dart";

class Subject extends CalculationObject {
  List<Subject> children = [];
  List<Term> terms = [];
  @override
  double get denominator => getCurrentYear().maxGrade;

  bool isGroup = false;
  bool isChild = false;
  double speakingWeight = DefaultValues.speakingWeight;

  Subject(
    String name,
    double weight, {
    this.speakingWeight = DefaultValues.speakingWeight,
    this.isGroup = false,
    this.isChild = false,
  }) {
    super.name = name;
    super.weight = weight;
    ensureTermCount();
  }

  @override
  void calculate() {
    if (isGroup) {
      for (final Subject child in children) {
        child.calculate();
      }

      result = Calculator.calculate(children);
      preciseResult = Calculator.calculate(children, precise: true);
    } else {
      for (final Term term in terms) {
        term.calculate(speakingWeight: speakingWeight);
      }

      const double examWeight = DefaultValues.examWeight;
      final int nonEmptyTerms = terms.where((element) => element.result != null && !element.isExam).length;

      for (final Term t in terms) {
        if (t.isExam) {
          t.weight = examWeight * nonEmptyTerms;
        }
      }

      result = Calculator.calculate(terms);
      preciseResult = Calculator.calculate(terms, precise: true);
    }
  }

  void ensureTermCount({Year? year}) {
    year ??= getCurrentYear();

    if (isGroup) {
      for (final child in children) {
        child.ensureTermCount(year: year);
      }
      return;
    }

    final bool shouldHaveExam = year.validatedYear == 1;
    final bool hasExam = terms.isNotEmpty && terms.last.isExam;
    final int targetTermCount = year.termCount + (hasExam ? 1 : 0);

    while (terms.length > targetTermCount) {
      final int index = terms.length - 1 - (hasExam ? 1 : 0);
      terms.removeAt(index);
    }

    while (terms.length < targetTermCount) {
      final int index = terms.length - (hasExam ? 1 : 0);
      terms.insert(index, Term());
    }

    if (shouldHaveExam && !hasExam && terms.length < year.termCount + 1) {
      terms.add(Term(isExam: true));
    }
  }

  double? getTermResult(int termIndex, {bool precise = false}) {
    if (isGroup) {
      final List<CalculationObject> toCalculate = children.map((s) => Subject.copyWithTerms(s, termIndex)).toList();
      for (final CalculationObject c in toCalculate) {
        c.calculate();
      }

      return Calculator.calculate(toCalculate, precise: precise);
    } else {
      return precise ? terms[termIndex].preciseResult : terms[termIndex].result;
    }
  }

  String getTermResultString(int termIndex, {bool precise = false}) {
    return Calculator.format(getTermResult(termIndex, precise: precise), roundToMultiplier: precise ? DefaultValues.preciseRoundToMultiplier : 1);
  }

  Subject.fromSubject(Subject subject) {
    children = subject.children.map((e) => Subject.fromSubject(e)).toList();
    isGroup = subject.isGroup;
    isChild = subject.isChild;
    speakingWeight = subject.speakingWeight;
    name = subject.name;
    weight = subject.weight;
    ensureTermCount();
  }

  Subject.copyWithTerms(Subject subject, int termIndex) {
    isGroup = subject.isGroup;
    isChild = subject.isChild;
    speakingWeight = subject.speakingWeight;
    name = subject.name;
    weight = subject.weight;
    if (!subject.isGroup) {
      terms = [subject.terms[termIndex]];
    } else {
      children = subject.children.map((e) => Subject.copyWithTerms(e, termIndex)).toList();
    }
  }

  Subject.fromJson(Map<String, dynamic> json) {
    if (json["terms"] != null && json["terms"] is List && (json["terms"] as List).isNotEmpty) {
      final termsList = json["terms"] as List;
      terms = termsList.map((termJson) => Term.fromJson(termJson as Map<String, dynamic>)).toList();
    }
    if (json["children"] != null && json["children"] is List && (json["children"] as List).isNotEmpty) {
      final childrenList = json["children"] as List;
      children = childrenList.map((childJson) => Subject.fromJson(childJson as Map<String, dynamic>)..isChild = true).toList();
    }

    isGroup = json["type"] != null && json["type"] as bool;
    name = json["name"] as String;
    weight = json["coefficient"] as double;

    speakingWeight = json["speakingWeight"] as double? ?? DefaultValues.speakingWeight;
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "coefficient": weight,
        "speakingWeight": speakingWeight,
        "type": isGroup,
        "children": children.toList(),
        "terms": terms,
      };

  int compareTo(Subject other) => name.hashCode - other.name.hashCode;
}
