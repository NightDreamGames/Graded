// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:flex_color_picker/flex_color_picker.dart";
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
import "package:graded/ui/widgets/dialogs.dart";
import "package:graded/ui/widgets/misc_widgets.dart";
import "package:graded/ui/widgets/settings_tiles.dart";

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

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
                          showModalBottomSheet(
                            context: context,
                            showDragHandle: true,
                            builder: (context) {
                              return ColorBottomSheet(onChanged: rebuildAppContainer);
                            },
                          );
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
                      SimpleSettingsTile(
                        icon: CustomIcons.graded,
                        title: translations.app_name,
                        subtitle: translations.about_description,
                        onTap: () => launchURL(Link.website),
                      ),
                      FutureBuilder(
                        builder: (context, snapshot) {
                          return SimpleSettingsTile(
                            icon: Icons.info_outline,
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
                        icon: CustomIcons.github,
                        title: translations.source_code,
                        subtitle: translations.source_code_description,
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
      ),
    );
  }
}

class ColorBottomSheet extends StatelessWidget {
  ColorBottomSheet({
    super.key,
    this.onChanged,
  }) {
    if (!AppTheme.hasDynamicColor) {
      setPreference("dynamic_color", false);
    }
  }

  final void Function()? onChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.color_lens_outlined,
                  size: 24,
                ),
                const Padding(padding: EdgeInsets.only(top: 8, bottom: 8)),
                Text(
                  translations.colorOther,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Padding(padding: EdgeInsets.only(bottom: 8)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SettingsContainer(
              children: [
                SwitchSettingsTile(
                  title: translations.dynamic_color,
                  settingKey: "dynamic_color",
                  subtitle: !AppTheme.hasDynamicColor ? translations.no_dynamic_color : "",
                  defaultValue: AppTheme.hasDynamicColor,
                  enabled: AppTheme.hasDynamicColor,
                  onChange: (_) => onChanged?.call(),
                ),
                SimpleSettingsTile(
                  title: translations.custom_color,
                  subtitle: translations.edit_primary_color,
                  enabled: !AppTheme.hasDynamicColor || !getPreference<bool>("dynamic_color"),
                  trailing: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(getPreference<int>("custom_color")),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    Color selectedColor = Color(getPreference<int>("custom_color"));

                    ColorPicker(
                      color: selectedColor,
                      showColorCode: true,
                      heading: Text(
                        translations.select_color,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      colorCodeHasColor: true,
                      enableShadesSelection: false,
                      selectedPickerTypeColor: Theme.of(context).colorScheme.primary,
                      enableTonalPalette: true,
                      wheelHasBorder: true,
                      tonalSubheading: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(translations.material_3_shades),
                      ),
                      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                        copyFormat: ColorPickerCopyFormat.numHexRRGGBB,
                      ),
                      spacing: 8,
                      runSpacing: 8,
                      columnSpacing: 16,
                      wheelSquareBorderRadius: 16,
                      borderRadius: 16,
                      colorCodePrefixStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
                      pickersEnabled: const <ColorPickerType, bool>{
                        ColorPickerType.primary: true,
                        ColorPickerType.wheel: true,
                        ColorPickerType.accent: false,
                      },
                      pickerTypeLabels: <ColorPickerType, String>{
                        ColorPickerType.primary: translations.preset,
                        ColorPickerType.wheel: translations.custom,
                      },
                      onColorChanged: (Color value) {
                        selectedColor = value;
                      },
                    )
                        .showPickerDialog(
                      context,
                    )
                        .then((_) {
                      setPreference<int>("custom_color", selectedColor.value);
                      onChanged?.call();
                    });
                  },
                ),
                SwitchSettingsTile(
                  title: translations.amoled_mode,
                  settingKey: "amoled",
                  // ignore: avoid_redundant_argument_values
                  defaultValue: false,
                  onChange: (_) => onChanged?.call(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
