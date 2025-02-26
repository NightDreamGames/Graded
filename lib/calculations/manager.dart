// Flutter imports:
import "package:flutter/material.dart";

// Project imports:
import "package:graded/calculations/subject.dart";
import "package:graded/calculations/test.dart";
import "package:graded/calculations/year.dart";
import "package:graded/l10n/translations.dart";
import "package:graded/main.dart";
import "package:graded/misc/compatibility.dart";
import "package:graded/misc/setup_manager.dart";
import "package:graded/misc/storage.dart";
import "package:graded/ui/utilities/hints.dart";

class Manager {
  static List<Year> years = [];

  static int _currentYear = 0;
  static int get currentYear => _currentYear;
  static set currentYear(int newValue) {
    setPreference<int>("currentYear", newValue);
    _currentYear = newValue;
  }

  static int _currentTerm = 0;
  static int get currentTerm => _currentTerm;
  static set currentTerm(int newValue) {
    setPreference<int>("currentTerm", newValue);
    _currentTerm = newValue;
  }

  static bool deserializationError = false;

  static void init() {
    Compatibility.upgradeDataVersion();

    currentYear = getPreference<int>("currentYear");
    currentTerm = getPreference<int>("currentTerm");

    if (years.isNotEmpty) calculate();
  }

  static void calculate() {
    getCurrentYear().calculate();

    serialize();
  }

  static void clearTests() {
    getCurrentYear().subjects.forEach((subject) {
      for (final term in subject.terms) {
        term.bonus = 0;
        term.tests.clear();
      }
      for (final child in subject.children) {
        for (final term in child.terms) {
          term.bonus = 0;
          term.tests.clear();
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

  static int getAmountOfTerms() {
    return getCurrentYear().termCount + (getCurrentYear().validatedYear == 1 ? 1 : 0);
  }

  static Year refreshYearOverview({Year? yearOverview, Year? year}) {
    yearOverview ??= getYearOverview();
    year ??= getCurrentYear();

    for (final subject in yearOverview.subjects) {
      for (final term in subject.terms) {
        term.tests.clear();
      }
      for (final child in subject.children) {
        for (final term in child.terms) {
          term.tests.clear();
        }
      }
    }

    for (int i = 0; i < year.subjects.length; i++) {
      final Subject t = year.subjects[i];
      final Subject s = yearOverview.subjects[i];
      for (int j = 0; j < getAmountOfTerms(); j++) {
        if (s.isGroup) {
          for (int k = 0; k < s.children.length; k++) {
            final double? subjectResult = t.children[k].terms[j].result;
            s.children[k].terms[0].addTest(
              Test(
                subjectResult ?? 0,
                year.maxGrade,
                name: getTermName(termIndex: j),
                weight: t.children[k].terms[j].weight,
                isEmpty: subjectResult == null,
              ),
              calculate: false,
            );
          }
        } else {
          final double? subjectResult = t.terms[j].result;

          s.terms[0].addTest(
            Test(
              subjectResult ?? 0,
              year.maxGrade,
              name: getTermName(termIndex: j),
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

Year getYearOverview() {
  return getCurrentYear().yearOverview;
}

Year createYearOverview({required Year year}) {
  final Year yearOverview = Year(isYearOverview: true);

  if (getCurrentYear().subjects.isEmpty) return yearOverview;

  for (final Subject s in getCurrentYear().subjects) {
    yearOverview.subjects.add(Subject.fromSubject(s));
  }

  Manager.refreshYearOverview(yearOverview: yearOverview, year: year);

  return yearOverview;
}

Subject getSubjectInYearOverview(Subject subject) {
  final Year year = getCurrentYear();
  final Year yearOverview = getYearOverview();

  return getSubjectInSpecificYear(subject, year, yearOverview);
}

Subject getSubjectInYear(Subject subject) {
  final Year year = getCurrentYear();
  final Year yearOverview = getYearOverview();

  return getSubjectInSpecificYear(subject, yearOverview, year);
}

Subject getSubjectInSpecificYear(Subject subject, Year oldYear, Year newYear) {
  if (newYear.subjects.contains(subject) || newYear.subjects.any((s) => s.children.contains(subject))) return subject;

  final int index = oldYear.subjects.indexOf(subject);
  if (index == -1) {
    for (final Subject s in oldYear.subjects) {
      final int childIndex = s.children.indexOf(subject);
      if (childIndex != -1) {
        return newYear.subjects[oldYear.subjects.indexOf(s)].children[childIndex];
      }
    }
  }

  return newYear.subjects[oldYear.subjects.indexOf(subject)];
}
