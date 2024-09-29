// Project imports:
// ignore_for_file: avoid_dynamic_calls

import "dart:convert";

import "package:graded/localization/translations.dart";
import "package:graded/misc/default_values.dart";
import "package:graded/misc/enums.dart";
import "package:graded/misc/setup_manager.dart";
import "package:graded/misc/storage.dart";

class Compatibility {
  static const dataVersion = 15;

  static void upgradeDataVersion({bool imported = false}) {
    if (!getPreference<bool>("is_first_run") || imported) {
      String data = getPreference<String>("data");
      List decodedData = jsonDecode(data) as List;
      final int currentDataVersion = getPreference<int>("data_version");

      void updateData() {
        data = jsonEncode(decodedData);
      }

      void updateDecodedData() {
        decodedData = jsonDecode(data) as List;
      }

      if (currentDataVersion < 2) {
        data = data.replaceAll("period", "term").replaceAll("mark", "grade");
        updateDecodedData();
        setPreference<String?>("default_data", getPreference<String>("default_data", "[]").replaceAll("period", "term").replaceAll("mark", "grade"));
      }

      if (currentDataVersion < 5) {
        setPreference<String>("language", DefaultValues.language);
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
          final List<String> keys = ["validated_lux_system", "validated_year", "validated_section", "validated_variant"];

          for (final String key in keys) {
            setPreference(key, defaultValues[key]);
          }
        }
      }

      if (currentDataVersion < 9) {
        //Sort direction
        for (int sortType = 1; sortType <= 2; sortType++) {
          final int sortMode = getPreference<int>("sort_mode$sortType", SortMode.name);
          int sortDirection = SortDirection.ascending;

          switch (sortMode) {
            case SortMode.name:
            case SortMode.custom:
              sortDirection = SortDirection.ascending;
            case SortMode.result:
            case SortMode.coefficient:
              sortDirection = SortDirection.descending;
            default:
              throw const FormatException("Invalid");
          }
          setPreference<int>("sort_direction$sortType", sortDirection);
        }
      }

      if (currentDataVersion < 10) {
        //Fix exam coefficient
        if (getPreference<String>("validated_school_system", "") == "lux" && getPreference<int>("validated_year", -1) == 1) {
          for (final term in decodedData[0]["terms"] as List) {
            if (term["weight"] == 2) {
              term["isExam"] = true;
            }
          }

          updateData();
        }
      }

      if (currentDataVersion < 11) {
        //Change currentTerm behavior
        final int currentTerm = getPreference<int>("current_term", 0);
        if (currentTerm == -1) {
          setPreference("current_term", 0);
        }
      }

      if (currentDataVersion < 12) {
        //Move termTemplate into year
        final termTemplateList = jsonDecode(getPreference<String>("default_data", "[]")) as List;
        decodedData[0]["term_template"] = termTemplateList;

        setPreference("default_data", null);

        //Add year name
        decodedData[0]["name"] = "${translations.yearOne} 1";

        updateData();
      }

      if (currentDataVersion < 13) {
        //Move validated data into year
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

        updateData();
      }

      if (currentDataVersion < 14) {
        //Rename settings
        setPreference<int>("term_count", getPreference<int>("term", 3));
        setPreference<double>("max_grade", getPreference<double>("total_grades", 60.0));

        setPreference("term", null);
        setPreference("total_grades", null);
        setPreference("total_grades_description", null);

        //Move settings into year
        decodedData[0]["term_count"] = getPreference<int>("term_count", 3);
        decodedData[0]["max_grade"] = getPreference<double>("max_grade", 60);
        decodedData[0]["rounding_mode"] = getPreference<String>("rounding_mode", RoundingMode.up);
        decodedData[0]["round_to"] = getPreference<int>("round_to", 1);

        updateData();
      }

      if (currentDataVersion < 15) {
        //Change order from Year->Term->Subject to Year->Subject->Term

        // Function to handle child subjects recursively
        Map<String, dynamic> handleSubject(Map<String, dynamic> subject, double termCoefficient, bool isExam) {
          // Extract subject details
          final String subjectName = subject["name"] as String;
          final double subjectCoefficient = subject["coefficient"] as double;
          final double speakingWeight = subject["speakingWeight"] as double? ?? DefaultValues.speakingWeight;
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
          final int termCount = yearData["term_count"] as int? ?? DefaultValues.termCount;
          final double maxGrade = yearData["max_grade"] as double? ?? DefaultValues.maxGrade;
          final String roundingMode = yearData["rounding_mode"] as String? ?? DefaultValues.roundingMode;
          final int roundTo = yearData["round_to"] as int? ?? DefaultValues.roundTo;
          final String? validatedSchoolSystem = yearData["validated_school_system"] as String?;
          final String? validatedLuxSystem = yearData["validated_lux_system"] as String?;
          final int? validatedYear = yearData["validated_year"] as int?;
          final String? validatedSection = yearData["validated_section"] as String?;
          final String? validatedVariant = yearData["validated_variant"] as String?;

          // Initialize the new structure for subjects
          final Map<String, Map<String, dynamic>> subjectMap = {};

          // Iterate over terms
          for (final term in yearData["terms"] as List) {
            final double termCoefficient = term["coefficient"] as double? ?? DefaultValues.weight;
            final bool isExam = term["isExam"] as bool? ?? DefaultValues.isExam;

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

        //Keep termTemplate order
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

        updateData();
      }

      //TODO: Change everything to lowerCamelCase

      deserialize(dataString: data);
    }

    setPreference<int>("data_version", dataVersion);
  }
}
