import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
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

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

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
              SettingsGroup(
                title: I18n.of(context).general,
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
                    title: I18n.of(context).edit_subjects,
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
                  SimpleSettingsTile(
                    leading: Icon(
                      Icons.clear_all,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    onTap: () {
                      Manager.clear();
                    },
                    title: I18n.of(context).reset,
                  ),
                ],
              ),
              //TODO Language selector
              /*SettingsGroup(
                title: I18n.of(context).appearance,
                children: [
                  RadioModalSettingsTile<String>(
                    title: I18n.of(context).dark_theme,
                    leading: Icon(
                      Icons.dark_mode,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    settingKey: 'dark_theme',
                    values: <String, String>{
                      "auto": I18n.of(context).light_mode_auto,
                      "on": I18n.of(context).light_mode_on,
                      "off": I18n.of(context).light_mode_off,
                    },
                    selected: defaultValues["dark_theme"],
                    onChange: (value) {
                      print(value);
                      EasyDynamicTheme.of(context).changeTheme(
                        dark: value == "on",
                        dynamic: value == "auto",
                      );
                    },
                  ),
                  /*RadioModalSettingsTile<String>(
                    title: I18n.of(context).language,
                    leading: const Icon(Icons.language),
                    settingKey: 'language',
                    values: <String, String>{
                      "default": I18n.of(context).default_string,
                      "en": I18n.of(context).english,
                      "de": I18n.of(context).german,
                      "fr": I18n.of(context).french,
                      "lu": I18n.of(context).luxemburgish,
                    },
                    selected: defaultValues["language"],
                  ),*/
                ],
              ),*/

              SettingsGroup(
                title: I18n.of(context).about,
                children: [
                  SimpleSettingsTile(
                    leading: Icon(
                      CustomIcons.gradely,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    title: I18n.of(context).app_name,
                    subtitle: I18n.of(context).about_text,
                    onTap: () {
                      _launchURL(2);
                    },
                  ),
                  FutureBuilder(
                    builder: (context, snapshot) {
                      return SimpleSettingsTile(
                        leading: Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        title: I18n.of(context).app_version,
                        subtitle: snapshot.data as String,
                        onTap: () {
                          _launchURL(2);
                        },
                      );
                    },
                    future: PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
                      return packageInfo.version;
                    }),
                  ),
                  SimpleSettingsTile(
                    leading: Icon(
                      CustomIcons.github,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    title: I18n.of(context).github,
                    subtitle: I18n.of(context).github_summary,
                    onTap: () {
                      _launchURL(1);
                    },
                  ),
                  SimpleSettingsTile(
                    leading: Icon(
                      Icons.feedback_outlined,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    title: I18n.of(context).contact,
                    subtitle: I18n.of(context).email,
                    onTap: () {
                      _launchURL(0);
                    },
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
