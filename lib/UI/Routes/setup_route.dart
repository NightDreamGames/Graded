// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../Misc/compatibility.dart';
import '../../Misc/setup_manager.dart';
import '../../Misc/storage.dart';
import '../../Translations/translations.dart';
import '../Widgets/misc_widgets.dart';
import '../Widgets/settings_tiles.dart';
import '/UI/Settings/flutter_settings_screens.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({Key? key, this.dismissible = true}) : super(key: key);

  final bool dismissible;

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  void rebuild() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    //TODO Change when Flutter updates
    //compute(SetupManager.readFiles, null);
    SetupManager.readFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: () {
        if ((Storage.getPreference("lux_system") == "classic" &&
                Storage.getPreference<String>("year").isNotEmpty &&
                (!SetupManager.hasSections(Storage.getPreference("year")) || Storage.getPreference<String>("section").isNotEmpty)) ||
            Storage.getPreference("school_system") == "other") {
          return FloatingActionButton(
            onPressed: () async {
              await SetupManager.completeSetup();

              if (widget.dismissible) {
                Navigator.popUntil(context, ModalRoute.withName("/home"));
              } else {
                Navigator.pushReplacementNamed(context, "/home");
              }
            },
            child: const Icon(Icons.navigate_next),
          );
        }
      }(),
      body: CustomScrollView(
        primary: true,
        slivers: [
          SliverAppBar.large(
            title: AppBarTitle(
              title: Translations.setup,
              actionAmount: 0,
            ),
            automaticallyImplyLeading: widget.dismissible,
          ),
          SliverToBoxAdapter(
            child: SettingsContainer(
              children: [
                RadioModalSettingsTile<String>(
                  title: Translations.school_system,
                  icon: Icons.school,
                  settingKey: 'school_system',
                  onChange: (_) => rebuild(),
                  values: <String, String>{
                    "lux": Translations.lux_system,
                    "other": Translations.other_system,
                  },
                ),
                if (Storage.getPreference("school_system") == "lux")
                  SettingsGroup(
                    title: Translations.lux_system,
                    children: [
                      RadioModalSettingsTile<String>(
                        title: Translations.system,
                        icon: Icons.build,
                        settingKey: 'lux_system',
                        onChange: (_) {
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
                      if (Storage.getPreference("lux_system") == "classic") ...[
                        RadioModalSettingsTile<String>(
                          title: Translations.year,
                          icon: Icons.timelapse,
                          settingKey: 'year',
                          onChange: (_) {
                            if (SetupManager.hasSections(Storage.getPreference("year"))) {
                              Storage.setPreference<String>("section", defaultValues["section"]);
                            }
                            if (SetupManager.getVariants(Storage.getPreference("year"))[Storage.getPreference("variant")] == null) {
                              Storage.setPreference<String>("variant", defaultValues["variant"]);
                            }
                            rebuild();
                          },
                          values: SetupManager.getYears,
                        ),
                        if (SetupManager.hasSections(Storage.getPreference("year")))
                          RadioModalSettingsTile<String>(
                            title: Translations.section,
                            icon: Icons.fork_right,
                            settingKey: 'section',
                            onChange: (_) => rebuild(),
                            values: SetupManager.getSections(),
                          ),
                        if (SetupManager.hasVariants(Storage.getPreference("year")))
                          RadioModalSettingsTile<String>(
                            title: Translations.variant,
                            icon: Icons.edit,
                            settingKey: 'variant',
                            selected: defaultValues["variant"],
                            values: SetupManager.getVariants(Storage.getPreference("year")),
                          ),
                        if (Storage.getPreference("year") != "" && Storage.getPreference("year") != "1C")
                          RadioModalSettingsTile<int>(
                            title: Translations.term,
                            icon: Icons.access_time_outlined,
                            settingKey: 'term',
                            onChange: (_) => Compatibility.termCount(),
                            values: <int, String>{
                              3: Translations.trimesters,
                              2: Translations.semesters,
                              1: Translations.year,
                            },
                            selected: defaultValues["term"],
                          ),
                      ] else if (Storage.getPreference("lux_system") == "general") ...[
                        SimpleSettingsTile(
                          title: Translations.coming_soon,
                          subtitle: Translations.general_note,
                          icon: Icons.construction,
                          enabled: false,
                        ),
                      ]
                    ],
                  )
                else if (Storage.getPreference("school_system") == "other")
                  SettingsGroup(
                    title: Translations.other_system,
                    children: getSettingsTiles(context, true),
                  ),
                SimpleSettingsTile(
                  title: Translations.note,
                  subtitle: Translations.note_text,
                  icon: Icons.info_outline,
                  enabled: false,
                ),
              ],
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 88)),
        ],
      ),
    );
  }
}
