// Flutter imports:
import "package:flutter/material.dart";

// Project imports:
import "package:graded/calculations/calculator.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/localization/translations.dart";
import "package:graded/misc/default_values.dart";
import "package:graded/misc/enums.dart";
import "package:graded/misc/storage.dart";
import "package:graded/ui/settings/flutter_settings_screens.dart";

List<Widget> getSettingsTiles(BuildContext context, {required CreationType type, Function()? onChanged}) {
  final String subjectEditingPageTitle = type == CreationType.add ? translations.add_subjectOther : translations.edit_subjectOther;

  setPreference<int>("term_count", getCurrentYear().termCount);
  setPreference<double>("max_grade", getCurrentYear().maxGrade);
  setPreference<String>("max_grade_string", getCurrentYear().maxGrade.toString());
  setPreference<String>("rounding_mode", getCurrentYear().roundingMode);
  setPreference<int>("round_to", getCurrentYear().roundTo);

  return [
    SimpleSettingsTile(
      title: subjectEditingPageTitle,
      subtitle: translations.edit_subjects_description,
      icon: Icons.subject,
      onTap: () => Navigator.pushNamed(context, "/subject_edit", arguments: type).then((value) => onChanged?.call()),
    ),
    TermCountSettingsTile(
      onChanged: onChanged,
    ),
    TextInputSettingsTile(
      title: translations.rating_system,
      icon: Icons.vertical_align_top,
      settingKey: "max_grade_string",
      initialValue: defaultValues["max_grade"].toString(),
      numeric: true,
      onChange: (value) {
        final double? parsed = Calculator.tryParse(value);
        if (parsed == null) return;

        setPreference<double>("max_grade", parsed);
        setPreference<String>("max_grade_string", parsed.toString());
        getCurrentYear().maxGrade = parsed;
        Manager.calculate();

        onChanged?.call();
      },
      additionalValidator: (newValue) {
        final double? number = Calculator.tryParse(newValue);

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
      selected: defaultValues["rounding_mode"] as String,
      values: <String, String>{
        RoundingMode.up: translations.up,
        RoundingMode.down: translations.down,
        RoundingMode.halfUp: translations.half_up,
        RoundingMode.halfDown: translations.half_down,
      },
      onChange: (value) {
        getCurrentYear().roundingMode = value;
        Manager.calculate();
        onChanged?.call();
      },
    ),
    RadioModalSettingsTile<int>(
      title: translations.round_to,
      icon: Icons.cut,
      settingKey: "round_to",
      selected: defaultValues["round_to"] as int,
      values: <int, String>{
        1: translations.to_integer,
        10: translations.to_10th,
        100: translations.to_100th,
      },
      onChange: (value) {
        getCurrentYear().roundTo = value;
        Manager.calculate();
        onChanged?.call();
      },
    ),
  ];
}

class TermCountSettingsTile extends StatelessWidget {
  const TermCountSettingsTile({
    super.key,
    this.onChanged,
  });
  final Function()? onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioModalSettingsTile<int>(
      title: translations.school_termOne,
      icon: Icons.access_time_outlined,
      settingKey: "term_count",
      selected: defaultValues["term_count"] as int,
      values: <int, String>{
        4: translations.quarterOther,
        3: translations.trimesterOther,
        2: translations.semesterOther,
        1: translations.yearOne,
      },
      onChange: (value) {
        getCurrentYear().termCount = value;
        getCurrentYear().ensureTermCount();
        onChanged?.call();
      },
    );
  }
}
