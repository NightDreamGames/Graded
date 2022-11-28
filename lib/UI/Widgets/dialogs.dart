// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../Calculations/calculator.dart';
import '../../Calculations/manager.dart';
import '../../Calculations/subject.dart';
import '../../Calculations/term.dart';
import '../../Calculations/test.dart';
import '../../Translations/translations.dart';
import '../Utilities/hints.dart';
import '/UI/Settings/flutter_settings_screens.dart';
import 'easy_form_field.dart';

class EasyDialog<T> extends StatefulWidget {
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
      backgroundColor: ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surfaceTint, 3),
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
      if (widget.icon != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Icon(widget.icon, color: Theme.of(context).colorScheme.secondary),
        ),
      Text(
        widget.title,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    ]);
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Widget _addActionWidgets(BuildContext dialogContext, Widget children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: children,
            ),
          ),
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
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                onPressed: () async {
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
                    _disposeDialog(dialogContext);
                  }
                },
                child: Text(
                  MaterialLocalizations.of(dialogContext).okButtonLabel,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  void _disposeDialog(BuildContext dialogContext) {
    Navigator.pop(dialogContext);
  }
}

Future<void> showTestDialog(BuildContext context, Subject subject, {int? index}) async {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();
  final TextEditingController maximumController = TextEditingController();

  gradeController.clear();
  maximumController.clear();
  nameController.clear();

  bool add = index == null;
  gradeController.text = add ? "" : Calculator.format(subject.tests[index].grade1, ignoreZero: true);
  maximumController.text = add ? "" : Calculator.format(subject.tests[index].grade2, ignoreZero: true);
  nameController.text = add ? "" : subject.tests[index].name;

  return showDialog(
    context: context,
    builder: (context) {
      return EasyDialog(
        title: add ? Translations.add_test : Translations.edit_test,
        icon: add ? Icons.add : Icons.edit,
        onConfirm: () {
          if (add) {
            subject.addTest(Test(double.tryParse(gradeController.text) ?? 1, double.tryParse(maximumController.text) ?? Manager.totalGrades,
                nameController.text.isEmpty ? getTestHint(subject) : nameController.text));
          } else {
            subject.editTest(index, double.tryParse(gradeController.text) ?? 1, double.tryParse(maximumController.text) ?? Manager.totalGrades,
                nameController.text.isEmpty ? getTestHint(subject) : nameController.text);
          }

          return true;
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            EasyFormField(
              controller: nameController,
              label: Translations.name,
              hint: getTestHint(subject),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                EasyFormField(
                  controller: gradeController,
                  label: Translations.grade,
                  hint: "01",
                  textAlign: TextAlign.end,
                  autofocus: true,
                  numeric: true,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 18),
                  child: Text("/", style: TextStyle(fontSize: 20)),
                ),
                EasyFormField(
                  controller: maximumController,
                  label: Translations.maximum,
                  hint: Calculator.format(Manager.totalGrades),
                  numeric: true,
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showSubjectDialog(BuildContext context, {int? index}) async {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController coeffController = TextEditingController();

  coeffController.clear();
  nameController.clear();

  bool add = index == null;
  coeffController.text = add ? "" : Calculator.format(Manager.termTemplate[index].coefficient, ignoreZero: true);
  nameController.text = add ? "" : Manager.termTemplate[index].name;

  return showDialog(
    context: context,
    builder: (context) {
      return EasyDialog(
        title: add ? Translations.add_subject : Translations.edit_subject,
        icon: add ? Icons.add : Icons.edit,
        onConfirm: () {
          String name = nameController.text.isEmpty ? getSubjectHint() : nameController.text;
          double coefficient = double.tryParse(coeffController.text) ?? 1.0;

          if (add) {
            Manager.termTemplate.add(Subject(name, coefficient));

            for (Term p in Manager.getCurrentYear().terms) {
              p.subjects.add(Subject(name, coefficient));
            }
          } else {
            Manager.termTemplate[index].name = nameController.text.isEmpty ? getSubjectHint() : nameController.text;
            Manager.termTemplate[index].coefficient = double.tryParse(coeffController.text) ?? 1.0;

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
            EasyFormField(
              controller: nameController,
              autofocus: true,
              label: Translations.name,
              hint: getSubjectHint(),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                EasyFormField(
                  controller: coeffController,
                  label: Translations.coefficient,
                  hint: "1",
                  numeric: true,
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}