import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gradely/Translation/i18n.dart';

import '../Misc/compatibility.dart';
import '../Misc/storage.dart';
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

  static int maxTerm = 1;

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (Storage.getPreference<bool>("isFirstRunFlutter", true)) {
      try {
        await Compatibility.importPreferences();
      } catch (e) {
        log("Error while importing old data: " + e.toString());
      }
    }

    readPreferences();

    await Storage.deserialize();

    if (years.isEmpty) {
      years.add(Year());
    }

    //fillSampleData();

    Manager.calculate();

    Storage.setPreference<bool>("isFirstRunFlutter", false);
  }

  static void readPreferences() {
    currentTerm = Storage.getPreference<int>("current_term", defaultValues["current_term"]);
    maxTerm = Storage.getPreference<int>("term", defaultValues["term"]);
    totalGrades = Storage.getPreference<double>("total_grades", defaultValues["total_grades"]);
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

  static Term getCurrentTerm({dynamic context}) {
    if (currentTerm == -1) {
      Term p = Term();
      Year year = getCurrentYear();
      for (int i = 0; i < getCurrentYear().terms.length; i++) {
        for (int j = 0; j < getCurrentYear().terms[i].subjects.length; j++) {
          if (getCurrentYear().terms[i].subjects[j].result != -1) {
            String name = "";
            switch (i) {
              case 0:
                name = (maxTerm == 3) ? I18n.of(context).trimester_1 : I18n.of(context).semester_1;
                break;
              case 1:
                name = (maxTerm == 3) ? I18n.of(context).trimester_2 : I18n.of(context).semester_2;
                break;
              case 2:
                name = I18n.of(context).trimester_3;
                break;
              default:
                name = I18n.of(context).trimester_1;
                break;
            }

            p.subjects[j].addTest(Test(getCurrentYear().terms[i].subjects[j].result, totalGrades.toDouble(), name));
          }
        }
      }

      p.calculate();
      return p;
    }

    return getCurrentYear().terms[currentTerm];
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

    Storage.serialize();
  }

  static void fillSampleData() {
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
  }

  Map<String, dynamic> toJson() => {"years": years, "term_template": termTemplate};
}
