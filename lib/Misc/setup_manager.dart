// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/services.dart' show rootBundle;

// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import '../Calculations/manager.dart';
import '../Calculations/subject.dart';
import '../Translations/translations.dart';
import 'compatibility.dart';
import 'storage.dart';

class SetupManager {
  static String classicPath = "assets/class_data/classique.json";
  static String generalPath = "assets/class_data/general.json";

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

  static bool hasSections() {
    return getSections().isNotEmpty;
  }

  static Map<String, String> getSections() {
    Map<String, String> result = <String, String>{};
    String luxSystem = getPreference("lux_system");
    int year = getPreference("year");

    if (year == -1 || luxSystem.isEmpty) return result;

    if (luxSystem == "classic" && year <= 3) {
      result.addAll({
        "A": Translations.section_classic_a,
        "B": Translations.section_classic_b,
        "C": Translations.section_classic_c,
        "D": Translations.section_classic_d,
        "E": Translations.section_classic_e,
        "F": Translations.section_classic_f,
        "G": Translations.section_classic_g,
        "I": Translations.section_classic_i,
      });
    } else if (luxSystem == "general") {
      if (year <= 4) {
        result.addAll({
          "GH": Translations.section_general_gh,
          "SO": Translations.section_general_so,
          "A3D": Translations.section_general_a3d,
          "IG": Translations.section_general_ig,
          "SN": Translations.section_general_sn,
          "ACV": Translations.section_general_acv,
        });
      }
      if (year == 4 || year == 3) {
        result.addAll({
          "CM": Translations.section_general_cm,
          "PS": Translations.section_general_ps,
        });
      } else if (year == 2 || year == 1) {
        result.addAll({
          "CG": Translations.section_general_cg,
          "CC": Translations.section_general_cc,
          "CF": Translations.section_general_cf,
          "MM": Translations.section_general_mm,
          "ED": Translations.section_general_ed,
          "SI": Translations.section_general_si,
          "SH": Translations.section_general_sh,
          "IN": Translations.section_general_in,
          "SE": Translations.section_general_se,
        });
      }
    }

    return Map.fromEntries(result.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));
  }

  static bool hasVariants() {
    return getVariants().isNotEmpty;
  }

  static Map<String, String> getVariants() {
    String luxSystem = getPreference("lux_system");
    int year = getPreference("year");
    String section = getPreference("section");

    Map<String, String> result = <String, String>{};

    if (year == -1 || luxSystem.isEmpty) return result;

    if (luxSystem == "classic") {
      if (year != 7) {
        result.addAll({
          "": Translations.basic,
          "L": Translations.variant_classic_l,
        });
        if (year != 1) {
          result.addAll({
            "ZH": Translations.variant_classic_zh,
          });
        }
      }
    } else {
      if (year >= 5 && year <= 7) {
        result.addAll({
          "": Translations.basic,
          "-FR": Translations.variant_general_fr,
          "P": Translations.variant_general_p,
          "PF": Translations.variant_general_pf,
          "IA": Translations.variant_general_ia,
          "IF": Translations.variant_general_if,
        });
        if (year == 5) {
          result.addAll({
            "AD": Translations.variant_general_ad,
            "ADF": Translations.variant_general_adf,
          });
        }
      }
      if (section.isNotEmpty) {
        if (section == "CM" || section == "CG" || section == "PS" || section == "SO" || section == "IG" || section == "SN") {
          result.addAll({
            "": Translations.basic,
            "A": Translations.variant_general_a,
            "F": Translations.variant_general_f,
          });
        } else if (section == "CC" || section == "SI") {
          result.addAll({
            "": Translations.basic,
            "F": Translations.variant_general_f,
          });
        }
      }
    }

    return Map.fromEntries(result.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));
  }

  static void init() {
    rootBundle.loadString(classicPath);
    rootBundle.loadString(generalPath);
  }

  static Future<void> completeSetup() async {
    setPreference("validated_school_system", getPreference("school_system"));

    if (getPreference("school_system") == "lux") {
      setPreference("validated_lux_system", getPreference("lux_system"));
      setPreference("validated_year", getPreference("year"));

      if (!hasSections()) {
        setPreference<String>("section", defaultValues["section"]);
      } else {
        setPreference("validated_section", getPreference("section"));
      }

      if (!hasVariants() || getVariants()[getPreference("variant")] == null) {
        setPreference<String>("variant", defaultValues["variant"]);
      } else {
        setPreference("validated_variant", getPreference("variant"));
      }

      if (getPreference("year") == 1) {
        setPreference("term", 2);
      }

      setPreference<double>("total_grades", 60);
      setPreference("rounding_mode", "rounding_up");
      setPreference("round_to", 1);

      await fillSubjects();
    }

    Compatibility.termCount();
    Manager.clear();
    Manager.calculate();

    setPreference<bool>("is_first_run", false);
  }

  static Future<void> fillSubjects() async {
    Manager.termTemplate.clear();
    int year = getPreference("year");
    String section = getPreference("section");
    String variant = getPreference("variant");

    bool classic = getPreference("lux_system") == "classic";
    String letter = classic ? "C" : "G";
    if (variant == "P" || variant == "PF" || variant == "AD" || variant == "ADF") letter = "";

    String className = year.toString() + letter + (classic ? variant : "") + section + (classic ? "" : variant);

    String file = await rootBundle.loadString(classic ? classicPath : generalPath);
    final data = jsonDecode(file) as List;

    var classObject = data[binarySearch(data, {"name": className},
        compare: (element1, element2) => (element1 as Map<String, dynamic>)["name"].compareTo((element2 as Map<String, dynamic>)["name"]))];

    for (var subject in classObject["subjects"]) {
      Subject newSubject = Subject(subject["name"], (subject["coefficient"] ?? 0).toDouble(), isGroup: subject["children"] != null);
      Manager.termTemplate.add(newSubject);
      if (subject["children"] != null) {
        for (var child in subject["children"]) {
          newSubject.children.add(Subject(child["name"], (child["coefficient"] ?? 0).toDouble(), isChild: true));
        }
      }
    }
  }
}
