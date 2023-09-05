// Project imports:
import "package:graded/calculations/calculation_object.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/localization/translations.dart";

String getHint(String prefix, List<CalculationObject> data) {
  String hint = "";
  int i = data.length;

  do {
    i++;
    hint = "$prefix $i";
  } while (data.any((element) => element.name == hint));

  return hint;
}

String getTermName({required int termIndex}) {
  final int termCount = getCurrentYear().termCount;

  if (termIndex == -1) return translations.year_overview;

  if (termIndex == termCount) return translations.exams;

  switch (termCount) {
    case 4:
      return "${translations.quarterOne} ${termIndex + 1}";
    case 3:
      return "${translations.trimesterOne} ${termIndex + 1}";
    case 2:
      return "${translations.semesterOne} ${termIndex + 1}";
    case 1:
      return translations.yearOne;
    default:
      return "${translations.school_termOne} ${termIndex + 1}";
  }
}
