// Flutter imports:
import "package:flutter/material.dart";

// Project imports:
import "package:graded/calculations/calculator.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/localization/translations.dart";
import "package:graded/misc/compatibility.dart";
import "package:graded/misc/default_values.dart";
import "package:graded/misc/enums.dart";
import "package:graded/misc/storage.dart";
import "package:graded/ui/settings/flutter_settings_screens.dart";

List<Widget> getSettingsTiles(BuildContext context, {required CreationType type, Function()? onChanged}) {
  String subjectEditingPageTitle = type == CreationType.add ? translations.add_subjects : translations.edit_subjects;

  return [
    SimpleSettingsTile(
      icon: Icons.subject,
      onTap: () => Navigator.pushNamed(context, "/subject_edit").then((value) => onChanged?.call()),
      title: subjectEditingPageTitle,
      subtitle: translations.edit_subjects_summary,
    ),
    RadioModalSettingsTile<int>(
      title: translations.school_term,
      icon: Icons.access_time_outlined,
      settingKey: "term",
      onChange: (_) {
        Compatibility.termCount();
        onChanged?.call();
      },
      values: <int, String>{
        3: translations.trimesters,
        2: translations.semesters,
        1: translations.year,
      },
      selected: defaultValues["term"] as int,
    ),
    TextInputSettingsTile(
      title: translations.rating_system,
      settingKey: "total_grades_text",
      initialValue: defaultValues["total_grades"].toString(),
      icon: Icons.vertical_align_top,
      onChange: (value) {
        double? parsed = Calculator.tryParse(value);
        if (parsed == null) return;

        setPreference<double>("total_grades", parsed);
        Manager.calculate();

        onChanged?.call();
      },
      numeric: true,
      additionalValidator: (newValue) {
        double? number = Calculator.tryParse(newValue);

        if (number == null || number <= 0) {
          return translations.invalid;
        }

        return null;
      },
    ),
    RadioModalSettingsTile<String>(
      title: translations.rounding_mode,
      icon: Icons.arrow_upward,
      settingKey: "rounding_mode",
      onChange: (_) {
        Manager.calculate();
        onChanged?.call();
      },
      values: <String, String>{
        RoundingMode.up: translations.up,
        RoundingMode.down: translations.down,
        RoundingMode.halfUp: translations.half_up,
        RoundingMode.halfDown: translations.half_down,
      },
      selected: defaultValues["rounding_mode"] as String,
    ),
    RadioModalSettingsTile<int>(
      title: translations.round_to,
      icon: Icons.cut,
      settingKey: "round_to",
      onChange: (_) {
        Manager.calculate();
        onChanged?.call();
      },
      values: <int, String>{
        1: translations.to_integer,
        10: translations.to_10th,
        100: translations.to_100th,
      },
      selected: defaultValues["round_to"] as int,
    ),
  ];
}
