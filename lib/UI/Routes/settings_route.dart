// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:gradely/Misc/storage.dart';
import 'package:gradely/UI/Utilities/custom_icons.dart';
import 'package:gradely/UI/Widgets/dialogs.dart';
import 'package:gradely/UI/Widgets/settings_tiles.dart';
import 'package:gradely/main.dart';
import '../../Calculations/manager.dart';
import '../../Misc/locale_provider.dart';
import '../../Translations/translations.dart';
import '../Utilities/misc_utilities.dart';
import '../Widgets/misc_widgets.dart';
import '/UI/Settings/flutter_settings_screens.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void rebuild() {
    setState(() {});
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
          flexibleSpace: ScrollingTitle(title: Translations.settings),
        ),
        SliverToBoxAdapter(
          child: SettingsContainer(
            children: [
              SettingsGroup(
                title: Translations.general,
                children: [
                  SimpleSettingsTile(
                    icon: Icons.class_,
                    onTap: () {
                      Navigator.pushNamed(context, "/setup");
                    },
                    title: Translations.change_class,
                    subtitle: Translations.change_class_summary,
                  ),
                  ...getSettingsTiles(context, false),
                  SimpleSettingsTile(
                    icon: Icons.clear_all,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return EasyDialog(
                            title: Translations.confirm,
                            icon: Icons.clear_all,
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
                    icon: Icons.dark_mode,
                    settingKey: 'theme',
                    values: <String, String>{
                      "system": Translations.theme_system,
                      "light": Translations.theme_light,
                      "dark": Translations.theme_dark,
                    },
                    selected: defaultValues["theme"],
                    onChange: (value) {
                      appContainerKey.currentState!.setState(() {});
                    },
                  ),
                  RadioModalSettingsTile<String>(
                    title: Translations.language,
                    icon: Icons.language,
                    settingKey: 'language',
                    values: <String, String>{
                      "system": Translations.system_language,
                      "en": Translations.english,
                      "de": Translations.german,
                      "fr": Translations.french,
                    },
                    selected: defaultValues["language"],
                    onChange: (value) {
                      if (value != defaultValues["language"]) {
                        context.read<LocaleProvider>().setLocale(Locale(value));
                      } else {
                        context.read<LocaleProvider>().clearLocale();
                      }
                      rebuild();
                    },
                  ),
                ],
              ),
              SettingsGroup(
                title: Translations.about,
                children: [
                  SimpleSettingsTile(
                    icon: CustomIcons.gradely,
                    title: Translations.app_name,
                    subtitle: Translations.about_text,
                    onTap: () {
                      launchURL(0);
                    },
                  ),
                  FutureBuilder(
                    builder: (context, snapshot) {
                      return SimpleSettingsTile(
                        icon: Icons.info_outline,
                        title: Translations.app_version,
                        subtitle: snapshot.data != null ? snapshot.data as String : "",
                        onTap: () {
                          launchURL(1);
                        },
                      );
                    },
                    future: PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
                      return packageInfo.version;
                    }),
                  ),
                  SimpleSettingsTile(
                    icon: CustomIcons.github,
                    title: Translations.github,
                    subtitle: Translations.github_summary,
                    onTap: () {
                      launchURL(2);
                    },
                  ),
                  SimpleSettingsTile(
                    icon: Icons.feedback_outlined,
                    title: Translations.contact,
                    subtitle: Translations.email,
                    onTap: () {
                      launchURL(3);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
      ],
    );
  }
}
