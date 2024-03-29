// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:flex_color_picker/flex_color_picker.dart";
import "package:flutter_hooks/flutter_hooks.dart";

// Project imports:
import "package:graded/localization/translations.dart";
import "package:graded/misc/storage.dart";
import "package:graded/ui/settings/flutter_settings_screens.dart";
import "package:graded/ui/utilities/app_theme.dart";
import "package:graded/ui/utilities/custom_icons.dart";
import "package:graded/ui/utilities/haptics.dart";
import "package:graded/ui/utilities/misc_utilities.dart";
import "package:graded/ui/widgets/misc_widgets.dart";

class EasyBottomSheet extends StatefulHookWidget {
  final String title;
  final IconData? icon;
  final Widget child;
  final String? action;

  const EasyBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.action,
  });

  @override
  State<EasyBottomSheet> createState() => _EasyBottomSheetState();
}

class _EasyBottomSheetState extends State<EasyBottomSheet> {
  @override
  void initState() {
    super.initState();
    lightHaptics();
  }

  @override
  Widget build(BuildContext context) {
    final height = useState(0.0);

    final children = [
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
    ];

    // calculate the proportion
    final double maxSize = useMemoized(
      () => ((height.value / MediaQuery.of(context).size.height) + 0.06).clamp(.1, .9),
      [height.value],
    );

    // for some reason initSize can't equal max size for very long widgets
    final initSize = maxSize * (1 - .0001);

    // render the child to get its height
    if (height.value == 0) {
      return SingleChildScrollView(
        child: MeasuredWidget(
          onCalculateSize: (v) => height.value = v!.height,
          child: Column(
            children: children,
          ),
        ),
      );
    }

    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: maxSize,
      initialChildSize: initSize,
      builder: (context, scrollController) {
        return SafeArea(
          top: false,
          maintainBottomViewPadding: true,
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (OverscrollIndicatorNotification overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: Theme(
              data: Theme.of(context).copyWith(
                cardTheme: Theme.of(context).cardTheme.copyWith(elevation: 0.75),
              ),
              child: ListView(
                children: children,
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

class ColorBottomSheet extends StatelessWidget {
  const ColorBottomSheet({
    super.key,
    this.onChanged,
  });

  final void Function()? onChanged;

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
                lightHaptics();

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
              icon: Icon(
                CustomIcons.twitter,
                color: Theme.of(context).colorScheme.secondary,
              ),
              tooltip: translations.twitter,
            ),
            IconButton(
              onPressed: () {
                launchURL(Link.instagram);
              },
              icon: Icon(
                CustomIcons.instagram,
                color: Theme.of(context).colorScheme.secondary,
              ),
              tooltip: translations.instagram,
            ),
            IconButton(
              onPressed: () {
                launchURL(Link.facebook);
              },
              icon: Icon(
                CustomIcons.facebook,
                color: Theme.of(context).colorScheme.secondary,
              ),
              tooltip: translations.facebook,
            ),
            IconButton(
              onPressed: () {
                launchURL(Link.linkedin);
              },
              icon: Icon(
                CustomIcons.linkedin,
                color: Theme.of(context).colorScheme.secondary,
              ),
              tooltip: translations.linkedin,
            ),
          ],
        ),
      ),
    );
  }
}
