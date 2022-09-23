import 'dart:developer';
import 'dart:ffi';

import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:gradely/Misc/excel_parser.dart';
import 'package:gradely/Misc/storage.dart';
import 'package:gradely/custom_icons_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../Calculations/manager.dart';
import '../Translation/i18n.dart';
import 'package:customizable_space_bar/customizable_space_bar.dart';
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
    if (className == "na") return false;

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

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      primary: true,
      slivers: [
        SliverAppBar(
          floating: false,
          pinned: true,
          expandedHeight: 150,
          flexibleSpace: CustomizableSpaceBar(
            builder: (context, scrollingRate) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12, left: 24 + 40 * scrollingRate),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    I18n.of(context).settings,
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
                selected: null /*defaultValues["system"]*/,
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
                            rebuild();
                          },
                          values: <String, String>{
                            "classic": I18n.of(context).classic,
                            "general": I18n.of(context).general,
                          },
                        ),
                        Storage.existsPreference("lux_system")
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
                        hasVariant(Storage.getPreference<String?>("class", defaultValues["class"]))
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
                                values: getVariants(Storage.getPreference("class", defaultValues["class"])),
                              )
                            : Container(),
                      ],
                    )
                  : Storage.getPreference("school_system", null) == "other"
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
              SettingsGroup(
                title: "",
                children: [
                  SimpleSettingsTile(
                    title: I18n.of(context).note,
                    subtitle: I18n.of(context).note_text,
                    enabled: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void _launchURL(int type) async {
  switch (type) {
    case 0:
      if (!await launchUrlString(
          "mailto:contact.nightdreamgames@gmail.com?subject=Grade.ly%20feedback&body=Thank%20you%20you%20for%20your%20feedback")) {
        throw 'Could not launch email app';
      }
      break;
    case 1:
      if (!await launchUrlString("https://github.com/NightDreamGames/Grade.ly")) {
        throw 'Could not open link';
      }
      break;
    case 2:
      if (!await launchUrlString("https://play.google.com/store/apps/details?id=com.NightDreamGames.Grade.ly")) {
        throw 'Could not open link';
      }
      break;
  }
}
