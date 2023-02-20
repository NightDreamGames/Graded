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
    SetupManager.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: () {
        if ((getPreference<int>("year") != -1 && (!SetupManager.hasSections() || getPreference<String>("section").isNotEmpty)) ||
            getPreference<String>("school_system") == "other") {
          return FloatingActionButton(
            onPressed: () async {
              await SetupManager.completeSetup();

              // ignore: use_build_context_synchronously
              if (!context.mounted) return;
              if (widget.dismissible) {
                Navigator.popUntil(context, ModalRoute.withName("/"));
              } else {
                Navigator.pushReplacementNamed(context, "/");
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
          SliverSafeArea(
            top: false,
            bottom: false,
            sliver: SliverToBoxAdapter(
              child: SettingsContainer(
                children: [
                  SimpleSettingsTile(
                    icon: Icons.file_download_outlined,
                    title: Translations.import_string,
                    subtitle: Translations.import_details,
                    onTap: () => importData(context).then((value) {
                      if (value) {
                        setPreference<bool>("is_first_run", false);

                        // ignore: use_build_context_synchronously
                        if (!context.mounted) return;
                        if (widget.dismissible) {
                          Navigator.popUntil(context, ModalRoute.withName("/"));
                        } else {
                          Navigator.pushReplacementNamed(context, "/");
                        }
                      }
                    }),
                  ),
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
                  if (getPreference<String>("school_system") == "lux")
                    SettingsGroup(
                      title: Translations.lux_system,
                      children: [
                        RadioModalSettingsTile<String>(
                          title: Translations.system,
                          icon: Icons.build,
                          settingKey: 'lux_system',
                          onChange: (_) {
                            setPreference<int>("year", defaultValues["year"]);
                            setPreference<String>("section", defaultValues["section"]);
                            setPreference<String>("variant", defaultValues["variant"]);
                            rebuild();
                          },
                          values: <String, String>{
                            "classic": Translations.classic,
                            "general": Translations.general,
                          },
                        ),
                        if (getPreference<String>("lux_system").isNotEmpty)
                          RadioModalSettingsTile<int>(
                            title: Translations.year,
                            icon: Icons.timelapse,
                            settingKey: 'year',
                            onChange: (_) {
                              if (SetupManager.hasSections()) {
                                setPreference<String>("section", defaultValues["section"]);
                              }
                              if (SetupManager.getVariants()[getPreference<String>("variant")] == null) {
                                setPreference<String>("variant", defaultValues["variant"]);
                              }
                              rebuild();
                            },
                            values: SetupManager.getYears(),
                            selected: -1,
                          ),
                        if (SetupManager.hasSections())
                          RadioModalSettingsTile<String>(
                            title: Translations.section,
                            icon: Icons.fork_right,
                            settingKey: 'section',
                            onChange: (_) => rebuild(),
                            values: SetupManager.getSections(),
                          ),
                        if (SetupManager.hasVariants())
                          RadioModalSettingsTile<String>(
                            title: Translations.variant,
                            icon: Icons.edit,
                            settingKey: 'variant',
                            selected: defaultValues["variant"],
                            onChange: (_) => rebuild(),
                            values: SetupManager.getVariants(),
                          ),
                        if (getPreference<int>("year") != -1 && getPreference<int>("year") != 1)
                          RadioModalSettingsTile<int>(
                            title: Translations.term,
                            icon: Icons.access_time_outlined,
                            settingKey: 'term',
                            onChange: (_) => Compatibility.termCount(),
                            values: <int, String>{
                              3: Translations.trimesters,
                              2: Translations.semesters,
                            },
                            selected: defaultValues["term"],
                          ),
                      ],
                    )
                  else if (getPreference<String>("school_system") == "other")
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
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 88)),
        ],
      ),
    );
  }
}
