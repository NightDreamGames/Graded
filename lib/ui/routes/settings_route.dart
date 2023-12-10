// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:package_info_plus/package_info_plus.dart";
import "package:provider/provider.dart";

// Project imports:
import "package:graded/calculations/manager.dart";
import "package:graded/localization/translations.dart";
import "package:graded/main.dart";
import "package:graded/misc/default_values.dart";
import "package:graded/misc/enums.dart";
import "package:graded/misc/locale_provider.dart";
import "package:graded/misc/storage.dart";
import "package:graded/ui/settings/flutter_settings_screens.dart";
import "package:graded/ui/utilities/app_theme.dart";
import "package:graded/ui/utilities/custom_icons.dart";
import "package:graded/ui/utilities/misc_utilities.dart";
import "package:graded/ui/widgets/better_app_bar.dart";
import "package:graded/ui/widgets/bottom_sheets.dart";
import "package:graded/ui/widgets/dialogs.dart";
import "package:graded/ui/widgets/misc_widgets.dart";
import "package:graded/ui/widgets/settings_tiles.dart";

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void rebuild() {
    setState(() {});
  }

  void rebuildYearOverview() {
    getCurrentYear().yearOverview = createYearOverview(year: getCurrentYear());
    rebuildHomePage();
  }

  void rebuildHomePage() {
    mainRouteKey.currentState?.rebuild();
  }

  void rebuildAppContainer() {
    appContainerKey.currentState?.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        primary: true,
        slivers: [
          BetterSliverAppBar.large(
            title: AppBarTitle(
              title: translations.settings,
            ),
          ),
          SliverSafeArea(
            top: false,
            sliver: SliverToBoxAdapter(
              child: SettingsContainer(
                children: [
                  SettingsGroup(
                    title: translations.general,
                    children: [
                      SimpleSettingsTile(
                        icon: Icons.calendar_month_outlined,
                        onTap: () => Navigator.pushNamed(context, "/years").then((value) => rebuildYearOverview()),
                        title: translations.manage_years,
                        subtitle: translations.manage_years_description,
                      ),
                      ...getSettingsTiles(context, type: CreationType.edit, onChanged: rebuildYearOverview),
                      SimpleSettingsTile(
                        icon: Icons.clear_all,
                        title: translations.reset,
                        onTap: () => showResetConfirmDialog(context),
                      ),
                    ],
                  ),
                  SettingsGroup(
                    title: "${translations.import_}/${translations.export_}",
                    children: [
                      SimpleSettingsTile(
                        icon: Icons.file_upload_outlined,
                        title: translations.export_,
                        subtitle: translations.export_description,
                        onTap: () => exportData(),
                      ),
                      ImportSettingsTile(
                        onChanged: () {
                          rebuildYearOverview();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  SettingsGroup(
                    title: translations.appearance,
                    children: [
                      RadioModalSettingsTile<String>(
                        title: translations.theme,
                        icon: Icons.dark_mode,
                        settingKey: "theme",
                        values: <String, String>{
                          "system": translations.system,
                          "light": translations.theme_light,
                          "dark": translations.theme_dark,
                        },
                        selected: DefaultValues.theme,
                        onChange: (_) => rebuildAppContainer(),
                      ),
                      SimpleSettingsTile(
                        icon: Icons.color_lens_outlined,
                        title: translations.colorOther,
                        subtitle: translations.edit_color_scheme,
                        onTap: () {
                          if (!AppTheme.hasDynamicColor) {
                            setPreference("dynamic_color", false);
                          }

                          showColorBottomSheet(context, rebuildAppContainer);
                        },
                      ),
                      RadioModalSettingsTile<String>(
                        title: translations.font,
                        icon: Icons.font_download_outlined,
                        settingKey: "font",
                        values: <String, String>{
                          "montserrat": "Montserrat",
                          "noto": "Noto Sans",
                          "system": translations.system,
                        },
                        selected: DefaultValues.font,
                        onChange: (_) => rebuildAppContainer(),
                      ),
                      RadioModalSettingsTile<String>(
                        title: translations.language,
                        icon: Icons.language,
                        settingKey: "language",
                        values: <String, String>{
                          "system": translations.system,
                          "en": translations.english,
                          "de": translations.german,
                          "fr": translations.french,
                          "lb": translations.luxembourgish,
                          "nl": translations.dutch,
                        },
                        selected: DefaultValues.language,
                        onChange: (value) {
                          if (value != DefaultValues.language) {
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
                      FutureBuilder(
                        builder: (context, snapshot) {
                          return SimpleSettingsTile(
                            icon: CustomIcons.graded,
                            title: translations.app_version,
                            subtitle: snapshot.data ?? translations.error,
                            onTap: () => launchURL(Link.store),
                          );
                        },
                        future: PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
                          return "${packageInfo.version} (${packageInfo.buildNumber})";
                        }),
                      ),
                      SimpleSettingsTile(
                        icon: Icons.translate,
                        title: translations.help_translate,
                        subtitle: translations.help_translate_description,
                        onTap: () => launchURL(Link.translate),
                      ),
                      SimpleSettingsTile(
                        icon: Icons.bug_report_outlined,
                        title: translations.issue_tracker,
                        subtitle: translations.issue_tracker_description,
                        onTap: () => launchURL(Link.issueTracker),
                      ),
                      SimpleSettingsTile(
                        icon: CustomIcons.github,
                        title: translations.source_code,
                        subtitle: translations.source_code_description,
                        onTap: () => launchURL(Link.github),
                      ),
                    ],
                  ),
                  SettingsGroup(
                    title: translations.credits,
                    children: [
                      SimpleSettingsTile(
                        icon: Icons.emoji_people,
                        title: translations.nightdream_games,
                        subtitle: translations.credits_description,
                        onTap: () => launchURL(Link.website),
                      ),
                      SimpleSettingsTile(
                        icon: Icons.feedback_outlined,
                        title: translations.contact_me,
                        subtitle: translations.email,
                        onTap: () => launchURL(Link.email),
                      ),
                      SimpleSettingsTile(
                        icon: Icons.star_border_outlined,
                        title: translations.follow_nightdream_games,
                        onTap: () => showSocialsBottomSheet(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }
}
