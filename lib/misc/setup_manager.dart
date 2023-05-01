// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/services.dart' show rootBundle;

// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import '../calculations/calculator.dart';
import '../calculations/manager.dart';
import '../calculations/subject.dart';
import '../localization/translations.dart';
import 'compatibility.dart';
import 'storage.dart';

class SetupManager {
  static String classicPath = "assets/class_data/classique.json";
  static String generalPath = "assets/class_data/general.json";
  static List<String?> cache = [null, null];

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
    Map<String, String> result = <String, String>{};
    String luxSystem = luxSystemOverride ?? getPreference<String>("lux_system");
    int year = yearOverride ?? getPreference<int>("year");

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
    String luxSystem = luxSystemOverride ?? getPreference<String>("lux_system");
    int year = yearOverride ?? getPreference<int>("year");
    String section = sectionOverride ?? getPreference<String>("section");

    Map<String, String> result = <String, String>{};

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

  static void init() async {
    cache[0] = await rootBundle.loadString(classicPath);
    cache[1] = await rootBundle.loadString(generalPath);
  }

  static Future<void> completeSetup() async {
    List<String> keys = ["validated_lux_system", "validated_year", "validated_section", "validated_variant"];

    for (String key in keys) {
      setPreference(key, defaultValues[key]);
    }

    setPreference<String>("validated_school_system", getPreference<String>("school_system"));

    if (getPreference<String>("school_system") == "lux") {
      await completeLuxSystem();
    }

    Compatibility.termCount();
    Manager.clear();
    Manager.calculate();

    setPreference<bool>("is_first_run", false);
  }

  static Future<void> completeLuxSystem() async {
    setPreference<String>("validated_lux_system", getPreference<String>("lux_system"));
    setPreference<int>("validated_year", getPreference<int>("year"));

    if (hasSections()) {
      setPreference<String>("validated_section", getPreference<String>("section"));
    } else {
      setPreference<String>("section", defaultValues["section"]);
    }

    if (hasVariants() && getVariants()[getPreference<String>("variant")] != null) {
      setPreference<String>("validated_variant", getPreference<String>("variant"));
    } else {
      setPreference<String>("variant", defaultValues["variant"]);
    }

    if (getPreference<int>("year") == 1) {
      setPreference<int>("term", 2);
    }

    setPreference<double>("total_grades", 60);
    setPreference<String>("rounding_mode", RoundingMode.up);
    setPreference<int>("round_to", 1);

    await fillSubjects();
  }

  static Future<void> fillSubjects() async {
    Manager.termTemplate.clear();
    int year = getPreference<int>("year");
    String section = getPreference<String>("section");
    String variant = getPreference<String>("variant");

    bool classic = getPreference<String>("lux_system") == "classic";
    String letter = classic ? "C" : "G";
    if (variant == "P" || variant == "PF" || variant == "AD" || variant == "ADF") letter = "";

    String className = year.toString() + letter + (classic ? variant : "") + section + (classic ? "" : variant);

    String data = cache[classic ? 0 : 1] ?? (cache[classic ? 0 : 1] = await rootBundle.loadString(classic ? classicPath : generalPath));
    final json = jsonDecode(data) as List;

    var classObject = json[binarySearch(json, {"name": className},
        compare: (element1, element2) => (element1 as Map<String, dynamic>)["name"].compareTo((element2 as Map<String, dynamic>)["name"]))];

    for (var subject in classObject["subjects"]) {
      Subject newSubject =
          Subject(subject["name"], (subject["coefficient"] ?? 0).toDouble(), defaultValues["speaking_weight"], isGroup: subject["children"] != null);
      Manager.termTemplate.add(newSubject);
      if (subject["children"] != null) {
        for (var child in subject["children"]) {
          newSubject.children.add(Subject(child["name"], (child["coefficient"] ?? 0).toDouble(), defaultValues["speaking_weight"], isChild: true));
        }
      }
    }
  }
}
