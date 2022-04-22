import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:json_annotation/json_annotation.dart';

import '../Misc/preferences.dart';
import '../Misc/serialization.dart';
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
    Preferences.setPreference("current_term", newValue);
    _currentTerm = newValue;
  }

  static int maxTerm = 1;

  Manager();

  static void init() {
    WidgetsFlutterBinding.ensureInitialized();

    readPreferences();

    termTemplate = [];
    termTemplate.add(Subject("Allemand", 2));
    termTemplate.add(Subject("Programmation", 3));
    termTemplate.add(Subject("Education physique", 1));
    termTemplate.add(Subject("Education physidqfskfghjqslfhjkqsdlkfjh qldkjh qlskjh que", 1));
    termTemplate.add(Subject("a", 1));
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
    termTemplate.add(Subject("hlozuzjte", 1));

    years = [];
    years.add(Year());

    getCurrentTerm().subjects[0].addTest(Test(30, 60, "aTest 1"));
    getCurrentTerm().subjects[0].addTest(Test(45, 60, "58Test 2"));
    getCurrentTerm().subjects[0].addTest(Test(2.5, 60, "Test 3"));
    getCurrentTerm().subjects[0].addTest(Test(56, 60, "Test 4"));
    getCurrentTerm().subjects[0].addTest(Test(56, 60, "bTest 4"));
    getCurrentTerm().subjects[0].addTest(Test(56, 60, "Test 4"));
    getCurrentTerm().subjects[0].addTest(Test(56, 60, "Test 4"));
    getCurrentTerm().subjects[0].addTest(Test(56, 60, "zTest 4"));
    getCurrentTerm().subjects[0].addTest(Test(56, 60, "Test 4"));
    getCurrentTerm().subjects[0].addTest(Test(56, 60, "Test 4"));
    getCurrentTerm().subjects[0].addTest(Test(56, 60, "Test 4"));
    getCurrentTerm().subjects[0].addTest(Test(56, 60, "cTest 4"));
    getCurrentTerm().subjects[0].addTest(Test(56, 60, "Test 4"));
    getCurrentTerm().subjects[0].addTest(Test(56, 60, "Test 4"));
    getCurrentTerm().subjects[0].addTest(Test(56, 60, "Test 4"));
    getCurrentTerm().subjects[0].addTest(Test(56, 60, "Test 4"));
    getCurrentTerm().subjects[0].addTest(Test(56, 60, "dTest 4"));
    getCurrentTerm().subjects[0].addTest(Test(56, 60, "Test 4"));
    getCurrentTerm().subjects[0].addTest(Test(56, 60, "uTest 4"));
    getCurrentTerm().subjects[0].addTest(Test(56, 60, "Test 4"));
    getCurrentTerm().subjects[0].addTest(Test(56, 60, "Test 4"));
    getCurrentTerm().subjects[0].addTest(Test(56, 60, "Test 4"));

    Serialization.deserialize();
    Manager.sortAll();
  }

  static void readPreferences() {
    currentTerm = Settings.getValue<int>("current_term", 0);
    maxTerm = Settings.getValue<int>("term", 3);
    totalGrades = double.parse(Settings.getValue<String>("total_grades", "60"));
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
      Term p = Term();

      for (int i = 0; i < getCurrentYear().terms.length; i++) {
        for (int j = 0; j < getCurrentYear().terms[i].subjects.length; j++) {
          if (getCurrentYear().terms[i].subjects[i].result != -1) {
            p.subjects[j].addTest(Test(getCurrentYear().terms[i].subjects[j].result, totalGrades.toDouble(), "", nameResource: getName(i)));
          }
        }
      }

      p.calculate();
      return p;
    }

    return getCurrentYear().terms[currentTerm];
  }

  static String getName(int i) {
    if (maxTerm == 3) {
      return "trimester_" + currentTerm.toString();
    } else {
      return "semester_" + currentTerm.toString();
    }
  }

  static void sortAll() {
    for (Year y in years) {
      for (Term p in y.terms) {
        for (Subject s in p.subjects) {
          s.sort();
        }
        p.sort();
      }
    }

    Calculator.sort1(termTemplate, "sort_mode3");

    Serialization.serialize();
  }
}
