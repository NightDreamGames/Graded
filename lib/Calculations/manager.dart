import 'package:flutter/material.dart';

import '../Misc/preferences.dart';
import '../Misc/serialization.dart';
import 'calculator.dart';
import 'subject.dart';
import 'term.dart';
import 'test.dart';
import 'year.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Manager {
  static int totalGrades = 0;
  static List<Year> years = [];
  static List<Subject> termTemplate = [];
  static int currentYear = 0;

  static int _currentTerm = 0;
  static int get currentTerm => _currentTerm;
  static set currentTerm(int newValue) {
    Preferences.setPreference("current_term", newValue);
    _currentTerm = newValue;
  }

  static int maxTerm = 1;

  static void init() async {
    WidgetsFlutterBinding.ensureInitialized();

    await readPreferences();

    termTemplate = [];
    termTemplate.add(Subject("Allemand", 2));
    termTemplate.add(Subject("Programmation", 3));
    termTemplate.add(Subject("Education physique", 1));
    /* termTemplate.add(Subject("a", 1));
    termTemplate.add(Subject("b", 1));
    termTemplate.add(Subject("c", 1));
    termTemplate.add(Subject("d", 1));
    termTemplate.add(Subject("e", 1));
    termTemplate.add(Subject("f", 1));
    termTemplate.add(Subject("g", 1));
    termTemplate.add(Subject("he", 1));
    termTemplate.add(Subject("hfe", 1));
    termTemplate.add(Subject("hsadfe", 1));
    termTemplate.add(Subject("hasvdae", 1));
    termTemplate.add(Subject("hveasde", 1));
    termTemplate.add(Subject("hqwvetbe", 1));
    termTemplate.add(Subject("hfgsde", 1));
    termTemplate.add(Subject("hlozuzjte", 1));*/

    years = [];
    years.add(Year());
  }

  static Future<void> readPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    currentTerm = prefs.getInt("current_term") ?? 0;

    switch (prefs.getString("term") ?? "term_trimester") {
      case "term_trimester":
        maxTerm = 3;
        break;
      case "term_semester":
        maxTerm = 2;
        break;
      case "term_year":
        maxTerm = 1;
        break;
    }

    interpretPreferences();
  }

  static void interpretPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    if ((prefs.getInt("total_grades") ?? 100) != -1) {
      totalGrades = prefs.getInt("total_grades") ?? 100;
    } else {
      totalGrades = prefs.getInt("custom_grade") ?? 100;
    }
  }

  static void calculate() {
    for (Year y in years) {
      y.calculate();
    }
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
      Term p = Term();
      String name = "";
      getName().then((value) => name = value);

      for (int i = 0; i < getCurrentYear().terms.length; i++) {
        for (int j = 0; j < getCurrentYear().terms[i].subjects.length; j++) {
          if (getCurrentYear().terms[i].subjects[i].result != -1) {
            p.subjects[j].addTest(Test(getCurrentYear().terms[i].subjects[j].result, totalGrades.toDouble(), name));
          }
        }
      }

      p.calculate();
      return p;
    }

    return getCurrentYear().terms[currentTerm];
    //return years[0].terms[currentTerm];
  }

  static Future<String> getName() async {
    String name = "";

    final prefs = await SharedPreferences.getInstance();
    if ((prefs.getString("term") ?? "term_trimester") == "term_trimester") {
      // TODO string manager
      /*name = MainActivity.sApplication.getString(MainActivity.sApplication
                .getResources()
                .getIdentifier("trimester_" + (i + 1).toString(), "string",
                    MainActivity.sApplication.getPackageName()));*/
    } else {
      /*name = MainActivity.sApplication.getString(MainActivity.sApplication
                .getResources()
                .getIdentifier("semester_" + (i + 1).toString(), "string",
                    MainActivity.sApplication.getPackageName()));*/
    }
    return name;
  }

  static void sortAll() {
    for (Year y in years) {
      for (Term p in y.terms) {
        p.sort();
        for (Subject s in p.subjects) {
          s.sort();
        }
      }
    }

    Calculator.sort1(termTemplate, "sort_mode3");

    Serialization.Serialize();
  }
}
