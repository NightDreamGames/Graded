// Project imports:
import "package:graded/calculations/calculator.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/calculations/term.dart";
import "package:graded/calculations/test.dart";
import "package:graded/calculations/year.dart";
import "package:graded/misc/compatibility.dart";
import "package:graded/misc/enums.dart";
import "package:graded/misc/storage.dart";
import "package:graded/ui/utilities/hints.dart";

class Manager {
  static List<Year> years = [];
  static List<Subject> termTemplate = [];
  static int currentYear = 0;

  static int _currentTerm = 0;
  static int get currentTerm => _currentTerm;
  static set currentTerm(int newValue) {
    setPreference<int>("current_term", newValue);
    _currentTerm = newValue;
  }

  static bool deserializationError = false;

  static Future<void> init() async {
    await Compatibility.upgradeDataVersion();
    currentTerm = getPreference<int>("current_term");

    Manager.calculate();
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
    years.add(Year());
    Compatibility.termCount();
    Manager.currentTerm = 0;

    calculate();
  }

  static Year getCurrentYear() {
    if (years.isEmpty) {
      deserialize();

      if (years.isEmpty) {
        years.add(Year());
        Compatibility.termCount();
      }
    }

    return years[currentYear];
  }

  static Term getTerm(int index) {
    if (index == getCurrentYear().terms.length) return getYearOverview();

    return getCurrentYear().terms[index];
  }

  static Term getYearOverview() {
    return getCurrentYear().yearOverview;
  }

  static Term createYearOverview({required Year year}) {
    Term yearOverview = Term(isYearOverview: true);

    refreshYearOverview(yearOverview: yearOverview, year: year);

    return yearOverview;
  }

  static Term refreshYearOverview({required Term yearOverview, required Year year}) {
    Manager.sortAll(
      sortModeOverride: SortMode.name,
      sortDirectionOverride: SortDirection.ascending,
    );
    Calculator.sortObjects(
      yearOverview.subjects,
      sortType: SortType.subject,
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
    Calculator.sortObjects(yearOverview.subjects, sortType: SortType.subject);

    return yearOverview;
  }

  static Term getCurrentTerm() {
    return getTerm(currentTerm);
  }

  static void sortAll({int? sortModeOverride, int? sortDirectionOverride}) {
    getCurrentYear().sort(sortModeOverride: sortModeOverride, sortDirectionOverride: sortDirectionOverride);

    for (final Subject element in termTemplate) {
      element.sort(sortModeOverride: sortModeOverride, sortDirectionOverride: sortDirectionOverride);
    }
    Calculator.sortObjects(
      termTemplate,
      sortType: SortType.subject,
      sortModeOverride: sortModeOverride,
      sortDirectionOverride: sortDirectionOverride,
    );

    if (sortModeOverride == null && sortDirectionOverride == null) {
      serialize();
    }
  }

  Map<String, dynamic> toJson() => {
        "years": years,
        "term_template": termTemplate,
      };
}
