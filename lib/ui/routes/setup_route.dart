// Flutter imports:
import "package:flutter/material.dart";

// Project imports:
import "package:graded/l10n/translations.dart";
import "package:graded/main.dart";
import "package:graded/misc/default_values.dart";
import "package:graded/misc/enums.dart";
import "package:graded/misc/setup_manager.dart";
import "package:graded/misc/storage.dart";
import "package:graded/ui/settings/flutter_settings_screens.dart";
import "package:graded/ui/utilities/haptics.dart";
import "package:graded/ui/widgets/better_app_bar.dart";
import "package:graded/ui/widgets/custom_safe_area.dart";
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
  double fabScale = 1;
  double fabPosition = 0;

  void _animateIcon() {
    setState(() {
      fabScale = 0.8;
      fabPosition = 8;
    });

    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() {
        fabScale = 1;
        fabPosition = 0;
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
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) return;
        SetupManager.dispose();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        floatingActionButton: () {
          if ((getPreference<int>("year") != -1 && (!SetupManager.hasSections() || getPreference<String>("section").isNotEmpty)) ||
              getPreference<String>("schoolSystem") == "other") {
            Future.delayed(const Duration(milliseconds: 500)).then((_) {
              if (startedAnimation || !mounted) return;
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
                heavyHaptics();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                transform: Matrix4.identity()
                  ..scale(fabScale, 1)
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
            CustomSliverSafeArea(
              top: false,
              maintainBottomViewPadding: true,
              sliver: SliverToBoxAdapter(
                child: SettingsContainer(
                  children: [
                    if (!widget.dismissible)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
                        child: Card(
                          child: ImportSettingsTile(
                            onChanged: () {
                              setPreference<bool>("isFirstRun", false);
                              replaceRoute(context);
                            },
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Card(
                        child: RadioModalSettingsTile<String>(
                          title: translations.school_system,
                          icon: Icons.school,
                          settingKey: "schoolSystem",
                          values: <String, String>{
                            "lux": translations.lux_system,
                            "other": translations.other_school_system,
                          },
                          onChange: (_) => rebuild(),
                        ),
                      ),
                    ),
                    if (getPreference<String>("schoolSystem") == "lux")
                      SettingsGroup(
                        title: translations.lux_system,
                        children: [
                          RadioModalSettingsTile<String>(
                            title: translations.system,
                            icon: Icons.build,
                            settingKey: "luxSystem",
                            values: <String, String>{
                              "classic": translations.lux_system_classic,
                              "general": translations.lux_system_general,
                            },
                            onChange: (_) {
                              setPreference<int>("year", DefaultValues.year);
                              setPreference<String>("section", DefaultValues.section);
                              setPreference<String>("variant", DefaultValues.variant);
                              rebuild();
                            },
                          ),
                          if (getPreference<String>("luxSystem").isNotEmpty)
                            RadioModalSettingsTile<int>(
                              title: translations.yearOne,
                              icon: Icons.timelapse,
                              settingKey: "year",
                              selected: -1,
                              values: SetupManager.getYears(),
                              onChange: (_) {
                                if (SetupManager.hasSections()) {
                                  setPreference<String>("section", DefaultValues.section);
                                }
                                if (SetupManager.getVariants()[getPreference<String>("variant")] == null) {
                                  setPreference<String>("variant", DefaultValues.variant);
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
                              selected: DefaultValues.variant,
                              values: SetupManager.getVariants(),
                              onChange: (_) => rebuild(),
                            ),
                          if (getPreference<int>("year") != -1 && getPreference<int>("year") != 1) const TermCountSettingsTile(),
                        ],
                      )
                    else if (getPreference<String>("schoolSystem") == "other")
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
