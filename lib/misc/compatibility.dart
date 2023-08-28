// Dart imports:
import "dart:convert";

// Project imports:
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/calculations/term.dart";
import "package:graded/calculations/year.dart";
import "package:graded/localization/translations.dart";
import "package:graded/misc/default_values.dart";
import "package:graded/misc/enums.dart";
import "package:graded/misc/setup_manager.dart";
import "package:graded/misc/storage.dart";

class Compatibility {
  static const dataVersion = 12;

  static void upgradeDataVersion({bool imported = false}) {
    final int currentDataVersion = getPreference<int>("data_version");

    if (!getPreference<bool>("is_first_run") || imported) {
      if (currentDataVersion < 2) {
        setPreference<String?>("data", getPreference<String>("data").replaceAll("period", "term").replaceAll("mark", "grade"));
        setPreference<String?>("default_data", getPreference<String>("default_data", "[]").replaceAll("period", "term").replaceAll("mark", "grade"));
      }

      deserialize();

      if (currentDataVersion < 5) {
        termCount();

        setPreference<String>("language", defaultValues["language"] as String);
      }

      if (currentDataVersion < 6) {
        final String variant = getPreference<String>("variant");
        String newVariant = "";
        if (variant == "latin") {
          newVariant = "L";
        } else if (variant == "chinese") {
          newVariant = "ZH";
        }
        setPreference<String>("variant", newVariant);

        final String year = getPreference<String>("year", "");
        setPreference<int>("year", year.isNotEmpty ? int.parse(year.substring(0, 1)) : -1);

        setPreference<String>("validated_school_system", getPreference<String>("school_system"));
        setPreference<String>("validated_lux_system", getPreference<String>("lux_system"));
        setPreference<int>("validated_year", getPreference<int>("year"));
        setPreference<String>("validated_section", getPreference<String>("section"));
        setPreference<String>("validated_variant", getPreference<String>("variant"));
      }

      if (currentDataVersion < 7) {
        termCount();
      }

      if (currentDataVersion < 8) {
        if (getPreference<String>("validated_school_system") == "lux") {
          try {
            if (!SetupManager.hasSections(getPreference<String>("validated_lux_system"), getPreference<int>("validated_year"))) {
              setPreference<String>("validated_section", defaultValues["validated_section"] as String);
            }
          } catch (e) {
            setPreference<String>("validated_section", defaultValues["validated_section"] as String);
          }
          try {
            if (!SetupManager.hasVariants(
                  getPreference<String>("validated_lux_system"),
                  getPreference<int>("validated_year"),
                  getPreference<String>("validated_section"),
                ) ||
                SetupManager.getVariants()[getPreference<String>("validated_variant")] == null) {
              setPreference<String>("validated_variant", defaultValues["validated_variant"] as String);
            }
          } catch (e) {
            setPreference<String>("validated_variant", defaultValues["validated_variant"] as String);
          }
        } else {
          final List<String> keys = ["validated_lux_system", "validated_year", "validated_section", "validated_variant"];

          for (final String key in keys) {
            setPreference(key, defaultValues[key]);
          }
        }
      }

      if (currentDataVersion < 9) {
        //Sort direction
        for (var sortType = 1; sortType <= 2; sortType++) {
          final int sortMode = getPreference<int>("sort_mode$sortType");
          int sortDirection = SortDirection.notApplicable;

          switch (sortMode) {
            case SortMode.name:
              sortDirection = SortDirection.ascending;
            case SortMode.result:
            case SortMode.coefficient:
              sortDirection = SortDirection.descending;
            case SortMode.custom:
              sortDirection = SortDirection.notApplicable;
          }
          setPreference<int>("sort_direction$sortType", sortDirection);
        }
      }

      if (currentDataVersion < 10) {
        //Fix exam coefficient
        if (getPreference<String>("validated_school_system") == "lux" && getPreference<int>("validated_year") == 1) {
          final Iterable<Term> examTerms = getCurrentYear().terms.where((element) => element.coefficient == 2);

          for (final examTerm in examTerms) {
            examTerm.isExam = true;
          }
        }
      }

      if (currentDataVersion < 11) {
        //Change currentTerm behavior
        final int currentTerm = getPreference<int>("current_term");
        if (currentTerm == -1) {
          setPreference("current_term", 0);
        }
      }

      if (currentDataVersion < 12) {
        //Move termTemplate into year
        final termTemplateList = jsonDecode(getPreference<String>("default_data", "[]")) as List<dynamic>;
        getCurrentYear().termTemplate = termTemplateList.map((templateJson) => Subject.fromJson(templateJson as Map<String, dynamic>)).toList();

        setPreference("default_data", null);

        //Add year name
        getCurrentYear().name = "${translations.yearOne} 1";
      }
    }

    setPreference<int>("data_version", dataVersion);
  }

  static void termCount() {
    final int termCount = getPreference<int>("term");
    final bool hasExam = getPreference<int>("validated_year") == 1;
    Manager.currentTerm = 0;

    for (final Year year in Manager.years) {
      final List<Term> terms = year.terms;
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
    }

    serialize();
  }
}
