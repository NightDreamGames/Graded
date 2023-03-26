// Package imports:
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:graded/Calculations/Calculator.dart';
import 'package:graded/Calculations/manager.dart';
import 'package:graded/Calculations/subject.dart';
import 'package:graded/Calculations/test.dart';
import 'package:graded/Misc/storage.dart';
import 'package:graded/UI/Settings/flutter_settings_screens.dart';

void main() async {
  SharedPreferences.setMockInitialValues({});
  await Settings.init();
  await Manager.init();

  test('Calculations', () async {
    Manager.termTemplate.addAll({
      Subject("Test1", 3),
      Subject("Test2", 3),
      Subject("Test3", 3),
      Subject("Test4", 2),
      Subject("Test5", 1),
      Subject("Test6", 3),
      Subject("Test7", 3)
        ..isGroup = true
        ..children.addAll({
          Subject("Child1", 1)..isChild = true,
          Subject("Child2", 2)..isChild = true,
        }),
      Subject("Test8", 2),
      Subject("Test9", 2),
      Subject("Test10", 3),
      Subject("Test11", 2)
        ..isGroup = true
        ..children.addAll({
          Subject("Child3", 1)..isChild = true,
          Subject("Child4", 1)..isChild = true,
        }),
    });

    var list = Manager.getCurrentTerm().subjects = Manager.termTemplate;
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
    expect(Manager.getCurrentYear().result, equals(48));

    setPreference("round_to", 10);
    Manager.calculate();
    expect(Manager.getCurrentYear().result, equals(47.8));

    setPreference("round_to", 100);
    setPreference("rounding_mode", RoundingMode.halfDown);
    Manager.calculate();
    expect(Manager.getCurrentYear().result, equals(47.71));
  });
}
