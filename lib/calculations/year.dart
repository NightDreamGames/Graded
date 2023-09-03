// Project imports:
import "package:graded/calculations/calculation_object.dart";
import "package:graded/calculations/calculator.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/calculations/term.dart";
import "package:graded/misc/default_values.dart";
import "package:graded/misc/enums.dart";
import "package:graded/misc/storage.dart";

class Year extends CalculationObject {
  List<Term> terms = [];
  List<Subject> termTemplate = [];
  late Term yearOverview = createYearOverview(year: this);

  String? validatedSchoolSystem;
  String? validatedLuxSystem;
  int? validatedYear;
  String? validatedSection;
  String? validatedVariant;

  Year({
    List<Subject>? termTemplate,
  }) : termTemplate = termTemplate ?? [];

  void calculate() {
    for (final Term t in terms) {
      t.calculate();
    }

    final double examCoefficient = defaultValues["exam_coefficient"] as double;
    final int notEmptyTerms = terms.where((element) => element.result != null && !element.isExam).length;

    for (final Term t in terms) {
      if (t.isExam) {
        t.coefficient = examCoefficient * notEmptyTerms;
      }
    }

    result = Calculator.calculate(terms);
    preciseResult = Calculator.calculate(terms, precise: true);
  }

  void sort({int? sortModeOverride, int? sortDirectionOverride}) {
    for (final Term term in terms) {
      term.sort(sortModeOverride: sortModeOverride, sortDirectionOverride: sortDirectionOverride);
    }
    sortTermTemplate();
  }

  void sortTermTemplate({int? sortModeOverride, int? sortDirectionOverride}) {
    Calculator.sortObjects(
      termTemplate,
      sortType: SortType.subject,
      sortModeOverride: sortModeOverride,
      sortDirectionOverride: sortDirectionOverride,
    );

    for (final Subject element in termTemplate) {
      element.sort(sortModeOverride: sortModeOverride, sortDirectionOverride: sortDirectionOverride);
    }
  }

  void addSubject(Subject subject) {
    final List<List<Subject>> lists = [termTemplate];
    lists.addAll(terms.map((term) => term.subjects));

    for (final List<Subject> t in lists) {
      t.add(subject);
    }
  }

  void editSubject(Subject subject, String name, double coefficient, double speakingWeight) {
    sort(
      sortModeOverride: SortMode.name,
      sortDirectionOverride: SortDirection.ascending,
    );

    subject.name = name;
    subject.coefficient = coefficient;
    subject.speakingWeight = speakingWeight;

    for (final Term t in terms) {
      for (int i = 0; i < t.subjects.length; i++) {
        final Subject s = t.subjects[i];
        final Subject template = termTemplate[i];

        s.name = template.name;
        s.coefficient = template.coefficient;
        s.speakingWeight = template.speakingWeight;
        for (int j = 0; j < t.subjects[i].children.length; j++) {
          s.children[j].name = template.children[j].name;
          s.children[j].coefficient = template.children[j].coefficient;
          s.children[j].speakingWeight = template.children[j].speakingWeight;
        }
      }
    }
  }

  void reorderSubjects(int oldIndex, int newIndex) {
    if (oldIndex == newIndex - 1) return;

    setPreference<int>("sort_mode${SortType.subject}", SortMode.custom);
    setPreference<int>("sort_direction${SortType.subject}", SortDirection.notApplicable);

    Manager.sortAll();

    final oldIndexes = getSubjectIndexes(oldIndex);
    final newIndexes = getSubjectIndexes(newIndex, addedIndex: 1);
    final int oldIndex1 = oldIndexes[0];
    final int oldIndex2 = oldIndexes[1];
    int newIndex1 = newIndexes[0];
    int newIndex2 = newIndexes[1];

    if (oldIndex1 == newIndex1 && oldIndex2 < newIndex2) {
      newIndex2--;
    }
    if (oldIndex1 < newIndex1 && oldIndex2 == -1) {
      newIndex1--;
    } else if (newIndex1 == oldIndex1 && oldIndex2 == -1 && newIndex2 != -1) {
      return;
    }

    final List<List<Subject>> lists = [termTemplate];
    lists.addAll(terms.map((term) => term.subjects));

    for (final List<Subject> list in lists) {
      Subject item;
      if (oldIndex2 == -1) {
        item = list.removeAt(oldIndex1);
      } else {
        item = list[oldIndex1].children.removeAt(oldIndex2);
        if (list[oldIndex1].children.isEmpty) list[oldIndex1].isGroup = false;
      }

      item.isChild = newIndex2 != -1;

      if (newIndex2 == -1) {
        list.insert(newIndex1, item);
      } else {
        list[newIndex1].children.insertAll(newIndex2, [item, ...item.children]);
        item.children.clear();
        item.isGroup = false;
        list[newIndex1].isGroup = true;
      }
    }

    serialize();
    calculate();
  }

  List<int> getSubjectIndexes(int absoluteIndex, {int addedIndex = 0}) {
    int subjectCount = 0;
    int index1 = 0;
    int index2 = -1;

    for (int i = 0; i < termTemplate.length; i++) {
      final int childAmount = termTemplate[i].children.length;
      if (subjectCount + childAmount + (childAmount > 0 ? addedIndex : 0) >= absoluteIndex) {
        break;
      }
      subjectCount += childAmount;
      index1 = i + 1;
      subjectCount++;
    }
    index2 = absoluteIndex - subjectCount - 1;

    return [index1, index2];
  }

  void ensureTermCount() {
    final int termCount = getPreference<int>("term");
    Manager.currentTerm = 0;

    final bool hasExam = validatedYear == 1;

    final bool examPresent = terms.isNotEmpty && terms.last.coefficient == 2;

    while (terms.length > termCount + (hasExam ? 1 : 0)) {
      final int index = terms.length - 1 - (hasExam ? 1 : 0);
      terms.removeAt(index);
    }

    while (terms.length < termCount + (examPresent ? 1 : 0)) {
      int index = terms.length - (examPresent ? 1 : 0);
      if (hasExam && !examPresent && terms.length > index) {
        index++;
      }
      terms.insert(index, Term());
    }

    if (hasExam && !examPresent && terms.length < termCount + 1) {
      terms.add(Term(isExam: true));
    }

    serialize();
  }

  Year.fromJson(Map<String, dynamic> json) {
    final termList = json["terms"] as List;
    final List<Term> t = termList.map((termJson) => Term.fromJson(termJson as Map<String, dynamic>)).toList();

    final termTemplateList = (json["term_template"] ?? []) as List<dynamic>;
    termTemplate = termTemplateList.map((templateJson) => Subject.fromJson(templateJson as Map<String, dynamic>)).toList();

    terms = t;
    name = (json["name"] as String?) ?? "";
    validatedSchoolSystem = json["validated_school_system"] as String?;
    validatedLuxSystem = json["validated_lux_system"] as String?;
    validatedYear = json["validated_year"] as int?;
    validatedSection = json["validated_section"] as String?;
    validatedVariant = json["validated_variant"] as String?;
  }

  Map<String, dynamic> toJson() => {
        "terms": terms,
        "term_template": termTemplate,
        "name": name,
        "validated_school_system": validatedSchoolSystem,
        "validated_lux_system": validatedLuxSystem,
        "validated_year": validatedYear,
        "validated_section": validatedSection,
        "validated_variant": validatedVariant,
      };
}
