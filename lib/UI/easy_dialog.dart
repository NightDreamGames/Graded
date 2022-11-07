import 'package:flutter/material.dart';
import '/UI/Settings/flutter_settings_screens.dart';

///[EasyDialog] is a widget which shows the given child widget inside a
/// dialog view.
///
/// This widget can be used to show a settings UI which is too big for a single
///  tile in the SettingScreen UI or a Setting tile which needs to be shown separately.
class EasyDialog<T> extends StatefulWidget {
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
  final Widget? leading;

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

  const EasyDialog({
    Key? key,
    required this.title,
    required this.child,
    this.subtitle = '',
    this.enabled = true,
    this.leading,
    this.showConfirmation = true,
    this.onCancel,
    this.onConfirm,
    this.titleTextStyle,
    this.subtitleTextStyle,
  }) : super(key: key);

  @override
  State<EasyDialog> createState() => _EasyDialogState();
}

class _EasyDialogState extends State<EasyDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Center(
        child: getTitle(),
      ),
      children: [
        _finalWidgets(context, widget.child),
      ],
    );
  }

  Widget _finalWidgets(BuildContext dialogContext, Widget children) {
    if (!widget.showConfirmation) {
      return children;
    }
    return _addActionWidgets(dialogContext, children);
  }

  Widget getTitle() {
    return Column(children: [
      widget.leading != null
          ? Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: widget.leading,
            )
          : Container(),
      Text(
        widget.title,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    ]);
  }

  Widget _addActionWidgets(BuildContext dialogContext, Widget children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: children,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0, right: 8.0),
          child: ButtonBar(
            layoutBehavior: ButtonBarLayoutBehavior.constrained,
            alignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                onPressed: () {
                  widget.onCancel?.call();
                  _disposeDialog(dialogContext);
                },
                child: Text(
                  MaterialLocalizations.of(dialogContext).cancelButtonLabel,
                  //style: TextStyle(color: Theme.of(dialogContext).colorScheme.primary),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                onPressed: () async {
                  var closeDialog = true;
                  if (widget.onConfirm != null) {
                    closeDialog = widget.onConfirm!.call();
                  }

                  if (closeDialog) {
                    _disposeDialog(dialogContext);
                  }
                },
                child: Text(
                  MaterialLocalizations.of(dialogContext).okButtonLabel,
                  //style: TextStyle(color: Theme.of(dialogContext).colorScheme.primary),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  void _disposeDialog(BuildContext dialogContext) {
    Navigator.of(dialogContext).pop();
  }
}
