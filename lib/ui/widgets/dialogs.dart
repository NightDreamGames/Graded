// Flutter imports:
import "package:flutter/material.dart";

// Project imports:
import "package:graded/calculations/calculator.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/calculations/test.dart";
import "package:graded/localization/translations.dart";
import "package:graded/misc/default_values.dart";
import "package:graded/misc/enums.dart";
import "package:graded/ui/settings/flutter_settings_screens.dart";
import "package:graded/ui/utilities/hints.dart";
import "package:graded/ui/utilities/misc_utilities.dart";
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
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: AlertDialog(
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
          ),
        ],
        content: Form(
          key: formKey,
          child: widget.child,
        ),
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

Future<void> showTestDialog(BuildContext context, Subject subject, {int? index}) {
  return showDialog(
    context: context,
    builder: (context) {
      return TestDialog(
        subject: subject,
        index: index,
      );
    },
  );
}

class TestDialog extends StatefulWidget {
  const TestDialog({
    super.key,
    required this.subject,
    this.index,
  });

  final Subject subject;
  final int? index;

  @override
  State<TestDialog> createState() => _TestDialogState();
}

class _TestDialogState extends State<TestDialog> {
  final nameController = TextEditingController();
  final gradeController = TextEditingController();
  final maximumController = TextEditingController();
  final weightController = TextEditingController();

  final GlobalKey<EasyDialogState> dialogKey = GlobalKey<EasyDialogState>();

  late CreationType action;
  late bool isSpeaking;
  late int? timestamp;

