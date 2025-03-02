// @dart = 2.12
// ignore_for_file: unused_element, unused_element_parameter

part of "settings_widgets.dart";

/// [SettingsScreen] is a simple Screen widget that may contain Tiles or other
/// widgets.
///
/// * Example:
/// ```dart
/// SettingsScreen(
///   title: 'Application Settings',
///   children: <Widget>[
///     SettingsGroup(
///            title: 'Single Choice Settings',
///            children: <Widget>[
///              SwitchSettingsTile(
///                settingKey: 'key-wifi',
///                title: 'Wi-Fi',
///                enabledLabel: 'Enabled',
///                disabledLabel: 'Disabled',
///                leading: Icon(Icons.wifi),
///                onChange: (value) {
///                  debugPrint('key-wifi: $value');
///                },
///              ),
///              CheckboxSettingsTile(
///                settingKey: 'key-blue-tooth',
///                title: 'Bluetooth',
///                enabledLabel: 'Enabled',
///                disabledLabel: 'Disabled',
///                leading: Icon(Icons.bluetooth),
///                onChange: (value) {
///                  debugPrint('key-blue-tooth: $value');
///                },
///              ),
///              SwitchSettingsTile(
///                leading: Icon(Icons.developer_mode),
///                settingKey: 'key-switch-dev-mode',
///                title: 'Developer Settings',
///                onChange: (value) {
///                  debugPrint('key-switch-dev-mod: $value');
///                },
///                childrenIfEnabled: <Widget>[
///                  CheckboxSettingsTile(
///                    leading: Icon(Icons.adb),
///                    settingKey: 'key-is-developer',
///                    title: 'Developer Mode',
///                    onChange: (value) {
///                      debugPrint('key-is-developer: $value');
///                    },
///                  ),
///                  SwitchSettingsTile(
///                    leading: Icon(Icons.usb),
///                    settingKey: 'key-is-usb-debugging',
///                    title: 'USB Debugging',
///                    onChange: (value) {
///                      debugPrint('key-is-usb-debugging: $value');
///                    },
///                  ),
///                  SimpleSettingsTile(
///                    title: 'Root Settings',
///                    subtitle: 'These settings is not accessible',
///                    enabled: false,
///                  ),
///               ],
///             ),
///          ],
///       ),
///   ],
/// );
/// ```
class SettingsScreen extends StatelessWidget {
  /// Appbar title in Scaffold.
  final String title;

  /// Content of the screen, body of the Scaffold.
  final List<Widget> children;

  const SettingsScreen({
    Key? key,
    required this.children,
    this.title = "Settings",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: children.length,
        itemBuilder: (BuildContext context, int index) {
          return children[index];
        },
      ),
    );
  }
}

/// [_SettingsTile] is a Basic Building block for Any Settings widget.
///
/// This widget is container for any widget which is to be used for setting.
class _SettingsTile extends StatefulWidget {
  /// title string for the tile
  final String title;

  /// widget to be placed at first in the tile
  final Widget? leading;

  /// subtitle string for the tile
  final String? subtitle;

  /// title text style
  final TextStyle? titleTextStyle;

  /// subtitle text style
  final TextStyle? subtitleTextStyle;

  /// flag to represent if the tile is accessible or not, if false user input is ignored
  final bool enabled;

  /// widget which is placed as the main element of the tile as settings UI
  final Widget child;

  final Widget? trailing;

  /// call back for handling the tap event on tile
  final GestureTapCallback? onTap;

  /// flag to show the child below the main tile elements
  final bool showChildBelow;

  final Color? color;

  final EdgeInsets? padding;

  final bool dense;

  final ShapeBorder? shape;

