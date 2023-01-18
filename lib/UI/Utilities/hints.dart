// Project imports:
import '../../Calculations/calculation_object.dart';
import '../../Calculations/manager.dart';
import '../../Misc/storage.dart';
import '../../Translations/translations.dart';

String getHint(String prefix, List<CalculationObject> data) {
  String hint = "";
  int i = 1;
  bool foundDupe = false;

  do {
    hint = "$prefix ${data.length + i}";

    for (CalculationObject t in data) {
      if (t.name == hint) {
        foundDupe = true;
        i++;
        break;
      } else {
        foundDupe = false;
      }
    }
  } while (foundDupe);

  return hint;
}

String getTitle({int? termOverride}) {
  int currentTerm = termOverride ?? Manager.currentTerm;
  if (currentTerm == -1) return Translations.year_overview;

  switch (Storage.getPreference<int>("term")) {
    case 3:
      return "${Translations.trimester} ${currentTerm + 1}";
    case 2:
      return "${Translations.semester} ${currentTerm + 1}";
    case 1:
      return Translations.year;
  }

  return Translations.app_name;
}
