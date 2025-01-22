// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:flex_color_picker/flex_color_picker.dart";

// Project imports:
import "package:graded/localization/translations.dart";
import "package:graded/misc/storage.dart";
import "package:graded/ui/settings/flutter_settings_screens.dart";
import "package:graded/ui/utilities/app_theme.dart";
import "package:graded/ui/utilities/custom_icons.dart";
import "package:graded/ui/utilities/haptics.dart";
import "package:graded/ui/utilities/misc_utilities.dart";
import "package:graded/ui/widgets/misc_widgets.dart";

class EasyBottomSheet extends StatefulWidget {
  final String title;
  final IconData? icon;
  final Widget child;

  const EasyBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.icon,
  });

  @override
  State<EasyBottomSheet> createState() => _EasyBottomSheetState();
}

class _EasyBottomSheetState extends State<EasyBottomSheet> {
  double maxSize = 1;
  double get initSize => maxSize * (1 - .0001);

  void _setMaxChildSize(Size size) {
    setState(() {
      const double indicatorPadding = 48;
      const double errorPadding = 0;

      // get height of the container.
      final double boxHeight = size.height + indicatorPadding + errorPadding;
      // get height of the screen from mediaQuery.
      final double screenHeight = MediaQuery.of(context).size.height;
      // get the ratio to set as max size.
      final double ratio = boxHeight / screenHeight;
      maxSize = ratio.clamp(.1, .9);
    });
  }

  @override
  void initState() {
    super.initState();
    lightHaptics();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: maxSize,
      initialChildSize: maxSize,
      builder: (context, scrollController) {
        return NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: SingleChildScrollView(
            controller: scrollController,
            child: MeasureSize(
              onChange: _setMaxChildSize,
              child: SafeArea(
                top: false,
                maintainBottomViewPadding: true,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    cardTheme: Theme.of(context).cardTheme.copyWith(elevation: 0.75),
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              widget.icon,
                              size: 32,
                            ),
                            const Padding(padding: EdgeInsets.only(top: 8, bottom: 8)),
                            Text(
                              widget.title,
                              style: Theme.of(context).textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const Padding(padding: EdgeInsets.only(bottom: 8)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        child: widget.child,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

void showBottomSheet({required BuildContext context, required Widget child}) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return child;
      },
    );

void showColorBottomSheet(BuildContext context, void Function()? onChanged) => showBottomSheet(
      context: context,
      child: ColorBottomSheet(onChanged: onChanged),
    );

class ColorBottomSheet extends StatefulWidget {
  const ColorBottomSheet({
    super.key,
    this.onChanged,
  });

  final void Function()? onChanged;

  @override
  State<ColorBottomSheet> createState() => _ColorBottomSheetState();
}

class _ColorBottomSheetState extends State<ColorBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return EasyBottomSheet(
      title: translations.colorOther,
      icon: Icons.color_lens_outlined,
      child: Card(
        child: SettingsContainer(
          children: [
            SwitchSettingsTile(
              title: translations.dynamic_color,
              settingKey: "dynamicColor",
              subtitle: !AppTheme.hasDynamicColor ? translations.no_dynamic_color : "",
              defaultValue: AppTheme.hasDynamicColor,
              enabled: AppTheme.hasDynamicColor,
              onChange: (_) {
                widget.onChanged?.call();
                setState(() {});
              },
            ),
            SimpleSettingsTile(
              title: translations.custom_color,
              subtitle: translations.edit_primary_color,
              enabled: !AppTheme.hasDynamicColor || !getPreference<bool>("dynamicColor"),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(getPreference<int>("customColor")),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              onTap: () {
                lightHaptics();

                Color selectedColor = Color(getPreference<int>("customColor"));

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
                  colorCodePrefixStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
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
                  setPreference<int>("customColor", selectedColor.value32bit);
                  widget.onChanged?.call();
                });
              },
            ),
            SwitchSettingsTile(
              title: translations.amoled_mode,
              settingKey: "amoled",
              // ignore: avoid_redundant_argument_values
              defaultValue: false,
              onChange: (_) => widget.onChanged?.call(),
            ),
          ],
        ),
      ),
    );
  }
}

void showSocialsBottomSheet(BuildContext context) => showBottomSheet(
      context: context,
      child: const SocialsBottomSheet(),
    );

class SocialsBottomSheet extends StatelessWidget {
  const SocialsBottomSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return EasyBottomSheet(
      title: translations.follow_nightdream_games,
      icon: Icons.star_border_outlined,
      child: Theme(
        data: Theme.of(context).copyWith(
          iconTheme: Theme.of(context).iconTheme.copyWith(
                size: 32,
              ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                launchURL(Link.twitter);
              },
              icon: const Icon(CustomIcons.twitter),
              tooltip: translations.twitter,
            ),
            IconButton(
              onPressed: () {
                launchURL(Link.instagram);
              },
              icon: const Icon(CustomIcons.instagram),
              tooltip: translations.instagram,
            ),
            IconButton(
              onPressed: () {
                launchURL(Link.facebook);
              },
              icon: const Icon(CustomIcons.facebook),
              tooltip: translations.facebook,
            ),
            IconButton(
              onPressed: () {
                launchURL(Link.linkedin);
              },
              icon: const Icon(CustomIcons.linkedin),
              tooltip: translations.linkedin,
            ),
          ],
        ),
      ),
    );
  }
}
