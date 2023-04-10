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
import '../Utilities/misc_utilities.dart';
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
  final double bottomPadding;

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
    this.bottomPadding = 20,
  }) : super(key: key);

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

Future<void> showTestDialog(BuildContext context, Subject subject, TextEditingController nameController, TextEditingController gradeController,
    TextEditingController maximumController,
    {int? index}) async {
  gradeController.clear();
  maximumController.clear();
  nameController.clear();

  MenuAction action = index == null ? MenuAction.add : MenuAction.edit;

  index == null;
  gradeController.text = action == MenuAction.edit ? Calculator.format(subject.tests[index!].numerator, addZero: false) : "";
  maximumController.text = action == MenuAction.edit ? Calculator.format(subject.tests[index!].denominator, addZero: false, roundToOverride: 1) : "";
  nameController.text = action == MenuAction.edit ? subject.tests[index!].name : "";
  bool isSpeaking = action == MenuAction.edit ? subject.tests[index!].isSpeaking : false;

  return showDialog(
    context: context,
    builder: (context) {
      final GlobalKey<EasyDialogState> dialogKey = GlobalKey<EasyDialogState>();

      return StatefulBuilder(builder: (context, setState) {
        return EasyDialog(
          key: dialogKey,
          title: action == MenuAction.add ? Translations.add_test : Translations.edit_test,
          icon: action == MenuAction.add ? Icons.add : Icons.edit,
          bottomPadding: 0,
          onConfirm: () {
            String name = nameController.text.isEmpty ? getHint(Translations.test, subject.tests) : nameController.text;
            double numerator = Calculator.tryParse(gradeController.text) ?? 1;
            double denominator = Calculator.tryParse(maximumController.text) ?? getPreference<double>("total_grades");

            if (action == MenuAction.add) {
              subject.addTest(Test(numerator, denominator, name: name, isSpeaking: isSpeaking));
            } else {
              subject.editTest(index!, numerator, denominator, name, isSpeaking: isSpeaking);
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
                  hint: getHint(Translations.test, subject.tests),
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
                      controller: maximumController,
                      label: Translations.maximum,
                      hint: Calculator.format(getPreference<double>("total_grades"), roundToOverride: 1),
                      numeric: true,
                      signed: false,
                      onSubmitted: () {
                        if (dialogKey.currentState is EasyDialogState) {
                          (dialogKey.currentState as EasyDialogState).submit();
                        }
                      },
                      additionalValidator: (newValue) {
                        double? number = Calculator.tryParse(newValue);

                        if (number != null && number <= 0) {
                          return Translations.invalid;
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
                    Translations.speaking,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                ),
              )
            ],
          ),
        );
      });
    },
  );
}

Future<void> showSubjectDialog(
    BuildContext context, TextEditingController nameController, TextEditingController coeffController, TextEditingController speakingController,
    {int? index, int? index2}) async {
  coeffController.clear();
  nameController.clear();
  speakingController.clear();

  MenuAction action = index == null ? MenuAction.add : MenuAction.edit;

  Subject subject = action == MenuAction.add
      ? Subject("", 0, 0)
      : index2 == null
          ? Manager.termTemplate[index!]
          : Manager.termTemplate[index!].children[index2];
  coeffController.text = action == MenuAction.edit ? Calculator.format(subject.coefficient, addZero: false, roundToOverride: 1) : "";
  nameController.text = action == MenuAction.edit ? subject.name : "";
  speakingController.text = action == MenuAction.edit ? Calculator.format(subject.speakingWeight + 1, addZero: false) : "";

  final GlobalKey<EasyDialogState> dialogKey = GlobalKey<EasyDialogState>();
  return showDialog(
    context: context,
    builder: (context) {
      return EasyDialog(
        key: dialogKey,
        title: action == MenuAction.add ? Translations.add_subject : Translations.edit_subject,
        icon: action == MenuAction.add ? Icons.add : Icons.edit,
        onConfirm: () {
          String name = nameController.text.isEmpty ? getHint(Translations.subject, Manager.termTemplate) : nameController.text;
          double coefficient = Calculator.tryParse(coeffController.text) ?? 1.0;

          double speakingWeight = Calculator.tryParse(speakingController.text) ?? defaultValues["speaking_weight"] + 1;
          speakingWeight--;
          if (speakingWeight <= 0) speakingWeight = 1;

          if (action == MenuAction.add) {
            Manager.termTemplate.add(Subject(name, coefficient, speakingWeight));

            for (Term t in Manager.getCurrentYear().terms) {
              t.subjects.add(Subject(name, coefficient, speakingWeight));
            }
          } else {
            Manager.sortAll(sortModeOverride: SortMode.name);

            subject.name = name;
            subject.coefficient = coefficient;
            subject.speakingWeight = speakingWeight;

            for (Term t in Manager.getCurrentYear().terms) {
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
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: EasyFormField(
                controller: nameController,
                autofocus: true,
                label: Translations.name,
                hint: getHint(Translations.subject, Manager.termTemplate),
                textInputAction: TextInputAction.next,
                additionalValidator: (newValue) {
                  if (Manager.termTemplate.any((element) {
                    if (action == MenuAction.edit && element == subject) {
                      return false;
                    }
                    if (element.children.any((child) {
                      if (action == MenuAction.edit && child == subject) {
                        return false;
                      }
                      return child.name == newValue;
                    })) {
                      return true;
                    }
                    return element.name == newValue;
                  })) {
                    return Translations.enter_unique;
                  }
                  return null;
                },
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
                    label: Translations.coefficient,
                    hint: "1",
                    numeric: true,
                    textInputAction: TextInputAction.next,
                    additionalValidator: (newValue) {
                      double? number = Calculator.tryParse(newValue);

                      if (number != null && number < 0) {
                        return Translations.invalid;
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
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
                  child: Row(
                    children: const [
                      Text("1 /", style: TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
                Flexible(
                  child: EasyFormField(
                    controller: speakingController,
                    label: Translations.speaking_weight,
                    hint: Calculator.format(defaultValues["speaking_weight"] + 1, addZero: false),
                    numeric: true,
                    onSubmitted: () {
                      if (dialogKey.currentState is EasyDialogState) {
                        (dialogKey.currentState as EasyDialogState).submit();
                      }
                    },
                    additionalValidator: (newValue) {
                      double? number = Calculator.tryParse(newValue);

                      if (number != null && number < 1) {
                        return Translations.invalid;
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
