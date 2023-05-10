// Flutter imports:
import "package:flutter/material.dart";

// Project imports:
import "package:graded/localization/translations.dart";
import "package:graded/misc/compatibility.dart";
import "package:graded/misc/default_values.dart";
import "package:graded/misc/enums.dart";
import "package:graded/misc/setup_manager.dart";
import "package:graded/misc/storage.dart";
import "package:graded/ui/settings/flutter_settings_screens.dart";
import "package:graded/ui/widgets/misc_widgets.dart";
import "package:graded/ui/widgets/settings_tiles.dart";

class SetupPage extends StatefulWidget {
  const SetupPage({super.key, this.dismissible = true});

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
              title: translations.setup,
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
                  if (!widget.dismissible)
                    SimpleSettingsTile(
                      icon: Icons.file_download_outlined,
                      title: translations.import_string,
                      subtitle: translations.import_details,
                      onTap: () => importData(context).then((value) {
                        if (value) {
                          setPreference<bool>("is_first_run", false);

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
                    title: translations.school_system,
                    icon: Icons.school,
                    settingKey: "school_system",
                    onChange: (_) => rebuild(),
                    values: <String, String>{
                      "lux": translations.lux_system,
                      "other": translations.other_school_system,
                    },
                  ),
                  if (getPreference<String>("school_system") == "lux")
                    SettingsGroup(
                      title: translations.lux_system,
                      children: [
                        RadioModalSettingsTile<String>(
                          title: translations.system,
                          icon: Icons.build,
                          settingKey: "lux_system",
                          onChange: (_) {
                            setPreference<int>("year", defaultValues["year"] as int);
                            setPreference<String>("section", defaultValues["section"] as String);
                            setPreference<String>("variant", defaultValues["variant"] as String);
                            rebuild();
                          },
                          values: <String, String>{
                            "classic": translations.classic,
                            "general": translations.general,
                          },
                        ),
                        if (getPreference<String>("lux_system").isNotEmpty)
                          RadioModalSettingsTile<int>(
                            title: translations.year,
                            icon: Icons.timelapse,
                            settingKey: "year",
                            onChange: (_) {
                              if (SetupManager.hasSections()) {
                                setPreference<String>("section", defaultValues["section"] as String);
                              }
                              if (SetupManager.getVariants()[getPreference<String>("variant")] == null) {
                                setPreference<String>("variant", defaultValues["variant"] as String);
                              }
                              rebuild();
                            },
                            values: SetupManager.getYears(),
                            selected: -1,
                          ),
                        if (SetupManager.hasSections())
                          RadioModalSettingsTile<String>(
                            title: translations.section,
                            icon: Icons.fork_right,
                            settingKey: "section",
                            onChange: (_) => rebuild(),
                            values: SetupManager.getSections(),
                          ),
                        if (SetupManager.hasVariants())
                          RadioModalSettingsTile<String>(
                            title: translations.variant,
                            icon: Icons.edit,
                            settingKey: "variant",
                            selected: defaultValues["variant"] as String,
                            onChange: (_) => rebuild(),
                            values: SetupManager.getVariants(),
                          ),
                        if (getPreference<int>("year") != -1 && getPreference<int>("year") != 1)
                          RadioModalSettingsTile<int>(
                            title: translations.school_term,
                            icon: Icons.access_time_outlined,
                            settingKey: "term",
                            onChange: (_) => Compatibility.termCount(),
                            values: <int, String>{
                              3: translations.trimesters,
                              2: translations.semesters,
                            },
                            selected: defaultValues["term"] as int,
                          ),
                      ],
                    )
                  else if (getPreference<String>("school_system") == "other")
                    SettingsGroup(
                      title: translations.other_school_system,
                      children: getSettingsTiles(context, CreationType.add),
                    ),
                  SimpleSettingsTile(
                    title: translations.note,
                    subtitle: translations.note_text,
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
