// Project imports:
import "package:graded/calculations/calculation_object.dart";
import "package:graded/calculations/calculator.dart";
import "package:graded/ui/utilities/grade_display_value.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/misc/default_values.dart";
import "package:graded/misc/enums.dart";
import "package:graded/misc/storage.dart";

class Year extends CalculationObject {
  List<Subject> subjects = [];
  late Year yearOverview = createYearOverview(year: this);
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
  bool scaleUpTests = DefaultValues.scaleUpTests;

  bool isYearOverview = false;
  bool hasBeenSortedCustom = false;

  List<GradeMapping> gradeMappings = [];

  Year({
    this.isYearOverview = false,
  });

  @override
  void calculate() {
    for (final Subject s in subjects) {
      s.calculate();
    }

    final List<Subject> toBeCalculated = subjects;
    for (int i = 0; i < toBeCalculated.length; i++) {
      if (toBeCalculated[i].weight == 0) {
        toBeCalculated.addAll(toBeCalculated[i].children);
        toBeCalculated.removeAt(i);
        i--;
      }
    }

    result = Calculator.calculate(toBeCalculated);
    preciseResult = Calculator.calculate(toBeCalculated, precise: true);
  }

  void addSubject(Subject subject) {
    subjects.add(Subject.fromSubject(subject));
  }

  void clearSubjects() {
    subjects.clear();
  }

  void editSubject(Subject subject, String name, double weight, double speakingWeight) {
    subject.name = name;
    subject.weight = weight;
    subject.speakingWeight = speakingWeight;
  }

  void reorderSubjects(int oldIndex, int newIndex) {
    if (oldIndex == newIndex - 1) return;

    subjects = Calculator.sortObjects(subjects, sortType: SortType.subject);
    for (final subject in subjects) {
      subject.children = Calculator.sortObjects(subject.children, sortType: SortType.subject);
    }

    final oldIndexes = getIndexesFromFlattened(oldIndex);
    final newIndexes = getIndexesFromFlattened(newIndex, addedIndex: 1);
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

    Subject item;

    if (oldIndex2 == null) {
      item = subjects.removeAt(oldIndex1);
    } else {
      item = subjects[oldIndex1].children.removeAt(oldIndex2);
      if (subjects[oldIndex1].children.isEmpty) subjects[oldIndex1].isGroup = false;
    }

    item.isChild = newIndex2 != null;

    if (newIndex2 == null) {
      subjects.insert(newIndex1, item);
    } else {
      subjects[newIndex1].children.insertAll(newIndex2, [item, ...item.children]);
      item.children.clear();
      item.isGroup = false;
      subjects[newIndex1].isGroup = true;
    }

    setPreference<int>("sortMode${SortType.subject}", SortMode.custom);
    setPreference<int>("sortDirection${SortType.subject}", SortDirection.ascending);

    serialize();
    calculate();
  }

  (int, int?) getIndexesFromFlattened(int absoluteIndex, {int addedIndex = 0, List<Subject>? subjectData, List<List<Subject>>? childrenData}) {
    int subjectCount = 0;
    int index1 = 0;
    int? index2;
    subjectData ??= subjects;
    childrenData ??= subjectData.map((element) => element.children).toList();

    for (int i = 0; i < subjectData.length; i++) {
      final int childCount = childrenData[i].length;
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
    for (final Subject s in subjects) {
      s.ensureTermCount(year: this);
    }
  }

  double? getTermResult(int termIndex, {bool precise = false}) {
    final List<CalculationObject> toCalculate = subjects.map((s) => Subject.copyWithTerms(s, termIndex)).toList();
    for (final CalculationObject c in toCalculate) {
      c.calculate();
    }

    return Calculator.calculate(toCalculate, precise: precise);
  }

  String getTermResultString(int termIndex, {bool precise = false}) {
    return Calculator.format(getTermResult(termIndex, precise: precise), roundToMultiplier: precise ? DefaultValues.preciseRoundToMultiplier : 1);
  }

  Year.fromJson(Map<String, dynamic> json) {
    final subjectList = json["subjects"] as List;
    subjects = subjectList.map((subjectJson) => Subject.fromJson(subjectJson as Map<String, dynamic>)).toList();

    name = (json["name"] as String?) ?? "";

    validatedSchoolSystem = json["validatedSchoolSystem"] as String?;
    validatedLuxSystem = json["validatedLuxSystem"] as String?;
    validatedYear = json["validatedYear"] as int?;
    validatedSection = json["validatedSection"] as String?;
    validatedVariant = json["validatedVariant"] as String?;

    termCount = json["termCount"] as int? ?? DefaultValues.termCount;
    maxGrade = json["maxGrade"] as double? ?? DefaultValues.maxGrade;
    roundingMode = json["roundingMode"] as String? ?? DefaultValues.roundingMode;
    roundTo = json["roundTo"] as int? ?? DefaultValues.roundTo;
    scaleUpTests = (json["scaleUpTests"] as bool?) ?? DefaultValues.scaleUpTests;

    hasBeenSortedCustom = (json["hasBeenSortedCustom"] as bool?) ?? DefaultValues.hasBeenSortedCustom;

    gradeMappings = ((json["gradeMappings"] ?? []) as List).map((e) => GradeMapping.fromJson(e as Map<String, dynamic>)).toList();
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "termCount": termCount,
        "maxGrade": maxGrade,
        "roundingMode": roundingMode,
        "roundTo": roundTo,
        "scaleUpTests": scaleUpTests,
        "validatedSchoolSystem": validatedSchoolSystem,
        "validatedLuxSystem": validatedLuxSystem,
        "validatedYear": validatedYear,
        "validatedSection": validatedSection,
        "validatedVariant": validatedVariant,
        "hasBeenSortedCustom": hasBeenSortedCustom,
        "gradeMappings": gradeMappings.map((e) => e.toJson()).toList(),
        "subjects": subjects,
      };
}
