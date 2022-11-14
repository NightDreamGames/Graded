import 'dart:developer';

import 'package:flutter/material.dart';

import '../Misc/compatibility.dart';
import '../Misc/storage.dart';
import '../Translation/translations.dart';
import 'calculator.dart';
import 'subject.dart';
import 'term.dart';
import 'test.dart';
import 'year.dart';

class Manager {
  static double totalGrades = 0;
  static List<Year> years = [];
  static List<Subject> termTemplate = [];
  static int currentYear = 0;

  static int _currentTerm = 0;
  static int get currentTerm => _currentTerm;
  static set currentTerm(int newValue) {
    Storage.setPreference<int>("current_term", newValue);
    _currentTerm = newValue;
  }

  static int _lastTerm = 0;
  static int get lastTerm => _lastTerm;
  static set lastTerm(int newValue) {
    Storage.setPreference<int>("last_term", newValue);
    _lastTerm = newValue;
  }

  static int maxTerm = 1;

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (Storage.getPreference<bool>("is_first_run")) {
      try {
        await Compatibility.importPreferences();
      } catch (e) {
        log("Error while importing old data: $e");
      }
    }

    readPreferences();

    await Storage.deserialize();

    if (years.isEmpty) {
      years.add(Year());
    }

    Manager.calculate();
  }

  static void readPreferences() {
    currentTerm = Storage.getPreference<int>("current_term");
    maxTerm = Storage.getPreference<int>("term");
    totalGrades = Storage.getPreference<double>("total_grades");
  }

  static void calculate() {
    for (Year y in years) {
      y.calculate();
    }

    sortAll();
  }

  static void clear() {
    for (Year y in years) {
      for (Term p in y.terms) {
        for (Subject s in p.subjects) {
          for (int i = 0; i < s.tests.length;) {
            s.removeTest(i);
          }
          s.bonus = 0;
        }
      }
    }
  }

  static Year getCurrentYear() {
    return years[currentYear];
  }

  static Term getCurrentTerm() {
    if (currentTerm == -1) {
      Term yearTerm = Term();
      Manager.sortSubjectsAZ();

      for (int i = 0; i < getCurrentYear().terms.length; i++) {
        for (int j = 0; j < getCurrentYear().terms[i].subjects.length; j++) {
          if (getCurrentYear().terms[i].subjects[j].result != -1) {
            String name = "";
            switch (i) {
              case 0:
                name = (maxTerm == 3) ? Translations.trimester_1 : Translations.semester_1;
                break;
              case 1:
                name = (maxTerm == 3) ? Translations.trimester_2 : Translations.semester_2;
                break;
              case 2:
                name = Translations.trimester_3;
                break;
              default:
                name = Translations.trimester_1;
                break;
            }

            yearTerm.subjects[j].addTest(Test(getCurrentYear().terms[i].subjects[j].result, totalGrades.toDouble(), name), calculate: false);
          }
        }
      }

      yearTerm.calculate();
      Calculator.sortSubjects(yearTerm.subjects, "sort_mode1");
      return yearTerm;
    }

    return getCurrentYear().terms[currentTerm];
  }

  //TODO Reduce number of times sort is called
  static void sortAll() {
    for (Year y in years) {
      for (Term p in y.terms) {
        for (Subject s in p.subjects) {
          s.sort();
        }
        p.sort();
      }
    }

    Calculator.sortSubjects(termTemplate, "sort_mode3");

    Storage.serialize();
  }

  static void sortSubjectsAZ() {
    for (Year y in years) {
      for (Term p in y.terms) {
        p.sort(sortModeOverride: 0);
      }
    }

    Calculator.sortSubjects(termTemplate, "", sortModeOverride: 0);
  }

  Map<String, dynamic> toJson() => {"years": years, "term_template": termTemplate};
}
