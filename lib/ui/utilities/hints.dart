// Project imports:
import "package:graded/calculations/calculation_object.dart";
import "package:graded/localization/translations.dart";
import "package:graded/misc/storage.dart";

String getHint(String prefix, List<CalculationObject> data) {
  String hint = "";
  int i = 0;

  do {
    i++;
    hint = "$prefix ${data.length + i}";
  } while (data.any((element) => element.name == hint));

  return hint;
}

String getTitle({required int termIndex}) {
  int maxTerms = getPreference<int>("term");

  if (termIndex == -1) return translations.year_overview;

  if (termIndex == maxTerms) return translations.exams;

  switch (maxTerms) {
    case 3:
      return "${translations.trimester} ${termIndex + 1}";
    case 2:
      return "${translations.semester} ${termIndex + 1}";
    case 1:
      return translations.year;
    default:
      return translations.app_name;
  }
}
