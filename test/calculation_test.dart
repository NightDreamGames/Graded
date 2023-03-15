// Package imports:
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:graded/Calculations/Calculator.dart';
import 'package:graded/Calculations/calculation_object.dart';
import 'package:graded/Calculations/manager.dart';
import 'package:graded/Calculations/test.dart';
import 'package:graded/UI/Settings/flutter_settings_screens.dart';

void main() async {
  SharedPreferences.setMockInitialValues({});
  await Settings.init();
  await Manager.init();

  test('Calculations with different weights', () {
    List<CalculationObject> objects = [Test(47.5, 50, "Test1"), Test(68.7, 70, "Test2"), Test(50, 55, "Test3")];

    expect(Calculator.calculate(objects), equals(57.0));
    expect(Calculator.calculate(objects, bonus: -3), equals(54.0));
    expect(Calculator.calculate(objects, bonus: -3, precise: true), equals(53.99));
  });

  test('Number formatting', () {
    expect(Calculator.format(47), equals("47"));
    expect(Calculator.format(47, roundToOverride: 10), equals("47.0"));
    expect(Calculator.format(47.5), equals("47.5"));
    expect(Calculator.format(47.5, roundToOverride: 100), equals("47.50"));
    expect(Calculator.format(1, addZero: false), equals("1"));
    expect(Calculator.format(1), equals("01"));
  });

  test('Number rounding', () {
    expect(Calculator.round(47), equals(47));
    expect(Calculator.round(47.11), equals(48));
    expect(Calculator.round(47.111, roundToOverride: 10), equals(47.2));
    expect(Calculator.round(47.199, roundToOverride: 100), equals(47.2));
    expect(Calculator.round(47.199, roundingModeOverride: RoundingMode.down), equals(47));
    expect(Calculator.round(47.5, roundingModeOverride: RoundingMode.halfUp), equals(48));
    expect(Calculator.round(47.05, roundingModeOverride: RoundingMode.halfDown, roundToOverride: 10), equals(47));
  });

  test('Number parsing', () {
    expect(Calculator.round(47), equals(47));
  });

  test('Object sorting', () {
    expect(Calculator.round(47), equals(47));
  });
}