  const _SettingsTile({
    required this.title,
    required this.child,
    this.color,
    this.subtitle = "",
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.onTap,
    this.enabled = true,
    this.showChildBelow = false,
    this.leading,
    this.trailing,
    this.padding,
    this.dense = false,
    this.shape,
  });

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ListTile(
          contentPadding: widget.padding,
          leading: widget.leading,
          shape: widget.shape,
          title: Text(
            widget.title,
            style: widget.titleTextStyle ??
                headerTextStyle(context)?.copyWith(color: !widget.enabled ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3) : null),
          ),
          subtitle: widget.subtitle?.isEmpty ?? true
              ? null
              : Text(
                  widget.subtitle!,
                  style: widget.subtitleTextStyle ??
                      subtitleTextStyle(context)
                          ?.copyWith(color: !widget.enabled ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3) : null),
                ),
          enabled: widget.enabled,
          onTap: widget.onTap,
          trailing: widget.trailing ??
              Visibility(
                visible: !widget.showChildBelow,
                child: widget.child,
              ),
          dense: widget.dense,
          // wrap only if the subtitle is longer than 70 characters
          //isThreeLine: (widget.subtitle?.isNotEmpty ?? false) && widget.subtitle!.length > 70,
        ),
        Visibility(
          visible: widget.showChildBelow,
          child: widget.child,
        ),
      ],
    );
  }
}

/// [_SimpleHeaderTile] is a widget which is used to show Leading, Title and subtitle
/// of a [_SettingsTile] without the main child widget
class _SimpleHeaderTile extends StatefulWidget {
  /// title string for the tile
  final String? title;

  /// subtitle string for the tile
  final String? subtitle;

  /// title text style
  final TextStyle? titleTextStyle;

  /// subtitle text style
  final TextStyle? subtitleTextStyle;

  /// widget to be placed at first in the tile
  final Widget? leading;

  const _SimpleHeaderTile({
    Key? key,
    this.title,
    this.subtitle = "",
    this.leading,
    this.titleTextStyle,
    this.subtitleTextStyle,
  }) : super(key: key);

  @override
  State<_SimpleHeaderTile> createState() => _SimpleHeaderTileState();
}

class _SimpleHeaderTileState extends State<_SimpleHeaderTile> {
  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: ListTile(
        title: Text(
          widget.title ?? "",
          style: widget.titleTextStyle ?? headerTextStyle(context),
        ),
        subtitle: (widget.subtitle?.isNotEmpty ?? false)
            ? Text(
                widget.subtitle!,
                style: widget.subtitleTextStyle ?? subtitleTextStyle(context),
              )
            : null,
        leading: widget.leading,
      ),
    );
  }
}

/// [_ExpansionSettingsTile] is a special setting widget which has two states.
///
/// Collapsed State:
///   In this state the settings tile would only show the Title,Subtitle and leading
///   widget
///
/// Expanded State:
///   In this state the settings tile would show all widgets in collapsed state,
///   but also the children widgets.
class _ExpansionSettingsTile extends StatefulWidget {
  /// title string for the tile
  final String title;

  /// subtitle string for the tile, default = ''
  final String subtitle;

  /// flag to represent if the tile is accessible or not, if false user input is ignored
  /// default = true
  final bool enabled;

  /// flag to represent the current state of the expansion tile, if true it means that
  /// the tile is in expanded mode
  /// default = false
  final bool expanded;

  /// The widget displayed when the tile is expanded
  final Widget child;

  /// The widget shown in front of the title
  final Widget? leading;

  /// A Callback for the change of the Expansion state
  final Function(bool)? onExpansionChanged;

  const _ExpansionSettingsTile({
    required this.title,
    required this.child,
    this.subtitle = "",
    this.enabled = true,
    this.expanded = false,
    this.onExpansionChanged,
    this.leading,
  });

  @override
  State<_ExpansionSettingsTile> createState() => _ExpansionSettingsTileState();
}

class _ExpansionSettingsTileState extends State<_ExpansionSettingsTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.enabled ? getExpansionTile() : getListTile();
  }

  Widget getListTile() {
    return _SettingsTile(
      title: widget.title,
      subtitle: widget.subtitle,
      enabled: false,
      leading: widget.leading,
      child: const Text(""),
    );
  }

  Widget getExpansionTile() {
    return Material(
      child: ExpansionTile(
        title: Text(
          widget.title,
          style: headerTextStyle(context),
        ),
        leading: widget.leading,
        subtitle: Text(
          widget.subtitle,
          style: subtitleTextStyle(context),
        ),
        initiallyExpanded: widget.expanded,
        childrenPadding: const EdgeInsets.only(left: 8),
        children: <Widget>[widget.child],
      ),
    );
  }
}

