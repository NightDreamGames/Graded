// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:shared_preferences/shared_preferences.dart";
import "package:test/test.dart";

// Project imports:
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/calculations/test.dart";
import "package:graded/calculations/year.dart";
import "package:graded/localization/generated/l10n.dart";
import "package:graded/misc/default_values.dart";
import "package:graded/misc/enums.dart";
import "package:graded/ui/settings/flutter_settings_screens.dart";

void main() async {
  SharedPreferences.setMockInitialValues({});
  await Settings.init();
  TranslationsClass.load(const Locale("en", ""));
  Manager.init();
  Manager.addYear(year: Year());
  getCurrentYear().ensureTermCount();

  test("Calculations", () async {
    getCurrentYear().termTemplate = [
      Subject("Test1", 3, defaultValues["speaking_weight"] as double),
      Subject("Test2", 3, defaultValues["speaking_weight"] as double),
      Subject("Test3", 3, defaultValues["speaking_weight"] as double),
      Subject("Test4", 2, defaultValues["speaking_weight"] as double),
      Subject("Test5", 1, defaultValues["speaking_weight"] as double),
      Subject("Test6", 3, defaultValues["speaking_weight"] as double),
      Subject("Test7", 3, defaultValues["speaking_weight"] as double)
        ..isGroup = true
        ..children.addAll({
          Subject("Child1", 1, defaultValues["speaking_weight"] as double)..isChild = true,
          Subject("Child2", 2, defaultValues["speaking_weight"] as double)..isChild = true,
        }),
      Subject("Test8", 2, defaultValues["speaking_weight"] as double),
      Subject("Test9", 2, defaultValues["speaking_weight"] as double),
      Subject("Test10", 3, defaultValues["speaking_weight"] as double),
      Subject("Test11", 2, defaultValues["speaking_weight"] as double)
        ..isGroup = true
        ..children.addAll({
          Subject("Child3", 1, defaultValues["speaking_weight"] as double)..isChild = true,
          Subject("Child4", 1, defaultValues["speaking_weight"] as double)..isChild = true,
        }),
    ];

    final list = getCurrentTerm().subjects = getCurrentYear().termTemplate;
    list[0].tests.addAll({Test(58, 60), Test(43, 60)});
    list[1].tests.addAll({Test(54, 60), Test(51, 60)});
    list[2].tests.addAll({Test(54, 60), Test(44, 60)});
    list[3].tests.addAll({Test(57, 60), Test(39, 60)});
    list[4].tests.addAll({Test(51, 60)});
    list[5].tests.addAll({Test(38.6, 40), Test(52, 60), Test(39, 60)});
    list[6].children[0].tests.addAll({Test(32, 60)});
    list[6].children[1].tests.addAll({Test(17, 60), Test(44, 60)});
    list[7].tests.addAll({Test(46, 60)});
    list[8].tests.addAll({Test(46, 60), Test(34, 60)});
    list[9].tests.addAll({Test(57, 60), Test(53, 60)});
    list[10].children[0].tests.addAll({Test(47.5, 50), Test(68.7, 70), Test(50, 55)});
    list[10].children[1].tests.addAll({Test(52, 60), Test(53, 60)});

    Manager.calculate();
    expect(getCurrentYear().result, equals(48));

    getCurrentYear().roundTo = 10;
    Manager.calculate();
    expect(getCurrentYear().result, equals(47.8));

    getCurrentYear().roundTo = 100;
    getCurrentYear().roundingMode = RoundingMode.halfDown;
    Manager.calculate();
    expect(getCurrentYear().result, equals(47.71));
  });
}
