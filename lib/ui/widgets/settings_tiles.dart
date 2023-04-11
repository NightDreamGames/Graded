// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../calculations/calculator.dart';
import '../../calculations/manager.dart';
import '../../localization/translations.dart';
import '../../misc/compatibility.dart';
import '../../misc/storage.dart';
import '../settings/flutter_settings_screens.dart';

List<Widget> getSettingsTiles(BuildContext context, bool type) {
  return [
    SimpleSettingsTile(
      icon: Icons.subject,
      onTap: () => Navigator.pushNamed(context, "/subject_edit"),
      title: type ? translations.add_subjects : translations.edit_subjects,
      subtitle: translations.edit_subjects_summary,
    ),
    RadioModalSettingsTile<int>(
      title: translations.term,
      icon: Icons.access_time_outlined,
      settingKey: 'term',
      onChange: (_) => Compatibility.termCount(),
      values: <int, String>{
        3: translations.trimesters,
        2: translations.semesters,
        1: translations.year,
      },
      selected: defaultValues["term"],
    ),
    TextInputSettingsTile(
      title: translations.rating_system,
      settingKey: 'total_grades_text',
      initialValue: defaultValues["total_grades"].toString(),
      icon: Icons.vertical_align_top,
      onChange: (value) {
        double? parsed = Calculator.tryParse(value);
        if (parsed != null) {
          setPreference<double>("total_grades", parsed);
        }

        Manager.calculate();
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
      settingKey: 'rounding_mode',
      onChange: (_) => Manager.calculate(),
      values: <String, String>{
        RoundingMode.up: translations.up,
        RoundingMode.down: translations.down,
        RoundingMode.halfUp: translations.half_up,
        RoundingMode.halfDown: translations.half_down,
      },
      selected: defaultValues["rounding_mode"],
    ),
    RadioModalSettingsTile<int>(
      title: translations.round_to,
      icon: Icons.cut,
      settingKey: 'round_to',
      onChange: (_) => Manager.calculate(),
      values: <int, String>{
        1: translations.to_integer,
        10: translations.to_10th,
        100: translations.to_100th,
      },
      selected: defaultValues["round_to"],
    ),
  ];
}
