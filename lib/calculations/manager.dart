// Flutter imports:
import "package:flutter/material.dart";

// Project imports:
import "package:graded/calculations/subject.dart";
import "package:graded/calculations/term.dart";
import "package:graded/calculations/test.dart";
import "package:graded/calculations/year.dart";
import "package:graded/localization/translations.dart";
import "package:graded/main.dart";
import "package:graded/misc/compatibility.dart";
import "package:graded/misc/setup_manager.dart";
import "package:graded/misc/storage.dart";
import "package:graded/ui/utilities/hints.dart";
import "package:graded/ui/utilities/ordered_collection.dart";

class Manager {
  static List<Year> years = [];

  static int _currentYear = 0;
  static int get currentYear => _currentYear;
  static set currentYear(int newValue) {
    setPreference<int>("current_year", newValue);
    _currentYear = newValue;
  }

  static int _currentTerm = 0;
  static int get currentTerm => _currentTerm;
  static set currentTerm(int newValue) {
    setPreference<int>("current_term", newValue);
    _currentTerm = newValue;
  }

  static bool deserializationError = false;

  static void init() {
    Compatibility.upgradeDataVersion();

    currentYear = getPreference<int>("current_year");
    currentTerm = getPreference<int>("current_term");

    if (years.isNotEmpty) calculate();
  }

  static void calculate() {
    getCurrentYear().calculate();

    serialize();
  }

  static void clearTests() {
    getCurrentYear().terms.forEach((term) {
      for (final subject in term.subjects) {
        subject.bonus = 0;
        subject.tests.clear();
        for (final child in subject.children) {
          child.bonus = 0;
          child.tests.clear();
        }
      }
    });

    calculate();
  }

  static void clearYears() {
    years.clear();
  }

  static void addYear({required Year year}) {
    year.name = getHint(translations.yearOne, years);
    years.add(year);
    changeYear(years.length - 1);
  }

  static void changeYear(int index) {
    currentYear = index;
    currentTerm = 0;
    calculate();
  }

  static Term refreshYearOverview({Term? yearOverview, Year? year}) {
    yearOverview ??= getYearOverview();
    year ??= getCurrentYear();

    for (final subject in yearOverview.subjects) {
      subject.tests.clear();
      for (final child in subject.children) {
        child.tests.clear();
      }
    }

    for (int i = 0; i < year.terms.length; i++) {
      final Term t = year.terms[i];
      for (int j = 0; j < t.subjects.length; j++) {
        final Subject s = yearOverview.subjects[j];

        if (s.isGroup) {
          for (int k = 0; k < s.children.length; k++) {
            final double? subjectResult = t.subjects[j].children[k].result;
            s.children[k].addTest(
              Test(
                subjectResult ?? 0,
                year.maxGrade,
                name: getTermName(termIndex: i),
                weight: t.weight,
                isEmpty: subjectResult == null,
              ),
              calculate: false,
            );
          }
        } else {
          final double? subjectResult = t.subjects[j].result;

          s.addTest(
            Test(
              subjectResult ?? 0,
              year.maxGrade,
              name: getTermName(termIndex: i),
              weight: t.weight,
              isEmpty: subjectResult == null,
            ),
            calculate: false,
          );
        }
      }
    }

    yearOverview.calculate();

    return yearOverview;
  }

  Map<String, dynamic> toJson() => {
        "years": years,
      };
}

Year getCurrentYear({bool allowSetup = true}) {
  if (SetupManager.inSetup && allowSetup) return SetupManager.year;

  if (Manager.years.isEmpty) {
    deserialize();

    if (Manager.years.isEmpty) {
      Navigator.of(navigatorKey.currentContext!).pushNamedAndRemoveUntil("/setup", (_) => false);
    }
  }

  return Manager.years[Manager.currentYear];
}

Term getTerm(int index) {
  if (index == getCurrentYear().terms.length) return getYearOverview();

  return getCurrentYear().terms[index];
}

Term getYearOverview() {
  return getCurrentYear().yearOverview;
}

Term createYearOverview({required Year year}) {
  final Term yearOverview = Term(isYearOverview: true);

  Manager.refreshYearOverview(yearOverview: yearOverview, year: year);

  return yearOverview;
}

Term getCurrentTerm() {
  return getTerm(Manager.currentTerm);
}

//TODO make more use of this function
List<Subject> getSubjectAcrossTerms(Subject subject) {
  final List<Subject> result = [];
  final (int, int?) indexes = getSubjectIndex(subject);

  for (final term in getCurrentYear().terms) {
    final Subject s = indexes.$2 == null ? term.subjects[indexes.$1] : term.subjects[indexes.$1].children[indexes.$2!];
    result.add(s);
  }
  return result;
}

Subject? getSubjectInTerm(Subject? subject, Term term) {
  if (subject == null) return null;

  final (int, int?) indexes = getSubjectIndex(subject);

  if (indexes.$2 == null) {
    return term.subjects[indexes.$1];
  } else {
    return term.subjects[indexes.$1].children[indexes.$2!];
  }
}

(int, int?) getSubjectIndex(Subject subject, {Term? term, bool? inTermTemplate, bool? inComparisonData, bool? isChild}) {
  final List<OrderedCollection<Subject>> lists = [];

  if (term != null) {
    lists.add(term.subjects);
  } else if (inComparisonData != null && inComparisonData) {
    lists.add(getCurrentYear().comparisonData);
  } else {
    if (inTermTemplate == null || inTermTemplate) {
      lists.add(getCurrentYear().termTemplate);
    }
    if (inTermTemplate == null || !inTermTemplate) {
      for (final term in getCurrentYear().terms) {
        lists.add(term.subjects);
      }
      lists.add(getYearOverview().subjects);
      lists.add(getCurrentYear().comparisonData);
    }
  }

  for (final subjects in lists) {
    if (isChild == null || !isChild) {
      final int result1 = subjects.indexOf(subject);
      if (result1 != -1) return (result1, null);
    }

    for (int j = 0; j < subjects.length; j++) {
      final int result2 = subjects[j].children.indexOf(subject);
      if (result2 != -1) return (j, result2);
    }
  }

  throw ArgumentError("Subject not found in terms");
}
