import 'package:gradely/Misc/excel_parser.dart';
import 'package:gradely/Misc/storage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:customizable_space_bar/customizable_space_bar.dart';

import '../Calculations/manager.dart';
import '../Calculations/year.dart';
import '../Translation/i18n.dart';
import '/UI/Settings/flutter_settings_screens.dart';
import 'subject_edit_route.dart';

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
        result["basic"] = I18n.of(context).basic;
        result["latin"] = I18n.of(context).latin;
      } else {
        result["basic"] = I18n.of(context).basic;
        result["latin"] = I18n.of(context).latin;
        result["chinese"] = I18n.of(context).chinese;
      }

      return result;
    } else {
      throw UnimplementedError();
    }
  }

  void fillSubjects() {
    if (!hasSections(Storage.getPreference("year"))) {
      Storage.setPreference<String>("section", defaultValues["section"]);
    }
    if (!hasVariants(Storage.getPreference("year")) || getVariants(Storage.getPreference("year"))[Storage.getPreference("variant")] == null) {
      Storage.setPreference<String>("variant", defaultValues["variant"]);
    }

    if (Storage.getPreference("school_system") == "lux") {
      ExcelParser.fillSubjects();
    }

    Manager.years.clear();
    Manager.years.add(Year());

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
                      I18n.of(context).setup,
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
                  title: I18n.of(context).school_system,
                  leading: Icon(
                    Icons.school,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  settingKey: 'school_system',
                  onChange: (var value) {
                    rebuild();
                  },
                  values: <String, String>{
                    "lux": I18n.of(context).lux_system,
                    "other": I18n.of(context).other_system,
                  },
                ),
                Storage.getPreference("school_system") == "lux"
                    ? SettingsGroup(
                        title: I18n.of(context).lux_system,
                        children: [
                          RadioModalSettingsTile<String>(
                            title: I18n.of(context).system,
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
                              "classic": I18n.of(context).classic,
                              "general": "General (coming soon)",
                              //"general": I18n.of(context).general,
                            },
                          ),
                          Storage.existsPreference("lux_system") && Storage.getPreference("lux_system") == "classic"
                              ? RadioModalSettingsTile<String>(
                                  title: I18n.of(context).year,
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
                                  title: I18n.of(context).section,
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
                                  title: I18n.of(context).variant,
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
                            title: I18n.of(context).other_system,
                            children: [
                              SimpleSettingsTile(
                                leading: Icon(
                                  Icons.school,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                onTap: () {
                                  Navigator.pushNamed(context, "subject_edit");
                                },
                                title: I18n.of(context).add_subjects,
                                subtitle: I18n.of(context).edit_subjects_summary,
                              ),
                              RadioModalSettingsTile<int>(
                                title: I18n.of(context).term,
                                leading: Icon(
                                  Icons.access_time_outlined,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                settingKey: 'term',
                                onChange: (var value) {
                                  Manager.readPreferences();
                                },
                                values: <int, String>{
                                  3: I18n.of(context).trimesters,
                                  2: I18n.of(context).semesters,
                                  1: I18n.of(context).year,
                                },
                                selected: defaultValues["term"],
                              ),
                              TextInputSettingsTile(
                                title: I18n.of(context).rating_system,
                                settingKey: 'total_grades_text',
                                initialValue: defaultValues["total_grades"].toString(),
                                leading: Icon(
                                  Icons.book,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                keyboardType: TextInputType.number,
                                onChange: (text) {
                                  double d = double.parse(text);
                                  Storage.setPreference<double>("total_grades", d);
                                  Manager.totalGrades = d;
                                },
                                validator: (String? input) {
                                  if (input != null && double.tryParse(input) != null) {
                                    return null;
                                  }
                                  return I18n.of(context).enter_valid_number;
                                },
                              ),
                              RadioModalSettingsTile<String>(
                                title: I18n.of(context).rounding_mode,
                                leading: Icon(
                                  Icons.arrow_upward,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                settingKey: 'rounding_mode',
                                values: <String, String>{
                                  "rounding_up": I18n.of(context).up,
                                  "rounding_down": I18n.of(context).down,
                                  "rounding_half_up": I18n.of(context).half_up,
                                  "rounding_half_down": I18n.of(context).half_down,
                                },
                                selected: defaultValues["rounding_mode"],
                              ),
                              RadioModalSettingsTile<int>(
                                title: I18n.of(context).round_to,
                                leading: Icon(
                                  Icons.cut,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                settingKey: 'round_to',
                                values: <int, String>{
                                  1: I18n.of(context).to_integer,
                                  10: I18n.of(context).to_10th,
                                  100: I18n.of(context).to_100th,
                                },
                                selected: defaultValues["round_to"],
                              ),
                            ],
                          )
                        : Container(),
                SimpleSettingsTile(
                  title: I18n.of(context).note,
                  subtitle: I18n.of(context).note_text,
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
