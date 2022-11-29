// Package imports:
import 'package:collection/collection.dart';
import 'package:diacritic/diacritic.dart';
import 'package:sprintf/sprintf.dart';
import 'package:tuple/tuple.dart';

// Project imports:
import 'package:gradely/Calculations/sort_interface.dart';
import '../Misc/storage.dart';

class Calculator {
  static void sortObjects(List<SortInterface> data, int sortMode, {int? sortModeOverride}) {
    if (data.length >= 2) {
      switch (sortModeOverride ?? Storage.getPreference<int>("sort_mode$sortMode")) {
        case 0:
          insertionSort(data,
              compare: (SortInterface a, SortInterface b) => removeDiacritics(a.name.toLowerCase())
                  .replaceAll("[^\\p{ASCII}]", "")
                  .compareTo(removeDiacritics(b.name.toLowerCase()).replaceAll("[^\\p{ASCII}]", "")));
          break;
        case 1:
          insertionSort(data, compare: (SortInterface a, SortInterface b) => b.result.compareTo(a.result));
          break;
        case 2:
          insertionSort(data, compare: (SortInterface a, SortInterface b) => b.coefficient.compareTo(a.coefficient));
          break;
      }
    }
  }

  static double calculate(List<Tuple2<double, double>> data) {
    if (data.isEmpty) {
      return -1;
    }

    double a = 0;
    double b = 0;

    for (int i = 0; i < data.length; i++) {
      if (data[i].item1 != -1) {
        a += data[i].item1 * data[i].item2;
        b += data[i].item2;
      }
    }

    if (b > 0) {
      return round(a / b);
    } else {
      return -1;
    }
  }

  static double round(double number) {
    String roundingMode = Storage.getPreference<String>("rounding_mode");
    int roundTo = Storage.getPreference<int>("round_to");

    switch (roundingMode) {
      case "rounding_up":
        double a = number * roundTo;
        return a.ceilToDouble() / roundTo;
      case "rounding_down":
        double a = number * roundTo;
        return a.floorToDouble() / roundTo;
      case "rounding_half_up":
        double i = (number * roundTo).floorToDouble();
        double f = number - i;
        return (f < 0.5 ? i : i + 1) / roundTo;
      case "rounding_half_down":
        double i1 = (number * roundTo).floorToDouble();
        double f1 = number - i1;
        return (f1 <= 0.5 ? i1 : i1 + 1) / roundTo;
      default:
        return number;
    }
  }

  static double? tryParse(String? input) {
    if (input == null) return null;
    return double.tryParse(input.replaceAll(",", ".").replaceAll(" ", ""));
  }

  static String format(double d, {bool ignoreZero = false}) {
    String result;

    if (d == d.toInt()) {
      result = sprintf("%d", [d.toInt()]);
    } else {
      result = sprintf("%s", [d]);
    }

    if (!ignoreZero && d < 10 && d > 0 && d % 1 == 0) {
      return 0.toString() + result;
    } else {
      return result;
    }
  }
}
