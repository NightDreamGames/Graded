// Project imports:
import '../../calculations/calculation_object.dart';
import '../../calculations/manager.dart';
import '../../localization/translations.dart';
import '../../misc/storage.dart';

String getHint(String prefix, List<CalculationObject> data) {
  String hint = "";
  int i = 0;

  do {
    i++;
    hint = "$prefix ${data.length + i}";
  } while (data.any((element) => element.name == hint));

  return hint;
}

String getTitle({int? termOverride}) {
  int maxTerms = getPreference<int>("term");
  int currentTerm = termOverride ?? Manager.currentTerm;
  if (currentTerm == -1) return translations.year_overview;

  if (currentTerm == maxTerms) return termOverride == null ? translations.exams : translations.exam;
  switch (maxTerms) {
    case 3:
      return "${translations.trimester} ${currentTerm + 1}";
    case 2:
      return "${translations.semester} ${currentTerm + 1}";
    case 1:
      return translations.year;
    default:
      return translations.app_name;
  }
}
