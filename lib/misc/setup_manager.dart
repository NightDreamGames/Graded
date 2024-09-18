// Dart imports:
import "dart:convert";

// Flutter imports:
import "package:flutter/services.dart" show rootBundle;

// Package imports:
import "package:collection/collection.dart";

// Project imports:
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/calculations/year.dart";
import "package:graded/localization/translations.dart";
import "package:graded/misc/default_values.dart";
import "package:graded/misc/enums.dart";
import "package:graded/misc/storage.dart";

class SetupManager {
  static String classicPath = "assets/class_data/lux/classique.json";
  static String generalPath = "assets/class_data/lux/general.json";
  static List<String?> cache = [null, null];
  static bool inSetup = false;
  static Year year = Year();

  static Map<int, String> getYears() {
    return {
      7: "7e",
      6: "6e",
      5: "5e",
      4: "4e",
      3: "3e",
      2: "2e",
      1: "1e",
    };
  }

  static bool hasSections([String? luxSystemOverride, int? yearOverride]) {
    return getSections(luxSystemOverride, yearOverride).isNotEmpty;
  }

  static Map<String, String> getSections([String? luxSystemOverride, int? yearOverride]) {
    final Map<String, String> result = <String, String>{};
    final String luxSystem = luxSystemOverride ?? getPreference<String>("lux_system");
    final int year = yearOverride ?? getPreference<int>("year");

    if (year == -1 || luxSystem.isEmpty) return result;

    if (luxSystem == "classic" && year <= 3) {
      result.addAll({
        "A": translations.section_classic_a,
        "B": translations.section_classic_b,
        "C": translations.section_classic_c,
        "D": translations.section_classic_d,
        "E": translations.section_classic_e,
        "F": translations.section_classic_f,
        "G": translations.section_classic_g,
        "I": translations.section_classic_i,
      });
    } else if (luxSystem == "general") {
      if (year <= 4) {
        result.addAll({
          "GH": translations.section_general_gh,
          "SO": translations.section_general_so,
          "A3D": translations.section_general_a3d,
          "IG": translations.section_general_ig,
          "SN": translations.section_general_sn,
          "ACV": translations.section_general_acv,
        });
      }
      if (year == 4 || year == 3) {
        result.addAll({
          "CM": translations.section_general_cm,
          "PS": translations.section_general_ps,
        });
      } else if (year == 2 || year == 1) {
        result.addAll({
          "CG": translations.section_general_cg,
          "CC": translations.section_general_cc,
          "CF": translations.section_general_cf,
          "MM": translations.section_general_mm,
          "ED": translations.section_general_ed,
          "SI": translations.section_general_si,
          "SH": translations.section_general_sh,
          "IN": translations.section_general_in,
          "SE": translations.section_general_se,
        });
      }
    }

    return Map.fromEntries(result.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));
  }

  static bool hasVariants([String? luxSystemOverride, int? yearOverride, String? sectionOverride]) {
    return getVariants(luxSystemOverride, yearOverride, sectionOverride).isNotEmpty;
  }

  static Map<String, String> getVariants([String? luxSystemOverride, int? yearOverride, String? sectionOverride]) {
    final String luxSystem = luxSystemOverride ?? getPreference<String>("lux_system");
    final int year = yearOverride ?? getPreference<int>("year");
    final String section = sectionOverride ?? getPreference<String>("section");

    final Map<String, String> result = <String, String>{};

    if (year == -1 || luxSystem.isEmpty) return result;

    if (luxSystem == "classic") {
      if (year != 7) {
        result.addAll({
          "": translations.basic,
          "L": translations.variant_classic_l,
        });
        if (year != 1) {
          result.addAll({
            "ZH": translations.variant_classic_zh,
          });
        }
      }
    } else {
      if (year >= 5 && year <= 7) {
        result.addAll({
          "": translations.basic,
          "-FR": translations.variant_general_fr,
          "P": translations.variant_general_p,
          "PF": translations.variant_general_pf,
          "IA": translations.variant_general_ia,
          "IF": translations.variant_general_if,
        });
        if (year == 5) {
          result.addAll({
            "AD": translations.variant_general_ad,
            "ADF": translations.variant_general_adf,
          });
        }
      }
      if (section.isNotEmpty) {
        if (section == "CM" || section == "CG" || section == "PS" || section == "SO" || section == "IG" || section == "SN") {
          result.addAll({
            "": translations.basic,
            "A": translations.variant_general_a,
            "F": translations.variant_general_f,
          });
        } else if (section == "CC" || section == "SI") {
          result.addAll({
            "": translations.basic,
            "F": translations.variant_general_f,
          });
        }
      }
    }

    return Map.fromEntries(result.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));
  }

  static Future<void> init() async {
    inSetup = true;
    year = Year();

    cache = [await rootBundle.loadString(classicPath), await rootBundle.loadString(generalPath)];
  }

  static void dispose() {
    inSetup = false;
    cache.clear();
  }

  static Future<void> completeSetup() async {
    year.validatedSchoolSystem = getPreference<String>("school_system");

    if (getPreference<String>("school_system") == "lux") {
      await completeLuxSystem();
    }

    Manager.addYear(year: year);

    inSetup = false;
    year.ensureTermCount();

    setPreference<bool>("is_first_run", false);
  }

  static Future<void> completeLuxSystem() async {
    year.validatedLuxSystem = getPreference<String>("lux_system");
    year.validatedYear = getPreference<int>("year");

    if (hasSections()) {
      year.validatedSection = getPreference<String>("section");
    } else {
      setPreference<String>("section", DefaultValues.section);
    }

    if (hasVariants() && getVariants()[getPreference<String>("variant")] != null) {
      year.validatedVariant = getPreference<String>("variant");
    } else {
      setPreference<String>("variant", DefaultValues.variant);
    }

    if (getPreference<int>("year") == 1) {
      year.termCount = 2;
    }

    year.maxGrade = 60;
    year.roundingMode = RoundingMode.up;
    year.roundTo = 1;

    year.clearSubjects();

    final List<Subject> termTemplate = await fillSubjects();

    for (final Subject subject in termTemplate) {
      year.addSubject(subject);
    }
  }

  static Future<List<Subject>> fillSubjects() async {
    final List<Subject> termTemplate = [];
    final int year = getPreference<int>("year");
    final String section = getPreference<String>("section");
    final String variant = getPreference<String>("variant");

    final bool classic = getPreference<String>("lux_system") == "classic";
    String letter = classic ? "C" : "G";
    if (variant == "P" || variant == "PF" || variant == "AD" || variant == "ADF") letter = "";

    final String className = year.toString() + letter + (classic ? variant : "") + section + (classic ? "" : variant);

    final String data = cache[classic ? 0 : 1] ?? (cache[classic ? 0 : 1] = await rootBundle.loadString(classic ? classicPath : generalPath));
    final json = jsonDecode(data) as List;

    final Map<String, dynamic> classObject = json[binarySearch(
      json,
      {"name": className},
      compare: (element1, element2) =>
          ((element1! as Map<String, dynamic>)["name"] as String).compareTo((element2! as Map<String, dynamic>)["name"] as String),
    )] as Map<String, dynamic>;

    for (final subject in (classObject["subjects"] as List<dynamic>).cast<Map<String, dynamic>>()) {
      final Subject newSubject = Subject(
        subject["name"] as String,
        (subject["coefficient"] as int?)?.toDouble() ?? 0,
        isGroup: subject["children"] != null,
      );
      termTemplate.add(newSubject);

      if (subject["children"] == null) continue;
      for (final childSubject in (subject["children"] as List<dynamic>).cast<Map<String, dynamic>>()) {
        newSubject.children.add(
          Subject(
            childSubject["name"] as String,
            (childSubject["coefficient"] as int?)?.toDouble() ?? 0,
            isChild: true,
          ),
        );
      }
    }

    return termTemplate;
  }
}
