// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:customizable_space_bar/customizable_space_bar.dart';

// Project imports:
import 'package:gradely/Misc/excel_parser.dart';
import 'package:gradely/Misc/storage.dart';
import '../../Calculations/manager.dart';
import '../../Calculations/year.dart';
import '../../Translation/translations.dart';
import '/UI/Settings/flutter_settings_screens.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({Key? key}) : super(key: key);

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  void rebuild() {
    setState(() {});
  }

  bool hasSections(String year) {
    String luxSystem = Storage.getPreference("lux_system");

    if (luxSystem.isEmpty) {
      return false;
    } else if (luxSystem == "classic") {
      if (year.isEmpty) {
        return false;
      } else if (int.parse(year.substring(0, 1)) <= 3) {
        return true;
      }
      return false;
    } else {
      return false;
      //throw UnimplementedError();
    }
  }

  bool hasVariants(String year) {
    String luxSystem = Storage.getPreference("lux_system");

    if (luxSystem.isEmpty) {
      return false;
    } else if (luxSystem == "classic") {
      if (year.isEmpty) {
        return false;
      }
      return year != "7C";
    } else {
      return false;
      //throw UnimplementedError();
    }
  }

  Map<String, String> getVariants(String year) {
    String luxSystem = Storage.getPreference("lux_system");

    if (luxSystem.isEmpty) {
      return {};
    } else if (luxSystem == "classic") {
      if (!hasVariants(year)) {
        return {};
      }

      Map<String, String> result = <String, String>{};
      if (year == "1C") {
        result["basic"] = Translations.basic;
        result["latin"] = Translations.latin;
      } else {
        result["basic"] = Translations.basic;
        result["latin"] = Translations.latin;
        result["chinese"] = Translations.chinese;
      }

      return result;
    } else {
      throw UnimplementedError();
    }
  }

  void fillSubjects() {
    if (Storage.getPreference("school_system") == "lux") {
      if (Storage.getPreference("lux_system") == "classic") {
        if (!hasSections(Storage.getPreference("year"))) {
          Storage.setPreference<String>("section", defaultValues["section"]);
        }
        if (!hasVariants(Storage.getPreference("year")) || getVariants(Storage.getPreference("year"))[Storage.getPreference("variant")] == null) {
          Storage.setPreference<String>("variant", defaultValues["variant"]);
        }

        if (Storage.getPreference("year") == "1C") {
          Storage.setPreference("term", 2);
        } else {
          Storage.setPreference("term", 3);
        }
      }

      ExcelParser.fillSubjects();

      Storage.setPreference<double>("total_grades", 60.0);
      Storage.setPreference("rounding_mode", "rounding_up");
      Storage.setPreference("round_to", 1);
    }

    Manager.readPreferences();
    Manager.years.clear();
    Manager.years.add(Year());

    Manager.calculate();

    Storage.setPreference<bool>("is_first_run", false);
  }

  @override
  Widget build(BuildContext context) {
    ExcelParser.fillClassNames();

    return Scaffold(
      floatingActionButton: (Storage.getPreference("lux_system") == "classic" &&
                  Storage.getPreference<String>("year").isNotEmpty &&
                  (!hasSections(Storage.getPreference("year")) || Storage.getPreference<String>("section").isNotEmpty)) ||
              Storage.getPreference("school_system") == "other"
          ? FloatingActionButton(
              onPressed: () {
                fillSubjects();

                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).popUntil(ModalRoute.withName("/home"));
                } else {
                  Navigator.of(context).pushReplacementNamed("/home");
                }
              },
              child: const Icon(Icons.navigate_next),
            )
          : null,
      body: CustomScrollView(
        primary: true,
        slivers: [
          SliverAppBar(
            floating: false,
            pinned: true,
            automaticallyImplyLeading: Navigator.of(context).canPop(),
            expandedHeight: 150,
            flexibleSpace: CustomizableSpaceBar(
              builder: (context, scrollingRate) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12, left: 24 + 40 * scrollingRate),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      Translations.setup,
                      style: TextStyle(
                        fontSize: 42 - 18 * scrollingRate,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: SettingsContainer(
              children: [
                RadioModalSettingsTile<String>(
                  title: Translations.school_system,
                  leading: Icon(
                    Icons.school,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  settingKey: 'school_system',
                  onChange: (var value) {
                    rebuild();
                  },
                  values: <String, String>{
                    "lux": Translations.lux_system,
                    "other": Translations.other_system,
                  },
                ),
                Storage.getPreference("school_system") == "lux"
                    ? SettingsGroup(
                        title: Translations.lux_system,
                        children: [
                          RadioModalSettingsTile<String>(
                            title: Translations.system,
                            leading: Icon(
                              Icons.build,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            settingKey: 'lux_system',
                            onChange: (var value) {
                              Storage.setPreference<String>("year", defaultValues["year"]);
                              Storage.setPreference<String>("section", defaultValues["section"]);
                              Storage.setPreference<String>("variant", defaultValues["variant"]);
                              rebuild();
                            },
                            values: <String, String>{
                              "classic": Translations.classic,
                              "general": "General (coming soon)",
                              //"general": Translations.general,
                            },
                          ),
                          Storage.existsPreference("lux_system") && Storage.getPreference("lux_system") == "classic"
                              ? RadioModalSettingsTile<String>(
                                  title: Translations.year,
                                  leading: Icon(
                                    Icons.timelapse,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                  settingKey: 'year',
                                  onChange: (var value) {
                                    if (hasSections(Storage.getPreference("year"))) {
                                      Storage.setPreference<String>("section", defaultValues["section"]);
                                    }
                                    if (getVariants(Storage.getPreference("year"))[Storage.getPreference("variant")] == null) {
                                      Storage.setPreference<String>("variant", defaultValues["variant"]);
                                    }
                                    rebuild();
                                  },
                                  values: ExcelParser.years,
                                )
                              : Container(),
                          hasSections(Storage.getPreference("year")) && Storage.getPreference("lux_system") == "classic"
                              ? RadioModalSettingsTile<String>(
                                  title: Translations.section,
                                  leading: Icon(
                                    Icons.fork_right,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                  settingKey: 'section',
                                  onChange: (var value) {
                                    rebuild();
                                  },
                                  values: ExcelParser.getSections(context),
                                )
                              : Container(),
                          Storage.existsPreference("year") &&
                                  hasVariants(Storage.getPreference("year")) &&
                                  Storage.getPreference("lux_system") == "classic"
                              ? RadioModalSettingsTile<String>(
                                  title: Translations.variant,
                                  leading: Icon(
                                    Icons.edit,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                  settingKey: 'variant',
                                  onChange: (var value) {
                                    rebuild();
                                  },
                                  selected: defaultValues["variant"],
                                  values: getVariants(Storage.getPreference("year")),
                                )
                              : Container(),
                        ],
                      )
                    : Storage.getPreference("school_system") == "other"
                        ? SettingsGroup(
                            title: Translations.other_system,
                            children: [
                              SimpleSettingsTile(
                                leading: Icon(
                                  Icons.subject,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                onTap: () {
                                  Navigator.pushNamed(context, "/subject_edit");
                                },
                                title: Translations.add_subjects,
                                subtitle: Translations.edit_subjects_summary,
                              ),
                              RadioModalSettingsTile<int>(
                                title: Translations.term,
                                leading: Icon(
                                  Icons.access_time_outlined,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                settingKey: 'term',
                                onChange: (var value) {
                                  Manager.readPreferences();
                                },
                                values: <int, String>{
                                  3: Translations.trimesters,
                                  2: Translations.semesters,
                                  1: Translations.year,
                                },
                                selected: defaultValues["term"],
                              ),
                              TextInputSettingsTile(
                                title: Translations.rating_system,
                                settingKey: 'total_grades_text',
                                initialValue: defaultValues["total_grades"].toString(),
                                leading: Icon(
                                  Icons.vertical_align_top,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                keyboardType: TextInputType.number,
                                onChange: (text) {
                                  double d = double.parse(text);
                                  Storage.setPreference<double>("total_grades", d);
                                  Manager.totalGrades = d;
                                },
                                validator: (String? input) {
                                  if (input == null || input.isEmpty || double.tryParse(input) != null) {
                                    return null;
                                  }
                                  return Translations.invalid;
                                },
                              ),
                              RadioModalSettingsTile<String>(
                                title: Translations.rounding_mode,
                                leading: Icon(
                                  Icons.arrow_upward,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                settingKey: 'rounding_mode',
                                values: <String, String>{
                                  "rounding_up": Translations.up,
                                  "rounding_down": Translations.down,
                                  "rounding_half_up": Translations.half_up,
                                  "rounding_half_down": Translations.half_down,
                                },
                                selected: defaultValues["rounding_mode"],
                              ),
                              RadioModalSettingsTile<int>(
                                title: Translations.round_to,
                                leading: Icon(
                                  Icons.cut,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                settingKey: 'round_to',
                                values: <int, String>{
                                  1: Translations.to_integer,
                                  10: Translations.to_10th,
                                  100: Translations.to_100th,
                                },
                                selected: defaultValues["round_to"],
                              ),
                            ],
                          )
                        : Container(),
                SimpleSettingsTile(
                  title: Translations.note,
                  subtitle: Translations.note_text,
                  leading: Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  enabled: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
