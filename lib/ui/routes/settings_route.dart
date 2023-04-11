// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

// Project imports:
import '../../calculations/manager.dart';
import '../../localization/translations.dart';
import '../../main.dart';
import '../../misc/locale_provider.dart';
import '../../misc/storage.dart';
import '../utilities/custom_icons.dart';
import '../utilities/misc_utilities.dart';
import '../widgets/dialogs.dart';
import '../widgets/misc_widgets.dart';
import '../widgets/settings_tiles.dart';
import '/ui/settings/flutter_settings_screens.dart';

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
        SliverAppBar.large(
          title: AppBarTitle(
            title: translations.settings,
            actionAmount: 0,
          ),
        ),
        SliverSafeArea(
          top: false,
          bottom: false,
          sliver: SliverToBoxAdapter(
            child: SettingsContainer(
              children: [
                SettingsGroup(
                  title: translations.general,
                  children: [
                    SimpleSettingsTile(
                      icon: Icons.class_,
                      onTap: () => Navigator.pushNamed(context, "/setup"),
                      title: translations.change_class,
                      subtitle: translations.change_class_summary,
                    ),
                    ...getSettingsTiles(context, false),
                    SimpleSettingsTile(
                      icon: Icons.clear_all,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return EasyDialog(
                              title: translations.confirm,
                              icon: Icons.clear_all,
                              action: translations.confirm,
                              onConfirm: () {
                                Manager.clear();
                                Navigator.pop(context);
                                return true;
                              },
                              child: Text(translations.confirm_delete),
                            );
                          },
                        );
                      },
                      title: translations.reset,
                    ),
                  ],
                ),
                SettingsGroup(
                  title: "${translations.import_string}/${translations.export_string}",
                  children: [
                    SimpleSettingsTile(
                      icon: Icons.file_upload_outlined,
                      title: translations.export_string,
                      subtitle: translations.export_details,
                      onTap: () => exportData(),
                    ),
                    SimpleSettingsTile(
                      icon: Icons.file_download_outlined,
                      title: translations.import_string,
                      subtitle: translations.import_details,
                      onTap: () => importData(context).then((value) {
                        if (value) Navigator.pop(context);
                      }),
                    ),
                  ],
                ),
                SettingsGroup(
                  title: translations.appearance,
                  children: [
                    RadioModalSettingsTile<String>(
                      title: translations.theme,
                      icon: Icons.dark_mode,
                      settingKey: 'theme',
                      values: <String, String>{
                        "system": translations.theme_system,
                        "light": translations.theme_light,
                        "dark": translations.theme_dark,
                      },
                      selected: defaultValues["theme"],
                      onChange: (_) => appContainerKey.currentState?.setState(() {}),
                    ),
                    RadioModalSettingsTile<String>(
                      title: translations.language,
                      icon: Icons.language,
                      settingKey: 'language',
                      values: <String, String>{
                        "system": translations.system_language,
                        "en": translations.english,
                        "de": translations.german,
                        "fr": translations.french,
                        "es": translations.spanish,
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
                  title: translations.about,
                  children: [
                    SimpleSettingsTile(
                      icon: CustomIcons.graded,
                      title: translations.app_name,
                      subtitle: translations.about_text,
                      onTap: () => launchURL(Link.website),
                    ),
                    FutureBuilder(
                      builder: (context, snapshot) {
                        return SimpleSettingsTile(
                          icon: Icons.info_outline,
                          title: translations.app_version,
                          subtitle: snapshot.data as String? ?? "2.0.0",
                          onTap: () => launchURL(Link.store),
                        );
                      },
                      future: PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
                        return packageInfo.version;
                      }),
                    ),
                    SimpleSettingsTile(
                      icon: CustomIcons.github,
                      title: translations.github,
                      subtitle: translations.github_summary,
                      onTap: () => launchURL(Link.github),
                    ),
                    SimpleSettingsTile(
                      icon: Icons.feedback_outlined,
                      title: translations.send_feedback,
                      subtitle: translations.email,
                      onTap: () => launchURL(Link.email),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
      ],
    );
  }
}
