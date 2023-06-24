// Flutter imports:
import "package:flutter/material.dart";

// Project imports:
import "package:graded/calculations/calculator.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/calculations/term.dart";
import "package:graded/calculations/test.dart";
import "package:graded/localization/translations.dart";
import "package:graded/misc/default_values.dart";
import "package:graded/misc/enums.dart";
import "package:graded/misc/storage.dart";
import "package:graded/ui/settings/flutter_settings_screens.dart";
import "package:graded/ui/utilities/hints.dart";
import "package:graded/ui/widgets/easy_form_field.dart";

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
  final double bottomPadding;

  const EasyDialog({
    super.key,
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
    this.action,
    this.bottomPadding = 20,
  });

  @override
  State<EasyDialog> createState() => EasyDialogState();
}

class EasyDialogState extends State<EasyDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
      contentPadding: EdgeInsets.only(left: 24, top: 16, right: 24, bottom: widget.bottomPadding),
      semanticLabel: widget.title,
      title: Text(widget.title),
      scrollable: true,
      icon: widget.icon != null ? Icon(widget.icon) : null,
      elevation: 3,
      actions: [
        TextButton(
          onPressed: () {
            widget.onCancel?.call();
            _disposeDialog(context);
          },
          child: Text(
            translations.cancel,
          ),
        ),
        TextButton(
          onPressed: () async {
            submit();
          },
          child: Text(
            widget.action ?? translations.save,
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
    bool closeDialog = true;

    bool submitText() {
      bool isValid = true;
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

Future<void> showTestDialog(
  BuildContext context,
  Subject subject,
  TextEditingController nameController,
  TextEditingController gradeController,
  TextEditingController maximumController, {
  int? index,
}) async {
  gradeController.clear();
  maximumController.clear();
  nameController.clear();

  CreationType action = index == null ? CreationType.add : CreationType.edit;

  gradeController.text = action == CreationType.edit ? Calculator.format(subject.tests[index!].numerator, addZero: false) : "";
  maximumController.text =
      action == CreationType.edit ? Calculator.format(subject.tests[index!].denominator, addZero: false, roundToOverride: 1) : "";
  nameController.text = action == CreationType.edit ? subject.tests[index!].name : "";
  bool isSpeaking = action == CreationType.edit && subject.tests[index!].isSpeaking;

  return showDialog(
    context: context,
    builder: (context) {
      final GlobalKey<EasyDialogState> dialogKey = GlobalKey<EasyDialogState>();

      return StatefulBuilder(
        builder: (context, setState) {
          return EasyDialog(
            key: dialogKey,
            title: action == CreationType.add ? translations.add_test : translations.edit_test,
            icon: action == CreationType.add ? Icons.add : Icons.edit,
            bottomPadding: 0,
            onConfirm: () {
              String name = nameController.text.isEmpty ? getHint(translations.test, subject.tests) : nameController.text;
              double numerator = Calculator.tryParse(gradeController.text) ?? 1;
              double denominator = Calculator.tryParse(maximumController.text) ?? getPreference<double>("total_grades");

              if (action == CreationType.add) {
                subject.addTest(Test(numerator, denominator, name: name, isSpeaking: isSpeaking));
              } else {
                subject.editTest(index!, numerator, denominator, name, isSpeaking: isSpeaking);
              }

              return true;
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: EasyFormField(
                    controller: nameController,
                    label: translations.name,
                    hint: getHint(translations.test, subject.tests),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: EasyFormField(
                        controller: gradeController,
                        label: translations.gradeOne,
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
                        controller: maximumController,
                        label: translations.maximum,
                        hint: Calculator.format(getPreference<double>("total_grades"), roundToOverride: 1),
                        numeric: true,
                        signed: false,
                        onSubmitted: () {
                          dialogKey.currentState?.submit();
                        },
                        additionalValidator: (newValue) {
                          double? number = Calculator.tryParse(newValue);

                          if (number != null && number <= 0) {
                            return translations.invalid;
                          }

                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(4.0),
                ),
                Flexible(
                  child: CheckboxListTile(
                    value: isSpeaking,
                    onChanged: (value) {
                      isSpeaking = value ?? false;
                      setState(() {});
                    },
                    title: Text(
                      translations.speaking,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      );
    },
  );
}

Future<void> showSubjectDialog(
  BuildContext context,
  TextEditingController nameController,
  TextEditingController coeffController,
  TextEditingController speakingController, {
  int? index,
  int? index2,
}) async {
  coeffController.clear();
  nameController.clear();
  speakingController.clear();

  CreationType action = index == null ? CreationType.add : CreationType.edit;

  Subject subject = action == CreationType.add
      ? Subject("", 0, 0)
      : index2 == null
          ? Manager.termTemplate[index!]
          : Manager.termTemplate[index!].children[index2];
  coeffController.text = action == CreationType.edit ? Calculator.format(subject.coefficient, addZero: false, roundToOverride: 1) : "";
  nameController.text = action == CreationType.edit ? subject.name : "";
  speakingController.text = action == CreationType.edit ? Calculator.format(subject.speakingWeight + 1, addZero: false) : "";

  final GlobalKey<EasyDialogState> dialogKey = GlobalKey<EasyDialogState>();
  return showDialog(
    context: context,
    builder: (context) {
      return EasyDialog(
        key: dialogKey,
        title: action == CreationType.add ? translations.add_subjectOne : translations.edit_subjectOne,
        icon: action == CreationType.add ? Icons.add : Icons.edit,
        onConfirm: () {
          String name = nameController.text.isEmpty ? getHint(translations.subject, Manager.termTemplate) : nameController.text;
          double coefficient = Calculator.tryParse(coeffController.text) ?? 1.0;

          double speakingWeight = Calculator.tryParse(speakingController.text) ?? (defaultValues["speaking_weight"] as double) + 1;
          speakingWeight--;
          if (speakingWeight <= 0) speakingWeight = 1;

          if (action == CreationType.add) {
            List<List<Subject>> lists = [Manager.termTemplate];
            lists.addAll(Manager.getCurrentYear().terms.map((term) => term.subjects));

            for (final List<Subject> t in lists) {
              t.add(Subject(name, coefficient, speakingWeight));
            }
          } else {
            Manager.sortAll(
              sortModeOverride: SortMode.name,
              sortDirectionOverride: SortDirection.ascending,
            );

            subject.name = name;
            subject.coefficient = coefficient;
            subject.speakingWeight = speakingWeight;

            for (final Term t in Manager.getCurrentYear().terms) {
              for (int i = 0; i < t.subjects.length; i++) {
                Subject s = t.subjects[i];
                Subject template = Manager.termTemplate[i];

                s.name = template.name;
                s.coefficient = template.coefficient;
                s.speakingWeight = template.speakingWeight;
                for (int j = 0; j < t.subjects[i].children.length; j++) {
                  s.children[j].name = template.children[j].name;
                  s.children[j].coefficient = template.children[j].coefficient;
                  s.children[j].speakingWeight = template.children[j].speakingWeight;
                }
              }
            }
          }

          Manager.calculate();

          return true;
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: EasyFormField(
                controller: nameController,
                autofocus: true,
                label: translations.name,
                hint: getHint(translations.subject, Manager.termTemplate),
                textInputAction: TextInputAction.next,
                additionalValidator: (newValue) {
                  if (Manager.termTemplate.any((element) {
                    if (action == CreationType.edit && element == subject) {
                      return false;
                    }
                    if (element.children.any((child) {
                      if (action == CreationType.edit && child == subject) {
                        return false;
                      }
                      return child.name == newValue;
                    })) {
                      return true;
                    }
                    return element.name == newValue;
                  })) {
                    return translations.enter_unique;
                  }
                  return null;
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: EasyFormField(
                    controller: coeffController,
                    label: translations.coefficientOne,
                    hint: "1",
                    numeric: true,
                    textInputAction: TextInputAction.next,
                    additionalValidator: (newValue) {
                      double? number = Calculator.tryParse(newValue);

                      if (number != null && number < 0) {
                        return translations.invalid;
                      }

                      return null;
                    },
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 18),
                  child: Row(
                    children: [
                      Text("1 /", style: TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
                Flexible(
                  child: EasyFormField(
                    controller: speakingController,
                    label: translations.speaking_weight,
                    hint: Calculator.format((defaultValues["speaking_weight"] as double) + 1, addZero: false),
                    numeric: true,
                    onSubmitted: () {
                      dialogKey.currentState?.submit();
                    },
                    additionalValidator: (newValue) {
                      double? number = Calculator.tryParse(newValue);

                      if (number != null && number < 1) {
                        return translations.invalid;
                      }

                      return null;
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
