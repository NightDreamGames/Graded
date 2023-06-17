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

  static int lastTerm = 0;

  static bool deserializationError = false;

  static Future<void> init() async {
    await Compatibility.upgradeDataVersion();
    currentTerm = getPreference<int>("current_term");

    Manager.calculate();
  }

  static void calculate() {
    for (final Year y in years) {
      y.calculate();
    }

    sortAll();
  }

  static void clear() {
    years.clear();
    years.add(Year());
    Compatibility.termCount();
    Manager.currentTerm = 0;

    calculate();
  }

  static Year getCurrentYear() {
    if (years.isEmpty) {
      deserialize();
    }

    if (years.isEmpty) {
      years.add(Year());
      Compatibility.termCount();
    }

    return years[currentYear];
  }

  static Term getCurrentTerm() {
    if (currentTerm == -1) {
      Year currentYear = getCurrentYear();
      Term yearTerm = Term();
      Manager.sortAll(sortModeOverride: SortMode.name);
      Calculator.sortObjects(yearTerm.subjects, sortType: SortType.subject, sortModeOverride: SortMode.name);

      for (int i = 0; i < currentYear.terms.length; i++) {
        Term t = currentYear.terms[i];
        for (int j = 0; j < t.subjects.length; j++) {
          Subject s = yearTerm.subjects[j];

          if (s.isGroup) {
            for (int k = 0; k < s.children.length; k++) {
              double? subjectResult = t.subjects[j].children[k].result;
              s.children[k].addTest(
                Test(
                  subjectResult ?? 0,
                  getPreference<double>("total_grades"),
                  name: getTitle(termOverride: i),
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
                name: getTitle(termOverride: i),
                coefficient: t.coefficient,
                isEmpty: subjectResult == null,
              ),
              calculate: false,
            );
          }
        }
      }

      yearTerm.calculate();
      Calculator.sortObjects(yearTerm.subjects, sortType: SortType.subject);

      return yearTerm;
    }

    return getCurrentYear().terms[currentTerm];
  }

  static void sortAll({int? sortModeOverride, int? sortDirectionOverride}) {
    for (final Year y in years) {
      for (final Term t in y.terms) {
        for (final Subject s in t.subjects) {
          s.sort(sortModeOverride: sortModeOverride, sortDirectionOverride: sortDirectionOverride);
        }
        t.sort(sortModeOverride: sortModeOverride, sortDirectionOverride: sortDirectionOverride);
      }
    }

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