  @override
  void initState() {
    super.initState();
    action = widget.index == null ? CreationType.add : CreationType.edit;
    nameController.text = action == CreationType.edit ? widget.subject.tests[widget.index!].name : "";
    gradeController.text = action == CreationType.edit ? Calculator.format(widget.subject.tests[widget.index!].numerator, addZero: false) : "";
    maximumController.text =
        action == CreationType.edit ? Calculator.format(widget.subject.tests[widget.index!].denominator, addZero: false, roundToOverride: 1) : "";
    weightController.text = action == CreationType.edit ? Calculator.format(widget.subject.tests[widget.index!].weight, addZero: false) : "";
    isSpeaking = action == CreationType.edit && widget.subject.tests[widget.index!].isSpeaking;
    timestamp = widget.index != null ? widget.subject.tests[widget.index!].timestamp : null;
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    gradeController.dispose();
    maximumController.dispose();
    weightController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EasyDialog(
      key: dialogKey,
      title: action == CreationType.add ? translations.add_test : translations.edit_test,
      icon: action == CreationType.add ? Icons.add : Icons.edit,
      bottomPadding: 0,
      onConfirm: () {
        final String name = nameController.text.isEmpty ? getHint(translations.testOne, widget.subject.tests) : nameController.text;
        final double numerator = Calculator.tryParse(gradeController.text) ?? 1;
        final double denominator = Calculator.tryParse(maximumController.text) ?? getCurrentYear().maxGrade;
        final double weight = Calculator.tryParse(weightController.text) ?? DefaultValues.weight;

        if (action == CreationType.add) {
          widget.subject.addTest(Test(numerator, denominator, name: name, weight: weight, isSpeaking: isSpeaking, timestamp: timestamp));
        } else {
          widget.subject.editTest(widget.index!, numerator, denominator, name, weight, isSpeaking: isSpeaking, timestamp: timestamp);
        }

        return true;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EasyFormField(
            controller: nameController,
            label: translations.name,
            hint: getHint(translations.testOne, widget.subject.tests),
            textInputAction: TextInputAction.next,
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              EasyFormField(
                controller: gradeController,
                label: translations.gradeOne,
                hint: "01",
                textAlign: TextAlign.end,
                autofocus: true,
                numeric: true,
                textInputAction: TextInputAction.next,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 18),
                child: Text("/", style: TextStyle(fontSize: 20)),
              ),
              EasyFormField(
                controller: maximumController,
                label: translations.maximum,
                hint: Calculator.format(getCurrentYear().maxGrade, roundToOverride: 1),
                numeric: true,
                signed: false,
                additionalValidator: (value) => thresholdValidator(value, inclusive: false),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
          ),
          EasyFormField(
            controller: weightController,
            label: translations.coefficientOne,
            hint: Calculator.format(DefaultValues.weight, addZero: false, roundToOverride: 1),
            numeric: true,
            signed: false,
            onSubmitted: () => dialogKey.currentState?.submit(),
            additionalValidator: (value) => thresholdValidator(value, inclusive: false),
          ),
          const Padding(
            padding: EdgeInsets.all(4.0),
          ),
          SizedBox(
            height: 56,
            child: Row(
              children: [
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
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: VerticalDivider(
                    indent: 10,
                    endIndent: 10,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_month),
                  tooltip: translations.select_date,
                  onPressed: () {
                    final DateTime now = DateTime.now();
                    showDatePicker(
                      context: context,
                      initialDate: timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp!) : DateTime(now.year, now.month, now.day),
                      firstDate: DateTime(1970),
                      lastDate: DateTime(2100),
                    ).then((value) => timestamp = value?.millisecondsSinceEpoch ?? DateTime(2021, 9, 15).millisecondsSinceEpoch);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showSubjectDialog(BuildContext context, {int? index1, int? index2}) {
  return showDialog(
    context: context,
    builder: (context) {
      return SubjectDialog(index1: index1, index2: index2);
    },
  );
}

class SubjectDialog extends StatefulWidget {
  const SubjectDialog({
    super.key,
    this.index1,
    this.index2,
  });

  final int? index1;
  final int? index2;

  @override
  State<SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends State<SubjectDialog> {
  final nameController = TextEditingController();
  final weightController = TextEditingController();
  final speakingController = TextEditingController();

  final GlobalKey<EasyDialogState> dialogKey = GlobalKey<EasyDialogState>();

  late CreationType action;
  late Subject subject;

  @override
  void initState() {
    super.initState();
    action = widget.index1 == null ? CreationType.add : CreationType.edit;
    subject = action == CreationType.add
        ? Subject("", 0, 0)
        : widget.index2 == null
            ? getCurrentYear().termTemplate[widget.index1!]
            : getCurrentYear().termTemplate[widget.index1!].children[widget.index2!];
    nameController.text = action == CreationType.edit ? subject.name : "";
    weightController.text = action == CreationType.edit ? Calculator.format(subject.weight, addZero: false, roundToOverride: 1) : "";
    speakingController.text = action == CreationType.edit ? Calculator.format(subject.speakingWeight + 1, addZero: false, roundToOverride: 1) : "";
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    weightController.dispose();
    speakingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EasyDialog(
      key: dialogKey,
      title: action == CreationType.add ? translations.add_subjectOne : translations.edit_subjectOne,
      icon: action == CreationType.add ? Icons.add : Icons.edit,
      onConfirm: () {
        final String name = nameController.text.isEmpty ? getHint(translations.subjectOne, getCurrentYear().termTemplate) : nameController.text;
        final double weight = Calculator.tryParse(weightController.text) ?? 1.0;

        double speakingWeight = Calculator.tryParse(speakingController.text) ?? (DefaultValues.speakingWeight) + 1;
        speakingWeight--;
        if (speakingWeight <= 0) speakingWeight = 1;

        if (action == CreationType.add) {
          getCurrentYear().addSubject(Subject(name, weight, speakingWeight));
        } else {
          getCurrentYear().editSubject(subject, name, weight, speakingWeight);
        }

        Manager.calculate();
        return true;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EasyFormField(
            controller: nameController,
            autofocus: true,
            label: translations.name,
            hint: getHint(translations.subjectOne, getCurrentYear().termTemplate),
            textInputAction: TextInputAction.next,
            additionalValidator: (newValue) {
              if (getCurrentYear().termTemplate.any((element) {
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
          const Padding(
            padding: EdgeInsets.all(8.0),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              EasyFormField(
                controller: weightController,
                label: translations.coefficientOne,
                hint: Calculator.format(DefaultValues.weight, addZero: false, roundToOverride: 1),
                numeric: true,
                textInputAction: TextInputAction.next,
                additionalValidator: thresholdValidator,
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
              EasyFormField(
                controller: speakingController,
                label: translations.speaking_weight,
                hint: Calculator.format((DefaultValues.speakingWeight) + 1, addZero: false, roundToOverride: 1),
                numeric: true,
                onSubmitted: () => dialogKey.currentState?.submit(),
                additionalValidator: (value) => thresholdValidator(value, threshold: 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
