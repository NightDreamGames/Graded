// Flutter imports:
import "package:flutter/material.dart";

// Project imports:
import "package:graded/localization/translations.dart";
import "package:graded/main.dart";
import "package:graded/misc/default_values.dart";
import "package:graded/misc/enums.dart";
import "package:graded/misc/setup_manager.dart";
import "package:graded/misc/storage.dart";
import "package:graded/ui/settings/flutter_settings_screens.dart";
import "package:graded/ui/widgets/better_sliver_app_bar.dart";
import "package:graded/ui/widgets/misc_widgets.dart";
import "package:graded/ui/widgets/settings_tiles.dart";

class SetupPage extends StatefulWidget {
  const SetupPage({super.key, this.dismissible = true});

  final bool dismissible;

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  bool startedAnimation = false;
  double fabScale = 1.0;
  double fabPosition = 0.0;

  void _animateIcon() {
    setState(() {
      fabScale = 0.8;
      fabPosition = 8.0;
    });

    Future.delayed(const Duration(milliseconds: 250), () {
      setState(() {
        fabScale = 1.0;
        fabPosition = 0.0;
      });
    });
  }

  void rebuild() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    SetupManager.init();
  }

  @override
  void dispose() {
    super.dispose();
    SetupManager.dispose();
  }

  void replaceRoute(BuildContext context) {
    Navigator.pushAndRemoveUntil(context, createRoute(const RouteSettings(name: "/")), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SetupManager.dispose();
        return true;
      },
      child: Scaffold(
        floatingActionButton: () {
          if ((getPreference<int>("year") != -1 && (!SetupManager.hasSections() || getPreference<String>("section").isNotEmpty)) ||
              getPreference<String>("school_system") == "other") {
            Future.delayed(const Duration(milliseconds: 500)).then((_) {
              if (startedAnimation) return;
              startedAnimation = true;
              _animateIcon();
            });

            return FloatingActionButton(
              tooltip: translations.done,
              onPressed: () async {
                await SetupManager.completeSetup();
                SetupManager.dispose();

                if (!context.mounted) return;
                replaceRoute(context);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                transform: Matrix4.identity()
                  ..scale(fabScale, 1.0)
                  ..translate(fabPosition),
                child: const Icon(Icons.navigate_next),
              ),
            );
          } else {
            startedAnimation = false;
          }
        }(),
        body: CustomScrollView(
          primary: true,
          slivers: [
            BetterSliverAppBar.large(
              title: AppBarTitle(
                title: translations.setup,
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
                        title: translations.import_,
                        subtitle: translations.import_description,
                        icon: Icons.file_download_outlined,
                        onTap: () => importData().then((success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success ? translations.import_success : translations.import_error),
                            ),
                          );

                          if (!success) return;

                          setPreference<bool>("is_first_run", false);
                          replaceRoute(context);
                        }),
                      ),
                    RadioModalSettingsTile<String>(
                      title: translations.school_system,
                      icon: Icons.school,
                      settingKey: "school_system",
                      values: <String, String>{
                        "lux": translations.lux_system,
                        "other": translations.other_school_system,
                      },
                      onChange: (_) => rebuild(),
                    ),
                    if (getPreference<String>("school_system") == "lux")
                      SettingsGroup(
                        title: translations.lux_system,
                        children: [
                          RadioModalSettingsTile<String>(
                            title: translations.system,
                            icon: Icons.build,
                            settingKey: "lux_system",
                            values: <String, String>{
                              "classic": translations.lux_system_classic,
                              "general": translations.lux_system_general,
                            },
                            onChange: (_) {
                              setPreference<int>("year", defaultValues["year"] as int);
                              setPreference<String>("section", defaultValues["section"] as String);
                              setPreference<String>("variant", defaultValues["variant"] as String);
                              rebuild();
                            },
                          ),
                          if (getPreference<String>("lux_system").isNotEmpty)
                            RadioModalSettingsTile<int>(
                              title: translations.yearOne,
                              icon: Icons.timelapse,
                              settingKey: "year",
                              selected: -1,
                              values: SetupManager.getYears(),
                              onChange: (_) {
                                if (SetupManager.hasSections()) {
                                  setPreference<String>("section", defaultValues["section"] as String);
                                }
                                if (SetupManager.getVariants()[getPreference<String>("variant")] == null) {
                                  setPreference<String>("variant", defaultValues["variant"] as String);
                                }
                                rebuild();
                              },
                            ),
                          if (SetupManager.hasSections())
                            RadioModalSettingsTile<String>(
                              title: translations.section,
                              icon: Icons.fork_right,
                              settingKey: "section",
                              values: SetupManager.getSections(),
                              onChange: (_) => rebuild(),
                            ),
                          if (SetupManager.hasVariants())
                            RadioModalSettingsTile<String>(
                              title: translations.variant,
                              icon: Icons.edit,
                              settingKey: "variant",
                              selected: defaultValues["variant"] as String,
                              values: SetupManager.getVariants(),
                              onChange: (_) => rebuild(),
                            ),
                          if (getPreference<int>("year") != -1 && getPreference<int>("year") != 1) const TermCountSettingsTile(),
                        ],
                      )
                    else if (getPreference<String>("school_system") == "other")
                      SettingsGroup(
                        title: translations.other_school_system,
                        children: getSettingsTiles(context, type: CreationType.add),
                      ),
                    SimpleSettingsTile(
                      title: translations.note,
                      subtitle: translations.note_description,
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
      ),
    );
  }
}