///[_ModalSettingsTile] is a widget which shows the given child widget inside a
/// dialog view.
///
/// This widget can be used to show a settings UI which is too big for a single
///  tile in the SettingScreen UI or a Setting tile which needs to be shown separately.
class _ModalSettingsTile<T> extends StatefulWidget {
  /// title string for the tile
  final String title;

  /// subtitle string for the tile, default = ''
  final String? subtitle;

  /// title text style
  final TextStyle? titleTextStyle;

  /// subtitle text style
  final TextStyle? subtitleTextStyle;

  /// flag to represent if the tile is accessible or not, if false user input is ignored
  /// default = true
  final bool enabled;

  /// The widget shown in front of the title
  final IconData? icon;

  /// The list widgets which will be displayed in a vertical list manner
  /// when the dialog is displayed
  final Widget child;

  /// flag that determines if the dialog will be displayed with
  /// confirmation buttons or not .
  /// Buttons like, ok & cancel
  ///
  /// default = false
  final bool showConfirmation;

  /// Callback to execute when user taps cancel button,
  /// It is a simple void callback to execute when user wants to revert the changes
  /// back to previous
  ///
  /// **Note**: the action performed will not affect the settings that were updated
  /// automatically. However you can choose to modify them as per your need by referencing
  /// the values from the callback & updating
  final VoidCallback? onCancel;

  /// Callback to execute when user taps ok button, while [onCancel] callback
  /// is a simple void callback, this one allows you to perform some task
  /// before closing the dialog.
  ///
  /// **Note**: the action performed will not affect the settings that were updated
  /// automatically. However you can choose to modify them as per your need by referencing
  /// the values from the callback & updating
  final OnConfirmedCallback? onConfirm;
  final GlobalKey? dialogKey;

  const _ModalSettingsTile({
    Key? key,
    required this.title,
    required this.child,
    this.subtitle = "",
    this.enabled = true,
    this.icon,
    this.showConfirmation = true,
    this.onCancel,
    this.onConfirm,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.dialogKey,
  }) : super(key: key);

  void submit() {}

  @override
  State<_ModalSettingsTile> createState() => _ModalSettingsTileState();
}

class _ModalSettingsTileState extends State<_ModalSettingsTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ListTile(
          leading: Icon(
            widget.icon,
          ),
          title: Text(widget.title, style: widget.titleTextStyle ?? headerTextStyle(context)),
          subtitle: widget.subtitle != null
              ? Text(
                  widget.subtitle!,
                  style: widget.subtitleTextStyle ?? subtitleTextStyle(context),
                )
              : null,
          enabled: widget.enabled,
          onTap: () => _showWidget(context, widget.child),
        ),
      ],
    );
  }

  void _showWidget(BuildContext context, Widget child) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (dialogContext) {
        return EasyDialog(
          title: widget.title,
          icon: widget.icon,
          onConfirm: widget.onConfirm,
          key: widget.dialogKey,
          child: child,
        );
      },
    );
  }
}

/// [_SettingsTileDivider] is widget which is used as a Divide various settings
/// tile in a list
class _SettingsTileDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider();
  }
}

/// [_SettingsCheckbox] is a Settings UI version of the [Checkbox] widget.
class _SettingsCheckbox extends StatelessWidget {
  /// current state of the checkbox
  final bool value;

  /// on change callback to handle state change
  final OnChanged<bool?> onChanged;

  /// flag which represents the state of the settings, if false the the tile will
  /// ignore all the user inputs
  final bool enabled;

  const _SettingsCheckbox({
    required this.value,
    required this.onChanged,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      onChanged: enabled ? onChanged : null,
    );
  }
}

