// Package imports:
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:graded/Calculations/Calculator.dart';
import 'package:graded/Calculations/calculation_object.dart';
import 'package:graded/Calculations/manager.dart';
import 'package:graded/Calculations/term.dart';
import 'package:graded/Calculations/test.dart';
import 'package:graded/Misc/storage.dart';
import 'package:graded/UI/Settings/flutter_settings_screens.dart';

void main() async {
  SharedPreferences.setMockInitialValues({});
  await Settings.init();
  await Manager.init();

  test('Calculations', () async {
    List<CalculationObject> emptyList = [Test(null, 0), Test(null, 0), Test(null, 0)];
    List<CalculationObject> oneItemList = [Test(80, 100)];
    List<CalculationObject> multipleItemsList = [Test(47.5, 50), Test(68.7, 70), Test(50, 55)];
    List<CalculationObject> speakingList = [Test(0, 60, isSpeaking: true), Test(60, 60)];

    expect(Calculator.calculate([]), equals(null));
    expect(Calculator.calculate(emptyList), equals(null));
    expect(Calculator.calculate(speakingList, speakingWeight: 3), equals(45));
    expect(Calculator.calculate(multipleItemsList), equals(57.0));
    expect(Calculator.calculate(multipleItemsList, bonus: -3), equals(54.0));
    expect(Calculator.calculate(multipleItemsList, bonus: 3, precise: true), equals(59.99));

    expect(Calculator.calculate(oneItemList), equals(48.0));
    setPreference("total_grades", 100.0);
    expect(Calculator.calculate(oneItemList), equals(80));
  });

  test('Number formatting', () {
    expect(Calculator.format(null), equals("-"));
    expect(Calculator.format(47), equals("47"));
    expect(Calculator.format(3.14159), equals("3.14159"));
    expect(Calculator.format(3.14159, roundToOverride: 100), equals("3.14159"));
    expect(Calculator.format(0.5, roundToOverride: 100), equals("0.50"));
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
    expect(Calculator.round(47.199, roundingModeOverride: RoundingMode.down, roundToOverride: 10), equals(47.1));
    expect(Calculator.round(47.5, roundingModeOverride: RoundingMode.halfUp), equals(48));
    expect(Calculator.round(47.15, roundingModeOverride: RoundingMode.halfDown, roundToOverride: 10), equals(47.1));
  });

  test('Number parsing', () {
    expect(Calculator.tryParse(null), equals(null));
    expect(Calculator.tryParse(""), equals(null));
    expect(Calculator.tryParse("abc"), equals(null));

    expect(Calculator.tryParse("1"), equals(1.0));
    expect(Calculator.tryParse("1.23"), equals(1.23));
    expect(Calculator.tryParse("1,23"), equals(1.23));
    expect(Calculator.tryParse("-1.23"), equals(-1.23));
    expect(Calculator.tryParse("1 234.56"), equals(1234.56));
    expect(Calculator.tryParse("1,234.56"), equals(null));
    expect(Calculator.tryParse("1.234,56"), equals(null));
    expect(Calculator.tryParse(".89"), equals(0.89));
  });

  test('Object sorting', () {
    // Test sorting by name in ascending order
    List<CalculationObject> data = [
      Test(30, 100, name: 'Beta'),
      Test(30, 100, name: 'Alpha'),
      Test(30, 100, name: 'Delta'),
      Test(30, 100, name: 'Gamma'),
    ];

    Calculator.sortObjects(data, sortType: 1, sortModeOverride: SortMode.name);

    expect(data[0].name, 'Alpha');
    expect(data[1].name, 'Beta');
    expect(data[2].name, 'Delta');
    expect(data[3].name, 'Gamma');

    // Test sorting by result in descending order
    data = [
      Test(50, 100, name: 'Beta'),
      Test(40, 100, name: 'Alpha'),
      Test(86, 100, name: 'Delta'),
      Test(99, 100, name: 'Gamma'),
    ];

    Calculator.sortObjects(data, sortType: 1, sortModeOverride: SortMode.result);

    expect(data[0].name, 'Gamma');
    expect(data[1].name, 'Delta');
    expect(data[2].name, 'Beta');
    expect(data[3].name, 'Alpha');

    // Test sorting by coefficient in descending order
    data = [
      Term(name: 'Alpha', coefficient: 0.5),
      Term(name: 'Beta', coefficient: 0.3),
      Term(name: 'Delta', coefficient: 0.8),
      Term(name: 'Gamma', coefficient: 0.1),
    ];

    Calculator.sortObjects(data, sortType: 1, sortModeOverride: SortMode.coefficient);

    expect(data[0].name, 'Delta');
    expect(data[1].name, 'Alpha');
    expect(data[2].name, 'Beta');
    expect(data[3].name, 'Gamma');

    // Test sorting using custom order
    data = [
      Term(name: 'Gamma'),
      Term(name: 'Beta'),
      Term(name: 'Alpha'),
      Term(name: 'Delta'),
    ];

    List<CalculationObject> comparisonData = [
      Term(name: 'Alpha'),
      Term(name: 'Beta'),
      Term(name: 'Gamma'),
      Term(name: 'Delta'),
    ];

    Calculator.sortObjects(data, sortType: 1, sortModeOverride: SortMode.custom, comparisonData: comparisonData);

    expect(data[0].name, 'Alpha');
    expect(data[1].name, 'Beta');
    expect(data[2].name, 'Gamma');
    expect(data[3].name, 'Delta');
  });
}
