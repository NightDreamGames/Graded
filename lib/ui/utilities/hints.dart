// Project imports:
import "package:graded/calculations/calculation_object.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/l10n/translations.dart";

String getHint(String prefix, Iterable<CalculationObject> data) {
  String hint = "";
  int i = data.length;

  do {
    i++;
    hint = "$prefix $i";
  } while (isDuplicateName(hint, data));

  return hint;
}

bool isDuplicateName(String name, Iterable<CalculationObject> data) {
  return data.any((e) => e.name == name || (e is Subject && e.children.any((child) => child.name == name)));
}

String getTermName({required int termIndex}) {
  final int termCount = getCurrentYear().termCount;

  if (termIndex == -1) return translations.year_overview;

  if (termIndex == termCount) return translations.exams;

  return switch (termCount) {
    4 => translations.quartile_num.replaceFirst("%s", (termIndex + 1).toString()),
    3 => translations.trimester_num.replaceFirst("%s", (termIndex + 1).toString()),
    2 => translations.semester_num.replaceFirst("%s", (termIndex + 1).toString()),
    1 => translations.yearOne,
    _ => translations.school_term_num.replaceFirst("%s", (termIndex + 1).toString()),
  };
}

String getTermNameShort({required int termIndex}) {
  final int termCount = getCurrentYear().termCount;

  if (termIndex == -1) return translations.year_overview;

  return switch (termCount) {
    4 => translations.quartile_short_num.replaceFirst("%s", (termIndex + 1).toString()),
    3 => translations.trimester_short_num.replaceFirst("%s", (termIndex + 1).toString()),
    2 => translations.semester_short_num.replaceFirst("%s", (termIndex + 1).toString()),
    1 => translations.yearOne,
    _ => translations.school_term_short_num.replaceFirst("%s", (termIndex + 1).toString()),
  };
}