/// [_SettingsSwitch] is a Settings UI version of the [Switch] widget
class _SettingsSwitch extends StatelessWidget {
  /// current state of the switch
  final bool value;

  /// on change callback to handle state change
  final OnChanged<bool?> onChanged;

  /// flag which represents the state of the settings, if false the the tile will
  /// ignore all the user inputs
  final bool enabled;

  const _SettingsSwitch({
    required this.value,
    required this.onChanged,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: enabled ? onChanged : null,
    );
  }
}

/// [_SettingsRadio] is a Settings UI version of the [Radio] widgets
class _SettingsRadio<T> extends StatelessWidget {
  /// value of the selected radio in this group
  final T groupValue;

  /// value of the current radio widget
  final T value;

  /// on change callback to handle state change
  final OnChanged<T?> onChanged;

  /// flag which represents the state of the settings, if false the the tile will
  /// ignore all the user inputs
  final bool enabled;

  const _SettingsRadio({
    required this.groupValue,
    required this.value,
    required this.onChanged,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Radio<T>(
      groupValue: groupValue,
      value: value,
      onChanged: enabled ? onChanged : null,
    );
  }
}

/// [_SettingsDropDown] is a Settings UI version of the [DropdownButton]
class _SettingsDropDown<T> extends StatelessWidget {
  /// value of the selected in this dropdown
  final T selected;

  /// Alignment of the dropdown. Defaults to [AlignmentDirectional.centerEnd].
  final AlignmentGeometry alignment;

  /// List of values for this dropdown
  final List<T> values;

  /// on change call back to handle selected value change
  final OnChanged<T?> onChanged;

  /// single item builder for creating a [DropdownMenuItem]
  final ItemBuilder<T> itemBuilder;

  /// flag which represents the state of the settings, if false the the tile will
  /// ignore all the user inputs
  final bool enabled;

  const _SettingsDropDown({
    required this.selected,
    required this.values,
    required this.onChanged,
    required this.itemBuilder,
    this.alignment = AlignmentDirectional.centerEnd,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      children: <Widget>[
        DropdownButton<T>(
          //isDense: true,
          value: selected,
          alignment: alignment,
          onChanged: enabled ? onChanged : null,
          underline: Container(),
          items: values.map<DropdownMenuItem<T>>(
            (T val) {
              return DropdownMenuItem<T>(
                value: val,
                child: itemBuilder(val),
              );
            },
          ).toList(),
        ),
      ],
    );
  }
}

/// [_SettingsSlider] is a Settings UI version of [Slider] widget
class _SettingsSlider extends StatelessWidget {
  /// min value allowed for the slider
  final double min;

  /// max value allowed for the slider
  final double max;

  /// step value for slider interval
  final double step;

  /// current value of the slider
  final double value;

  /// on change callback to handle the value change when slider starts moving
  final OnChanged<double>? onChangeStart;

  /// on change callback to handle the value change
  final OnChanged<double>? onChanged;

  /// on change callback to handle the value change when slider stops moving
  final OnChanged<double>? onChangeEnd;

  /// flag which represents the state of the settings, if false then the tile will
  /// ignore all the user inputs
  final bool enabled;

  /// flag which allows updating the value of setting immediately when the
  /// slider is moved, default = true
  ///
  /// If this flag is enabled then [onChangeStart] & [onChangeEnd] callbacks are
  /// ignored & will not be executed
  final bool eagerUpdate;

  const _SettingsSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.enabled,
    this.onChangeStart,
    this.onChanged,
    this.onChangeEnd,
    this.eagerUpdate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Slider.adaptive(
      value: value,
      min: min,
      max: max,
      divisions: (max - min) ~/ step,
      onChangeStart: enabled && !eagerUpdate ? (value) => onChangeStart?.call(value) : null,
      onChanged: enabled ? (value) => onChanged?.call(value) : null,
      onChangeEnd: enabled && !eagerUpdate ? (value) => onChangeEnd?.call(value) : null,
    );
  }
}
