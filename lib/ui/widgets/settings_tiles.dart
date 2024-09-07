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
import "package:graded/ui/utilities/haptics.dart";
import "package:graded/ui/utilities/misc_utilities.dart";

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
      initialValue: DefaultValues.maxGrade.toString(),
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
      additionalValidator: (value) {
        final positiveCheck = thresholdValidator(value, inclusive: false);
        final nullCheck = nullValidator(value);

        if (positiveCheck != null) return positiveCheck;
        if (nullCheck != null) return nullCheck;

        return null;
      },
    ),
    RadioModalSettingsTile<String>(
      title: translations.rounding_mode,
      icon: Icons.arrow_upward,
      settingKey: "rounding_mode",
      selected: DefaultValues.roundingMode,
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
      selected: DefaultValues.roundTo,
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
      selected: DefaultValues.termCount,
      values: <int, String>{
        4: translations.quartileOther,
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

class ImportSettingsTile extends StatelessWidget {
  const ImportSettingsTile({
    super.key,
    this.onChanged,
  });
  final Function()? onChanged;

  @override
  Widget build(BuildContext context) {
    return SimpleSettingsTile(
      icon: Icons.file_download_outlined,
      title: translations.import_,
      subtitle: translations.import_description,
      onTap: () => importData().then((success) {
        if (!success) heavyHaptics();
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? translations.import_success : translations.import_error),
          ),
        );

        if (!success) return;

        onChanged?.call();
      }),
    );
  }
}
