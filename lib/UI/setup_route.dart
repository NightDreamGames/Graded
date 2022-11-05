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

  bool hasVariant(String? className) {
    if (className == "na" || className == null) return false;

    return className != "7C";
  }

  Map<String, String> getVariants(String className) {
    Map<String, String> result = <String, String>{};
    if (className.startsWith("1C")) {
      result["basic"] = I18n.of(context).basic;
      result["latin"] = I18n.of(context).latin;
    } else {
      result["basic"] = I18n.of(context).basic;
      result["latin"] = I18n.of(context).latin;
      result["chinese"] = I18n.of(context).chinese;
    }

    return result;
  }

  static void fillSubjects() {
    if (Storage.getPreference("school_system", defaultValues["school_system"]) == "lux") {
      ExcelParser.fillSubjects();
    }

    Manager.years.clear();
    Manager.years.add(Year());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: (Storage.getPreference("class", defaultValues["class"]) != "na" &&
                  Storage.getPreference("lux_system", defaultValues["lux_system"]) != "general") ||
              Storage.getPreference("school_system", defaultValues["school_system"]) == "other"
          ? FloatingActionButton(
              onPressed: () {
                fillSubjects();

                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).popUntil(ModalRoute.withName("/home"));
                } else {
                  Navigator.of(context).pushReplacementNamed("/home");
                }
              },
              child: const Icon(Icons.add),
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
                Storage.getPreference("school_system", defaultValues["school_system"]) == "lux"
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
                              Storage.setPreference("class", defaultValues["class"]);
                              rebuild();
                            },
                            values: <String, String>{
                              "classic": I18n.of(context).classic,
                              "general": "General (coming soon)",
                              //"general": I18n.of(context).general,
                            },
                          ),
                          Storage.existsPreference("lux_system") && Storage.getPreference("lux_system", defaultValues["lux_system"]) != "general"
                              ? FutureBuilder(
                                  initialData: const <String, String>{},
                                  future: ExcelParser.getClassNames(Storage.getPreference("lux_system", defaultValues["lux_system"])),
                                  builder: (context, snapshot) {
                                    return RadioModalSettingsTile<String>(
                                      title: I18n.of(context).class_string,
                                      leading: Icon(
                                        Icons.book,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                      settingKey: 'class',
                                      onChange: (var value) {
                                        rebuild();
                                      },
                                      values: snapshot.data as Map<String, String>,
                                    );
                                  },
                                )
                              : Container(),
                          hasVariant(Storage.getPreference<String?>("class", defaultValues["class"])) &&
                                  Storage.getPreference("lux_system", defaultValues["lux_system"]) != "general"
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
                                  values: getVariants(Storage.getPreference("class", defaultValues["class"])),
                                )
                              : Container(),
                        ],
                      )
                    : Storage.getPreference("school_system", defaultValues["school_system"]) == "other"
                        ? SettingsGroup(
                            title: I18n.of(context).other_system,
                            children: [
                              SimpleSettingsTile(
                                leading: Icon(
                                  Icons.school,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType.rightToLeft,
                                      child: const SubjectEditRoute(),
                                    ),
                                  );
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
