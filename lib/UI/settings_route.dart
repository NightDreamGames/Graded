// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:customizable_space_bar/customizable_space_bar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:gradely/Misc/storage.dart';
import 'package:gradely/UI/custom_icons.dart';
import 'package:gradely/UI/easy_dialog.dart';
import 'package:gradely/main.dart';
import '../Calculations/manager.dart';
import '../Translation/translations.dart';
import '/UI/Settings/flutter_settings_screens.dart';

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
                    Translations.settings,
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
                title: Translations.general,
                children: [
                  SimpleSettingsTile(
                    leading: Icon(
                      Icons.class_,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, "/setup");
                    },
                    title: Translations.change_class,
                    subtitle: Translations.change_class_summary,
                  ),
                  SimpleSettingsTile(
                    leading: Icon(
                      Icons.subject,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, "/subject_edit");
                    },
                    title: Translations.edit_subjects,
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
                    subtitle: Storage.getPreference("total_grades").toString(),
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
                      Manager.calculate();
                    },
                    validator: (String? input) {
                      if (input != null && double.tryParse(input) != null) {
                        return null;
                      }
                      return Translations.enter_valid_number;
                    },
                  ),
                  RadioModalSettingsTile<String>(
                    title: Translations.rounding_mode,
                    leading: Icon(
                      Icons.arrow_upward,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    settingKey: 'rounding_mode',
                    onChange: (value) {
                      Manager.calculate();
                    },
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
                    onChange: (value) {
                      Manager.calculate();
                    },
                    values: <int, String>{
                      1: Translations.to_integer,
                      10: Translations.to_10th,
                      100: Translations.to_100th,
                    },
                    selected: defaultValues["round_to"],
                  ),
                  SimpleSettingsTile(
                    leading: Icon(
                      Icons.clear_all,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return EasyDialog(
                            title: Translations.confirm,
                            leading: Icon(
                              Icons.clear_all,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            onConfirm: () {
                              Manager.clear();
                              Navigator.pop(context);
                              return true;
                            },
                            child: Text(Translations.confirm_delete),
                          );
                        },
                      );
                    },
                    title: Translations.reset,
                  ),
                ],
              ),
              SettingsGroup(
                title: Translations.appearance,
                children: [
                  RadioModalSettingsTile<String>(
                    title: Translations.theme,
                    leading: Icon(
                      Icons.dark_mode,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    settingKey: 'theme',
                    values: <String, String>{
                      "system": Translations.theme_system,
                      "light": Translations.theme_light,
                      "dark": Translations.theme_dark,
                    },
                    selected: defaultValues["theme"],
                    onChange: (value) {
                      // ignore: invalid_use_of_protected_member
                      appContainerKey.currentState!.setState(() {});
                    },
                  ),
                  /*
                  //TODO Language selector
                  RadioModalSettingsTile<String>(
                    title: Translations.language,
                    leading: const Icon(Icons.language),
                    settingKey: 'language',
                    values: <String, String>{
                      "default": Translations.default_string,
                      "en": Translations.english,
                      "de": Translations.german,
                      "fr": Translations.french,
                      "lu": Translations.luxemburgish,
                    },
                    selected: defaultValues["language"],
                  ),*/
                ],
              ),
              SettingsGroup(
                title: Translations.about,
                children: [
                  SimpleSettingsTile(
                    leading: Icon(
                      CustomIcons.gradely,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    title: Translations.app_name,
                    subtitle: Translations.about_text,
                    onTap: () {
                      _launchURL(4);
                    },
                  ),
                  FutureBuilder(
                    builder: (context, snapshot) {
                      return SimpleSettingsTile(
                        leading: Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        title: Translations.app_version,
                        subtitle: snapshot.data != null ? snapshot.data as String : "",
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
                    title: Translations.github,
                    subtitle: Translations.github_summary,
                    onTap: () {
                      _launchURL(1);
                    },
                  ),
                  SimpleSettingsTile(
                    leading: Icon(
                      Icons.feedback_outlined,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    title: Translations.contact,
                    subtitle: Translations.email,
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

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries.map((MapEntry<String, String> e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
}

final Uri githubLaunchUri = Uri.parse('https://github.com/NightDreamGames/Grade.ly');
final Uri playStoreLaunchUri = Uri.https('play.google.com', '/store/apps/details', {'id': 'com.NightDreamGames.Grade.ly'});
final Uri websiteLaunchUri = Uri.parse('https://nightdreamgames.com/');
final Uri emailLaunchUri = Uri(
  scheme: 'mailto',
  path: 'contact.nightdreamgames@gmail.com',
  query: encodeQueryParameters(<String, String>{
    'subject': 'Grade.ly feedback',
    'body': 'Thank you for your feedback!',
  }),
);

void _launchURL(int type) async {
  Uri link = websiteLaunchUri;

  switch (type) {
    case 0:
      link = emailLaunchUri;
      break;
    case 1:
      link = githubLaunchUri;
      break;
    case 2:
      link = playStoreLaunchUri;
      break;
    case 3:
      link = websiteLaunchUri;
      break;
  }

  if (!await launchUrl(
    link,
    mode: LaunchMode.externalApplication,
  )) {
    throw 'Error while opening link: $link';
  }
}
