// Project imports:
import "package:graded/calculations/calculation_object.dart";
import "package:graded/calculations/calculator.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/calculations/term.dart";
import "package:graded/misc/default_values.dart";
import "package:graded/misc/enums.dart";
import "package:graded/misc/storage.dart";
import "package:graded/ui/utilities/ordered_collection.dart";

class Year extends CalculationObject {
  List<Term> terms = [];
  OrderedCollection<Subject> termTemplate = OrderedCollection.newTreeSet();
  late OrderedCollection<Subject> comparisonData = OrderedCollection.newList(termTemplate);
  late Term yearOverview = createYearOverview(year: this);
  @override
  double get denominator => maxGrade;

  String? validatedSchoolSystem;
  String? validatedLuxSystem;
  int? validatedYear;
  String? validatedSection;
  String? validatedVariant;

  int termCount = DefaultValues.termCount;
  double maxGrade = DefaultValues.maxGrade;
  String roundingMode = DefaultValues.roundingMode;
  int roundTo = DefaultValues.roundTo;

  Year({
    Iterable<Subject>? termTemplate,
  }) : termTemplate = OrderedCollection.newTreeSet(termTemplate);

  void calculate() {
    for (final Term t in terms) {
      t.calculate();
    }

    const double examWeight = DefaultValues.examWeight;
    final int nonEmptyTerms = terms.where((element) => element.result != null && !element.isExam).length;

    for (final Term t in terms) {
      if (t.isExam) {
        t.weight = examWeight * nonEmptyTerms;
      }
    }

    result = Calculator.calculate(terms);
    preciseResult = Calculator.calculate(terms, precise: true);
  }

  void addSubject(Subject subject) {
    for (final t in getSubjectLists()) {
      t.add(Subject.fromSubject(subject));
    }
  }

  void clearSubjects() {
    for (final t in getSubjectLists()) {
      t.clear();
    }
  }

  void editSubject(Subject subject, String name, double weight, double speakingWeight) {
    subject.name = name;
    subject.weight = weight;
    subject.speakingWeight = speakingWeight;

    for (final Term t in terms) {
      for (int i = 0; i < t.subjects.length; i++) {
        final Subject s = t.subjects[i];
        final Subject template = termTemplate[i];

        s.name = template.name;
        s.weight = template.weight;
        s.speakingWeight = template.speakingWeight;
        for (int j = 0; j < t.subjects[i].children.length; j++) {
          s.children[j].name = template.children[j].name;
          s.children[j].weight = template.children[j].weight;
          s.children[j].speakingWeight = template.children[j].speakingWeight;
        }
      }
    }
  }

  void reorderSubjects(int oldIndex, int newIndex) {
    if (oldIndex == newIndex - 1) return;

    setPreference<int>("sort_mode${SortType.subject}", SortMode.custom);
    setPreference<int>("sort_direction${SortType.subject}", SortDirection.notApplicable);

    final oldIndexes = getSubjectIndexes(oldIndex);
    final newIndexes = getSubjectIndexes(newIndex, addedIndex: 1);
    final int oldIndex1 = oldIndexes.$1;
    final int? oldIndex2 = oldIndexes.$2;
    int newIndex1 = newIndexes.$1;
    int? newIndex2 = newIndexes.$2;

    if (oldIndex1 == newIndex1 && (oldIndex2 ?? -1) < (newIndex2 ?? -1)) {
      if (newIndex2 == 0 || newIndex2 == null) {
        newIndex2 = null;
      } else {
        newIndex2--;
      }
    }
    if (oldIndex1 < newIndex1 && oldIndex2 == null) {
      newIndex1--;
    } else if (newIndex1 == oldIndex1 && oldIndex2 == null && newIndex2 != null) {
      return;
    }

    final list = getCurrentYear().comparisonData;
    Subject item;

    if (oldIndex2 == null) {
      item = list.removeAt(oldIndex1);
    } else {
      item = list[oldIndex1].children.removeAt(oldIndex2);
      if (list[oldIndex1].children.isEmpty) list[oldIndex1].isGroup = false;
    }

    item.isChild = newIndex2 != null;

    if (newIndex2 == null) {
      list.insert(newIndex1, item);
    } else {
      list[newIndex1].children.insertAll(newIndex2, [item, ...item.children]);
      item.children.clear();
      item.isGroup = false;
      list[newIndex1].isGroup = true;
    }

    serialize();
    calculate();
  }

  (int, int?) getSubjectIndexes(int absoluteIndex, {int addedIndex = 0}) {
    int subjectCount = 0;
    int index1 = 0;
    int? index2;

    for (int i = 0; i < comparisonData.length; i++) {
      final int childCount = comparisonData[i].children.length;
      if (subjectCount + childCount + (childCount > 0 ? addedIndex : 0) >= absoluteIndex) break;

      subjectCount += childCount;
      index1 = i + 1;
      subjectCount++;
    }
    index2 = absoluteIndex - subjectCount - 1;

    if (index2 < 0) index2 = null;

    return (index1, index2);
  }

  void ensureTermCount() {
    Manager.currentTerm = 0;

    final bool hasExam = validatedYear == 1;

    final bool examPresent = terms.isNotEmpty && terms.last.weight == 2;

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

    Manager.calculate();
    serialize();
  }

  void populateSubjects() {
    for (final Term term in terms) {
      term.populateSubjects();
    }
  }

  List<OrderedCollection<Subject>> getSubjectLists({bool includeComparison = true}) {
    final List<OrderedCollection<Subject>> lists = [
      termTemplate,
      if (includeComparison) comparisonData,
    ];
    for (final term in terms) {
      lists.add(term.subjects);
    }

    return lists;
  }

  Year.fromJson(Map<String, dynamic> json) {
    final termList = json["terms"] as List;
    final List<Term> t = termList.map((termJson) => Term.fromJson(termJson as Map<String, dynamic>)).toList();

    final termTemplateList = (json["term_template"] ?? []) as List<dynamic>;
    termTemplate = OrderedCollection.newTreeSet(termTemplateList.map((templateJson) => Subject.fromJson(templateJson as Map<String, dynamic>)));

    terms = t;
    name = (json["name"] as String?) ?? "";

    validatedSchoolSystem = json["validated_school_system"] as String?;
    validatedLuxSystem = json["validated_lux_system"] as String?;
    validatedYear = json["validated_year"] as int?;
    validatedSection = json["validated_section"] as String?;
    validatedVariant = json["validated_variant"] as String?;

    termCount = json["term_count"] as int? ?? DefaultValues.termCount;
    maxGrade = json["max_grade"] as double? ?? DefaultValues.maxGrade;
    roundingMode = json["rounding_mode"] as String? ?? DefaultValues.roundingMode;
    roundTo = json["round_to"] as int? ?? DefaultValues.roundTo;
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "term_count": termCount,
        "max_grade": maxGrade,
        "rounding_mode": roundingMode,
        "round_to": roundTo,
        "validated_school_system": validatedSchoolSystem,
        "validated_lux_system": validatedLuxSystem,
        "validated_year": validatedYear,
        "validated_section": validatedSection,
        "validated_variant": validatedVariant,
        "terms": terms,
        "term_template": termTemplate.toList(),
      };
}
