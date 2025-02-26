// ignore_for_file: avoid_dynamic_calls

// Dart imports:
import "dart:convert";

// Project imports:
import "package:graded/l10n/translations.dart";
import "package:graded/misc/enums.dart";
import "package:graded/misc/setup_manager.dart";
import "package:graded/misc/storage.dart";
import "package:graded/ui/utilities/misc_utilities.dart";

class Compatibility {
  static const dataVersion = 17;

  static void upgradeDataVersion({bool imported = false}) {
    if (!(hasPreference("is_first_run") ? getPreference<bool>("is_first_run", true) : getPreference<bool>("isFirstRun")) || imported) {
      final String dataString = getPreference<String>("data");
      List decodedData = jsonDecode(dataString) as List;
      final int currentDataVersion = hasPreference("data_version") ? getPreference<int>("data_version", -1) : getPreference<int>("dataVersion");

      if (currentDataVersion < 2) {
        decodedData = replaceKeysInJson(decodedData, "period", "term") as List;
        decodedData = replaceKeysInJson(decodedData, "mark", "grade") as List;

        List defaultData = jsonDecode(getPreference<String>("default_data", "[]")) as List;
        defaultData = replaceKeysInJson(defaultData, "period", "term") as List;
        defaultData = replaceKeysInJson(defaultData, "mark", "grade") as List;
        setPreference("default_data", jsonEncode(defaultData));
      }

      if (currentDataVersion < 5) {
        setPreference<String>("language", "system");
      }

      if (currentDataVersion < 6) {
        final String variant = getPreference<String>("variant", "");
        String newVariant = "";
        if (variant == "latin") {
          newVariant = "L";
        } else if (variant == "chinese") {
          newVariant = "ZH";
        }
        setPreference<String>("variant", newVariant);

        final String year = getPreference<String>("year", "");
        setPreference<int>("year", year.isNotEmpty ? int.parse(year.substring(0, 1)) : -1);

        setPreference<String>("validated_school_system", getPreference<String>("school_system", ""));
        setPreference<String>("validated_lux_system", getPreference<String>("lux_system", ""));
        setPreference<int>("validated_year", getPreference<int>("year", -1));
        setPreference<String>("validated_section", getPreference<String>("section", ""));
        setPreference<String>("validated_variant", getPreference<String>("variant", ""));
      }

      if (currentDataVersion < 8) {
        if (getPreference<String>("validated_school_system", "") == "lux") {
          try {
            if (!SetupManager.hasSections(getPreference<String>("validated_lux_system", ""), getPreference<int>("validated_year", -1))) {
              setPreference<String>("validated_section", "");
            }
          } catch (e) {
            setPreference<String>("validated_section", "");
          }
          try {
            if (!SetupManager.hasVariants(
                  getPreference<String>("validated_lux_system", ""),
                  getPreference<int>("validated_year", -1),
                  getPreference<String>("validated_section", ""),
                ) ||
                SetupManager.getVariants()[getPreference<String>("validated_variant", "")] == null) {
              setPreference<String>("validated_variant", "");
            }
          } catch (e) {
            setPreference<String>("validated_variant", "");
          }
        } else {
          setPreference("validated_lux_system", "");
          setPreference("validated_year", -1);
          setPreference("validated_section", "");
          setPreference("validated_variant", "");
        }
      }

      if (currentDataVersion < 9) {
        // Sort direction
        for (int sortType = 1; sortType <= 2; sortType++) {
          final int sortMode = getPreference<int>("sort_mode$sortType", SortMode.name);
          int sortDirection = SortDirection.ascending;

          switch (sortMode) {
            case SortMode.name:
            case SortMode.custom:
              sortDirection = SortDirection.ascending;
            case SortMode.result:
            case SortMode.weight:
              sortDirection = SortDirection.descending;
            default:
              throw const FormatException("Invalid");
          }
          setPreference<int>("sort_direction$sortType", sortDirection);
        }
      }

      if (currentDataVersion < 10) {
        // Fix exam coefficient
        if (getPreference<String>("validated_school_system", "") == "lux" && getPreference<int>("validated_year", -1) == 1) {
          for (final term in decodedData[0]["terms"] as List) {
            if (term["weight"] == 2) {
              term["isExam"] = true;
            }
          }
        }
      }

      if (currentDataVersion < 11) {
        // Change currentTerm behavior
        final int currentTerm = getPreference<int>("current_term", 0);
        if (currentTerm == -1) {
          setPreference("current_term", 0);
        }
      }

      if (currentDataVersion < 12) {
        // Move termTemplate into year
        final termTemplateList = jsonDecode(getPreference<String>("default_data", "[]")) as List;
        decodedData[0]["term_template"] = termTemplateList;

        setPreference("default_data", null);

        // Add year name
        decodedData[0]["name"] = "${translations.yearOne} 1";
      }

      if (currentDataVersion < 13) {
        // Move validated data into year
        decodedData[0]["validatedSchoolSystem"] = getPreference<String?>("validated_school_system", "");
        decodedData[0]["validatedLuxSystem"] = getPreference<String?>("validated_lux_system", "");
        decodedData[0]["validatedYear"] = (getPreference<int>("validated_year", -1) != -1) ? getPreference<int>("validated_year", -1) : null;
        decodedData[0]["validatedSection"] = getPreference<String?>("validated_section", "");
        decodedData[0]["validatedVariant"] = getPreference<String?>("validated_variant", "");

        if (decodedData[0]["validatedSchoolSystem"] == "") {
          decodedData[0]["validatedSchoolSystem"] = null;
        }
        if (decodedData[0]["validatedLuxSystem"] == "") {
          decodedData[0]["validatedLuxSystem"] = null;
        }
        if (decodedData[0]["validatedYear"] == -1) {
          decodedData[0]["validatedYear"] = null;
        }
        if (decodedData[0]["validatedSection"] == "") {
          decodedData[0]["validatedSection"] = null;
        }
        if (decodedData[0]["validatedVariant"] == "") {
          decodedData[0]["validatedVariant"] = null;
        }

        setPreference("validated_school_system", null);
        setPreference("validated_lux_system", null);
        setPreference("validated_year", null);
        setPreference("validated_section", null);
        setPreference("validated_variant", null);
      }

      if (currentDataVersion < 14) {
        // Rename settings
        setPreference<int>("term_count", getPreference<int>("term", 3));
        setPreference<double>("max_grade", getPreference<double>("total_grades", 60.0));

        setPreference("term", null);
        setPreference("total_grades", null);
        setPreference("total_grades_description", null);

        // Move settings into year
        decodedData[0]["term_count"] = getPreference<int>("term_count", 3);
        decodedData[0]["max_grade"] = getPreference<double>("max_grade", 60);
        decodedData[0]["rounding_mode"] = getPreference<String>("rounding_mode", RoundingMode.up);
        decodedData[0]["round_to"] = getPreference<int>("round_to", 1);
      }

      if (currentDataVersion < 15) {
        // Change order from Year->Term->Subject to Year->Subject->Term

        // Function to handle child subjects recursively
        Map<String, dynamic> handleSubject(Map<String, dynamic> subject, double termCoefficient, bool isExam) {
          // Extract subject details
          final String subjectName = subject["name"] as String;
          final double subjectCoefficient = subject["coefficient"] as double;
          final double speakingWeight = subject["speakingWeight"] as double? ?? 3;
          final bool subjectType = subject["type"] as bool? ?? false;
          double bonus;
          try {
            bonus = subject["bonus"] as double;
          } catch (e) {
            bonus = (subject["bonus"] as int).toDouble();
          }

          // Recursively handle children if they exist
          final List children = (subject["children"] as List? ?? List.empty()).map((child) {
            return handleSubject(child as Map<String, dynamic>, termCoefficient, isExam);
          }).toList();

          // Construct the subject with term and child data
          return {
            "name": subjectName,
            "coefficient": subjectCoefficient,
            "speakingWeight": speakingWeight,
            "type": subjectType,
            "children": children,
            "terms": [
              {"coefficient": termCoefficient, "isExam": isExam, "tests": subject["tests"], "bonus": bonus},
            ],
          };
        }

        final List newDecodedData = decodedData.map((yearData) {
          yearData as Map<String, dynamic>;

          // Extract year-level information
          final String yearName = yearData["name"] as String? ?? "";
          final int termCount = yearData["term_count"] as int? ?? 3;
          final double maxGrade = yearData["max_grade"] as double? ?? 60;
          final String roundingMode = yearData["rounding_mode"] as String? ?? RoundingMode.up;
          final int roundTo = yearData["round_to"] as int? ?? 1;
          final String? validatedSchoolSystem = yearData["validated_school_system"] as String?;
          final String? validatedLuxSystem = yearData["validated_lux_system"] as String?;
          final int? validatedYear = yearData["validated_year"] as int?;
          final String? validatedSection = yearData["validated_section"] as String?;
          final String? validatedVariant = yearData["validated_variant"] as String?;

          // Initialize the new structure for subjects
          final Map<String, Map<String, dynamic>> subjectMap = {};

          // Iterate over terms
          for (final term in yearData["terms"] as List) {
            final double termCoefficient = term["coefficient"] as double? ?? 1;
            final bool isExam = term["isExam"] as bool? ?? false;

            for (final subject in term["subjects"] as List) {
              final String subjectName = subject["name"] as String;

              // Ensure the subject exists in the map
              if (!subjectMap.containsKey(subjectName)) {
                subjectMap[subjectName] = handleSubject(subject as Map<String, dynamic>, termCoefficient, isExam);
              } else {
                // Append term details to the existing subject in the map
                (subjectMap[subjectName]!["terms"] as List).add({
                  "coefficient": termCoefficient,
                  "isExam": isExam,
                  "tests": subject["tests"],
                  "bonus": subject["bonus"],
                });
              }
            }
          }

          // Convert the subject map to a list
          final List subjects = subjectMap.values.toList();

          // Return the transformed year structure
          return {
            "name": yearName,
            "term_count": termCount,
            "max_grade": maxGrade,
            "rounding_mode": roundingMode,
            "round_to": roundTo,
            "validated_school_system": validatedSchoolSystem,
            "validated_lux_system": validatedLuxSystem,
            "validated_year": validatedYear,
            "validated_section": validatedSection,
            "validated_variant": validatedVariant,
            "subjects": subjects,
          };
        }).toList();

        // Keep termTemplate order
        for (int i = 0; i < newDecodedData.length; i++) {
          final compare = decodedData[i]["term_template"] as List;
          (newDecodedData[i]["subjects"] as List).sort((a, b) {
            return compare.indexWhere((element) => a["name"] == element["name"]) - compare.indexWhere((element) => b["name"] == element["name"]);
          });
        }

        // Add hasBeenSortedCustom attribute to years
        if (getPreference("sort_mode1", SortMode.name) == SortMode.custom) {
          for (final year in newDecodedData) {
            year["has_been_sorted_custom"] = true;
          }
        }

        // Remove SortDirection.notApplicable
        if (getPreference<int>("sort_direction1", SortDirection.ascending) == 0) {
          setPreference<int>("sort_direction1", SortDirection.ascending);
        }
        if (getPreference<int>("sort_direction2", SortDirection.ascending) == 0) {
          setPreference<int>("sort_direction2", SortDirection.ascending);
        }

        decodedData = newDecodedData;
      }

      if (currentDataVersion < 16) {
        // Rename storage keys
        // Year
        decodedData = replaceKeysInJson(decodedData, "term_count", "termCount") as List;
        decodedData = replaceKeysInJson(decodedData, "max_grade", "maxGrade") as List;
        decodedData = replaceKeysInJson(decodedData, "rounding_mode", "roundingMode") as List;
        decodedData = replaceKeysInJson(decodedData, "round_to", "roundTo") as List;
        decodedData = replaceKeysInJson(decodedData, "validated_school_system", "validatedSchoolSystem") as List;
        decodedData = replaceKeysInJson(decodedData, "validated_lux_system", "validatedLuxSystem") as List;
        decodedData = replaceKeysInJson(decodedData, "validated_year", "validatedYear") as List;
        decodedData = replaceKeysInJson(decodedData, "validated_section", "validatedSection") as List;
        decodedData = replaceKeysInJson(decodedData, "validated_variant", "validatedVariant") as List;
        decodedData = replaceKeysInJson(decodedData, "has_been_sorted_custom", "hasBeenSortedCustom") as List;

        // Subject, Term & Test
        decodedData = replaceKeysInJson(decodedData, "coefficient", "weight") as List;

        // Subject
        decodedData = replaceKeysInJson(decodedData, "type", "isGroup") as List;

        // Test
        decodedData = replaceKeysInJson(decodedData, "grade1", "numerator") as List;
        decodedData = replaceKeysInJson(decodedData, "grade2", "denominator") as List;

        // Rename settings keys
        setPreference("currentYear", getPreference<int>("current_year", 0));
        setPreference("currentTerm", getPreference<int>("current_term", 0));
        setPreference("sortMode1", getPreference<int>("sort_mode1", SortMode.name));
        setPreference("sortMode2", getPreference<int>("sort_mode2", SortMode.name));
        setPreference("sortDirection1", getPreference<int>("sort_direction1", SortDirection.ascending));
        setPreference("sortDirection2", getPreference<int>("sort_direction2", SortDirection.ascending));
        setPreference("dataVersion", getPreference<int>("data_version", -1));
        setPreference("termCount", getPreference<int>("term_count", 3));
        setPreference("maxGrade", getPreference<double>("max_grade", 60.0));
        setPreference("maxGradeString", getPreference<String>("max_grade_string", "60.0"));
        setPreference("roundingMode", getPreference<String>("rounding_mode", RoundingMode.up));
        setPreference("roundTo", getPreference<int>("round_to", 1));
        setPreference("leadingZero", getPreference<bool>("leading_zero", true));
        setPreference("isFirstRun", getPreference<bool>("is_first_run", true));
        setPreference("schoolSystem", getPreference<String>("school_system", ""));
        setPreference("luxSystem", getPreference<String>("lux_system", ""));
        setPreference("dynamicColor", getPreference<bool>("dynamic_color", true));
        setPreference("customColor", getPreference<int>("custom_color", 0xFF2196f3));
        setPreference("hapticFeedback", getPreference<bool>("haptic_feedback", true));

        // Remove old keys
        final List<String> keys = [
          "current_year",
          "current_term",
          "sort_mode1",
          "sort_mode2",
          "sort_direction1",
          "sort_direction2",
          "data_version",
          "term_count",
          "max_grade",
          "max_grade_string",
          "rounding_mode",
          "round_to",
          "leading_zero",
          "is_first_run",
          "school_system",
          "lux_system",
          "dynamic_color",
          "custom_color",
          "haptic_feedback",
        ];

        for (final String key in keys) {
          setPreference(key, null);
        }
      }

      if (currentDataVersion < 17) {
        // Convert bonus to double
        for (final year in decodedData) {
          for (final subject in year["subjects"] as List) {
            for (final term in subject["terms"] as List) {
              if (term["bonus"] is int) {
                term["bonus"] = (term["bonus"] as int).toDouble();
              }
            }
          }
        }
      }

      deserialize(data: decodedData);
    }

    setPreference<int>("dataVersion", dataVersion);
  }
}
