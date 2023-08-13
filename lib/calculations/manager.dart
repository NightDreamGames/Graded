// Project imports:
import "package:graded/calculations/subject.dart";
import "package:graded/calculations/term.dart";
import "package:graded/calculations/test.dart";
import "package:graded/calculations/year.dart";
import "package:graded/localization/translations.dart";
import "package:graded/misc/compatibility.dart";
import "package:graded/misc/enums.dart";
import "package:graded/misc/storage.dart";
import "package:graded/ui/utilities/hints.dart";

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

    sortAll();
  }

  static void clearSubjects() {
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

  static void addYear({List<Subject> termTemplate = const []}) {
    Year year = Year(termTemplate);
    years.add(year);
    year.name = getHint(translations.year, years);
    changeYear(years.length - 1);
    Compatibility.termCount();
    year.sort();
  }

  static void changeYear(int index) {
    currentYear = index;
    currentTerm = 0;
    calculate();
  }

  static void sortAll({int? sortModeOverride, int? sortDirectionOverride}) {
    getCurrentYear().sort(sortModeOverride: sortModeOverride, sortDirectionOverride: sortDirectionOverride);

    for (final Subject element in getCurrentYear().termTemplate) {
      element.sort(sortModeOverride: sortModeOverride, sortDirectionOverride: sortDirectionOverride);
    }

    getCurrentYear().sortTermTemplate(
      sortModeOverride: sortModeOverride,
      sortDirectionOverride: sortDirectionOverride,
    );

    if (sortModeOverride == null && sortDirectionOverride == null) {
      serialize();
    }
  }

  static Term refreshYearOverview({Term? yearOverview, Year? year}) {
    yearOverview ??= getYearOverview();
    year ??= getCurrentYear();

    Manager.sortAll(
      sortModeOverride: SortMode.name,
      sortDirectionOverride: SortDirection.ascending,
    );

    yearOverview.sort(
      sortModeOverride: SortMode.name,
      sortDirectionOverride: SortDirection.ascending,
    );

    for (final subject in yearOverview.subjects) {
      subject.tests.clear();
      for (final child in subject.children) {
        child.tests.clear();
      }
    }

    for (int i = 0; i < year.terms.length; i++) {
      Term t = year.terms[i];
      for (int j = 0; j < t.subjects.length; j++) {
        Subject s = yearOverview.subjects[j];

        if (s.isGroup) {
          for (int k = 0; k < s.children.length; k++) {
            double? subjectResult = t.subjects[j].children[k].result;
            s.children[k].addTest(
              Test(
                subjectResult ?? 0,
                getPreference<double>("total_grades"),
                name: getTitle(termIndex: i),
                coefficient: t.coefficient,
                isEmpty: subjectResult == null,
              ),
              calculate: false,
            );
          }
        } else {
          double? subjectResult = t.subjects[j].result;

          s.addTest(
            Test(
              subjectResult ?? 0,
              getPreference<double>("total_grades"),
              name: getTitle(termIndex: i),
              coefficient: t.coefficient,
              isEmpty: subjectResult == null,
            ),
            calculate: false,
          );
        }
      }
    }

    yearOverview.calculate();
    Manager.sortAll();
    yearOverview.sort();

    return yearOverview;
  }

  Map<String, dynamic> toJson() => {
        "years": years,
      };
}

Year getCurrentYear() {
  if (Manager.years.isEmpty) {
    deserialize();

    if (Manager.years.isEmpty) {
      Manager.addYear();
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
  Term yearOverview = Term(isYearOverview: true);

  Manager.refreshYearOverview(yearOverview: yearOverview, year: year);

  return yearOverview;
}

Term getCurrentTerm() {
  return getTerm(Manager.currentTerm);
}
