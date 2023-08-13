// Project imports:
import "package:graded/calculations/calculation_object.dart";
import "package:graded/localization/translations.dart";
import "package:graded/misc/storage.dart";

String getHint(String prefix, List<CalculationObject> data) {
  String hint = "";
  int i = data.length;

  do {
    i++;
    hint = "$prefix $i";
  } while (data.any((element) => element.name == hint));

  return hint;
}

String getTitle({required int termIndex}) {
  int maxTerms = getPreference<int>("term");

  if (termIndex == -1) return translations.year_overview;

  if (termIndex == maxTerms) return translations.exams;

  switch (maxTerms) {
    case 4:
      return "${translations.quarterOne} ${termIndex + 1}";
    case 3:
      return "${translations.trimesterOne} ${termIndex + 1}";
    case 2:
      return "${translations.semesterOne} ${termIndex + 1}";
    case 1:
      return translations.year;
    default:
      return translations.app_name;
  }
}
