// Project imports:
import '../Misc/compatibility.dart';
import '../Misc/storage.dart';
import '../UI/Utilities/hints.dart';
import 'calculator.dart';
import 'subject.dart';
import 'term.dart';
import 'test.dart';
import 'year.dart';

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
    for (Year y in years) {
      y.calculate();
    }

    sortAll();
  }

  static void clear() {
    years.clear();
    years.add(Year());
    Manager.currentTerm = 0;

    calculate();
  }

  static Year getCurrentYear() {
    if (years.isEmpty) {
      deserialize();
    }

    if (years.isEmpty) {
      years.add(Year());
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
                  Test(subjectResult ?? 0, getPreference<double>("total_grades"), getTitle(termOverride: i), isEmpty: subjectResult == null),
                  calculate: false);
            }
          } else {
            double? subjectResult = t.subjects[j].result;
            s.addTest(Test(subjectResult ?? 0, getPreference<double>("total_grades"), getTitle(termOverride: i), isEmpty: subjectResult == null),
                calculate: false);
          }
        }
      }

      yearTerm.calculate();
      Calculator.sortObjects(yearTerm.subjects, sortType: SortType.subject);

      return yearTerm;
    }

    return getCurrentYear().terms[currentTerm];
  }

  static void sortAll({int? sortModeOverride}) {
    for (Year y in years) {
      for (Term t in y.terms) {
        for (Subject s in t.subjects) {
          s.sort(sortModeOverride: sortModeOverride);
        }
        t.sort(sortModeOverride: sortModeOverride);
      }
    }

    for (Subject element in termTemplate) {
      element.sort(sortModeOverride: sortModeOverride);
    }
    Calculator.sortObjects(termTemplate, sortType: SortType.subject, sortModeOverride: sortModeOverride);

    if (sortModeOverride == null) {
      serialize();
    }
  }

  Map<String, dynamic> toJson() => {
        "years": years,
        "term_template": termTemplate,
      };
}
