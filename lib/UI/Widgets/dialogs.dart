// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../Calculations/calculator.dart';
import '../../Calculations/manager.dart';
import '../../Calculations/subject.dart';
import '../../Calculations/term.dart';
import '../../Calculations/test.dart';
import '../../Misc/storage.dart';
import '../../Translations/translations.dart';
import '../Utilities/hints.dart';
import '/UI/Settings/flutter_settings_screens.dart';
import 'easy_form_field.dart';

class EasyDialog extends StatefulWidget {
  final String title;
  final String? subtitle;
  final TextStyle? titleTextStyle;
  final TextStyle? subtitleTextStyle;
  final bool enabled;
  final IconData? icon;
  final Widget child;
  final bool showConfirmation;
  final VoidCallback? onCancel;
  final OnConfirmedCallback? onConfirm;
  final String? action;

  const EasyDialog({
    Key? key,
    required this.title,
    required this.child,
    this.subtitle = '',
    this.enabled = true,
    this.icon,
    this.showConfirmation = true,
    this.onCancel,
    this.onConfirm,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.action,
  }) : super(key: key);

  @override
  State<EasyDialog> createState() => EasyDialogState();
}

class EasyDialogState extends State<EasyDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surfaceTint, 3),
      elevation: 0,
      semanticLabel: widget.title,
      title: Text(widget.title),
      scrollable: true,
      icon: widget.icon != null ? Icon(widget.icon) : null,
      iconColor: Theme.of(context).colorScheme.secondary,
      actions: [
        TextButton(
          onPressed: () {
            widget.onCancel?.call();
            _disposeDialog(context);
          },
          child: Text(
            Translations.cancel,
          ),
        ),
        TextButton(
          onPressed: () async {
            submit();
          },
          child: Text(
            widget.action ?? Translations.save,
          ),
        )
      ],
      content: Form(
        key: formKey,
        child: widget.child,
      ),
    );
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void _disposeDialog(BuildContext dialogContext) {
    Navigator.pop(dialogContext);
  }

  void submit() {
    var closeDialog = true;

    bool submitText() {
      var isValid = true;
      final state = formKey.currentState;
      if (state != null) {
        isValid = state.validate();
      }

      if (isValid) {
        state?.save();
        return true;
      }

      return false;
    }

    if (!submitText()) {
      closeDialog = false;
    } else if (widget.onConfirm != null) {
      closeDialog = widget.onConfirm!.call();
    }

    if (closeDialog) {
      _disposeDialog(context);
    }
  }
}

Future<void> showTestDialog(BuildContext context, Subject subject, TextEditingController nameController, TextEditingController gradeController,
    TextEditingController maximumController,
    {int? index}) async {
  gradeController.clear();
  maximumController.clear();
  nameController.clear();

  bool add = index == null;
  gradeController.text = add ? "" : Calculator.format(subject.tests[index].value1, ignoreZero: true);
  maximumController.text = add ? "" : Calculator.format(subject.tests[index].value2, ignoreZero: true);
  nameController.text = add ? "" : subject.tests[index].name;

  return showDialog(
    context: context,
    builder: (context) {
      final GlobalKey<EasyDialogState> dialogKey = GlobalKey<EasyDialogState>();
      FocusNode focusNode = FocusNode();

      return EasyDialog(
        key: dialogKey,
        title: add ? Translations.add_test : Translations.edit_test,
        icon: add ? Icons.add : Icons.edit,
        onConfirm: () {
          if (add) {
            subject.addTest(
              Test(
                  Calculator.tryParse(gradeController.text) ?? 1,
                  Calculator.tryParse(maximumController.text) ?? Storage.getPreference<double>("total_grades"),
                  nameController.text.isEmpty ? getTestHint(subject) : nameController.text),
            );
          } else {
            subject.editTest(
              index,
              Calculator.tryParse(gradeController.text) ?? 1,
              Calculator.tryParse(maximumController.text) ?? Storage.getPreference<double>("total_grades"),
              nameController.text.isEmpty ? getTestHint(subject) : nameController.text,
            );
          }

          return true;
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: EasyFormField(
                controller: nameController,
                label: Translations.name,
                hint: getTestHint(subject),
                textInputAction: TextInputAction.next,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: EasyFormField(
                    controller: gradeController,
                    label: Translations.grade,
                    hint: "01",
                    textAlign: TextAlign.end,
                    autofocus: true,
                    numeric: true,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 18),
                  child: Text("/", style: TextStyle(fontSize: 20)),
                ),
                Flexible(
                  child: EasyFormField(
                    focusNode: focusNode,
                    controller: maximumController,
                    label: Translations.maximum,
                    hint: Calculator.format(Storage.getPreference<double>("total_grades")),
                    numeric: true,
                    onSubmitted: () {
                      maximumController.clearComposing();
                      focusNode.unfocus();

                      if (dialogKey.currentState is EasyDialogState) {
                        (dialogKey.currentState as EasyDialogState).submit();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showSubjectDialog(BuildContext context, TextEditingController nameController, TextEditingController coeffController,
    {int? index}) async {
  coeffController.clear();
  nameController.clear();

  bool add = index == null;
  coeffController.text = add ? "" : Calculator.format(Manager.termTemplate[index].coefficient, ignoreZero: true);
  nameController.text = add ? "" : Manager.termTemplate[index].name;

  final GlobalKey<EasyDialogState> dialogKey = GlobalKey<EasyDialogState>();
  FocusNode focusNode = FocusNode();

  return showDialog(
    context: context,
    builder: (context) {
      return EasyDialog(
        key: dialogKey,
        title: add ? Translations.add_subject : Translations.edit_subject,
        icon: add ? Icons.add : Icons.edit,
        onConfirm: () {
          String name = nameController.text.isEmpty ? getSubjectHint() : nameController.text;
          double coefficient = Calculator.tryParse(coeffController.text) ?? 1.0;

          if (add) {
            Manager.termTemplate.add(Subject(name, coefficient));

            for (Term p in Manager.getCurrentYear().terms) {
              p.subjects.add(Subject(name, coefficient));
            }
          } else {
            Manager.termTemplate[index].name = nameController.text.isEmpty ? getSubjectHint() : nameController.text;
            Manager.termTemplate[index].coefficient = Calculator.tryParse(coeffController.text) ?? 1.0;

            Manager.sortSubjectsAZ();

            for (Term p in Manager.getCurrentYear().terms) {
              for (int i = 0; i < p.subjects.length; i++) {
                p.subjects[i].name = Manager.termTemplate[i].name;
                p.subjects[i].coefficient = Manager.termTemplate[i].coefficient;
              }
            }
          }

          Manager.calculate();

          return true;
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: EasyFormField(
                controller: nameController,
                autofocus: true,
                label: Translations.name,
                hint: getSubjectHint(),
                textInputAction: TextInputAction.next,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: EasyFormField(
                    controller: coeffController,
                    focusNode: focusNode,
                    label: Translations.coefficient,
                    hint: "1",
                    numeric: true,
                    onSubmitted: () {
                      coeffController.clearComposing();
                      focusNode.unfocus();

                      if (dialogKey.currentState is EasyDialogState) {
                        (dialogKey.currentState as EasyDialogState).submit();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
