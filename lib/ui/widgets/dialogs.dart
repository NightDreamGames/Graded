// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:decimal/decimal.dart";

// Project imports:
import "package:graded/calculations/calculator.dart";
import "package:graded/ui/utilities/grade_display_value.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/calculations/term.dart";
import "package:graded/calculations/test.dart";
import "package:graded/l10n/translations.dart";
import "package:graded/misc/default_values.dart";
import "package:graded/misc/enums.dart";
import "package:graded/ui/settings/flutter_settings_screens.dart";
import "package:graded/ui/utilities/haptics.dart";
import "package:graded/ui/utilities/hints.dart";
import "package:graded/ui/utilities/misc_utilities.dart";
import "package:graded/ui/widgets/easy_form_field.dart";
import "package:graded/ui/widgets/misc_widgets.dart";

class EasyDialog extends StatefulWidget {
  final String title;
  final IconData? icon;
  final Widget child;
  final VoidCallback? onCancel;
  final OnConfirmedCallback? onConfirm;
  final String? action;
  final double bottomPadding;

  const EasyDialog({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.onCancel,
    this.onConfirm,
    this.action,
    this.bottomPadding = 20,
  });

  @override
  State<EasyDialog> createState() => EasyDialogState();
}

class EasyDialogState extends State<EasyDialog> {
  @override
  void initState() {
    super.initState();
    lightHaptics();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          padding: MediaQuery.paddingOf(context).copyWith(
            bottom: MediaQuery.viewPaddingOf(context).bottom,
          ),
        ),
        child: GestureDetector(
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
                onPressed: () {
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
        lightHaptics();
        return true;
      }

      heavyHaptics();
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

Future<void> showTestDialog(BuildContext context, Term term, {Test? test}) {
  return showDialog(
    context: context,
    useSafeArea: false,
    builder: (context) {
      return TestDialog(
        term: term,
        test: test,
      );
    },
  );
}

Future<void> showResetConfirmDialog(BuildContext context) {
  return showDialog(
    context: context,
    useSafeArea: false,
    builder: (context) {
      return EasyDialog(
        title: translations.confirm,
        icon: Icons.clear_all,
        action: translations.confirm,
        onConfirm: () {
          heavyHaptics();
          Manager.clearTests();
          Navigator.pop(context);
          return true;
        },
        child: Text(translations.reset_confirm),
      );
    },
  );
}

class TestDialog extends StatefulWidget {
  const TestDialog({
    super.key,
    required this.term,
    this.test,
  });

  final Term term;
  final Test? test;

  @override
  State<TestDialog> createState() => _TestDialogState();
}

class _TestDialogState extends State<TestDialog> with TickerProviderStateMixin {
  final nameController = TextEditingController();
  final gradeController = TextEditingController();
  final maximumController = TextEditingController();
  final weightController = TextEditingController();
  late final AnimationController animationController;
  late final Animation<double> expandAnimation;

  final GlobalKey<EasyDialogState> dialogKey = GlobalKey<EasyDialogState>();
  final FocusNode weightFocus = FocusNode();

  late final CreationType action;
  late bool isSpeaking;
  late int? timestamp;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    action = widget.test == null ? CreationType.add : CreationType.edit;
    nameController.text = action == CreationType.edit ? widget.test!.name : "";
    gradeController.text = action == CreationType.edit ? Calculator.format(widget.test!.numerator, leadingZero: false) : "";
    maximumController.text = action == CreationType.edit ? Calculator.format(widget.test!.denominator, leadingZero: false, roundToOverride: 1) : "";
    weightController.text = action == CreationType.edit ? Calculator.format(widget.test!.weight, leadingZero: false) : "";
    isSpeaking = action == CreationType.edit && widget.test!.isSpeaking;
    timestamp = widget.test?.timestamp;

    animationController = AnimationController(duration: Durations.long2, reverseDuration: Durations.medium2, vsync: this);
    expandAnimation = CurvedAnimation(parent: animationController, curve: Easing.standard, reverseCurve: Easing.standard.flipped);
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
        final String name = nameController.text.isEmpty ? getHint(translations.testOne, widget.term.tests) : nameController.text;
        final double numerator = Calculator.tryParse(gradeController.text) ?? 1;
        final double denominator = Calculator.tryParse(maximumController.text) ?? getCurrentYear().maxGrade;
        final double weight = Calculator.tryParse(weightController.text) ?? DefaultValues.weight;

        if (action == CreationType.add) {
          widget.term.addTest(Test(numerator, denominator, name: name, weight: weight, isSpeaking: isSpeaking, timestamp: timestamp));
        } else {
          widget.term.editTest(widget.test!, numerator, denominator, name, weight, isSpeaking: isSpeaking, timestamp: timestamp);
        }

        return true;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EasyFormField(
            controller: nameController,
            label: translations.name,
            hint: getHint(translations.testOne, widget.term.tests),
            textInputAction: TextInputAction.next,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 16),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              EasyFormField(
                controller: gradeController,
                label: translations.gradeOne,
                hint: Calculator.format(1),
                textAlign: TextAlign.end,
                autofocus: true,
                numeric: true,
                textInputAction: TextInputAction.next,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "/",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              EasyFormField(
                controller: maximumController,
                label: translations.max,
                hint: Calculator.format(getCurrentYear().maxGrade, roundToOverride: 1),
                numeric: true,
                signed: false,
                textInputAction: isExpanded ? TextInputAction.next : TextInputAction.done,
                onSubmitted: () {
                  if (isExpanded) {
                    FocusScope.of(context).requestFocus(weightFocus);
                  } else {
                    dialogKey.currentState?.submit();
                  }
                },
                additionalValidator: (value) => thresholdValidator(value, inclusive: false),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: AnimatedRotation(
                  turns: isExpanded ? .5 : 0,
                  duration: Durations.short4,
                  child: IconButton(
                    onPressed: () {
                      lightHaptics();
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                      if (expandAnimation.status == AnimationStatus.reverse || expandAnimation.isDismissed) {
                        animationController.forward();
                      } else {
                        animationController.reverse();
                      }
                    },
                    color: isExpanded ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    icon: const Icon(Icons.expand_more),
                    tooltip: translations.expand,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
          ),
          SizeTransition(
            sizeFactor: expandAnimation,
            axisAlignment: -1,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                ),
                EasyFormField(
                  controller: weightController,
                  focusNode: weightFocus,
                  label: translations.coefficientOne,
                  hint: Calculator.format(DefaultValues.weight, leadingZero: false, roundToOverride: 1),
                  numeric: true,
                  signed: false,
                  onSubmitted: () => dialogKey.currentState?.submit(),
                  additionalValidator: (value) => thresholdValidator(value, inclusive: false),
                  flexible: false,
                ),
                const Padding(
                  padding: EdgeInsets.all(4),
                ),
                SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      Flexible(
                        child: Material(
                          borderRadius: BorderRadius.circular(8),
                          clipBehavior: Clip.antiAlias,
                          color: Colors.transparent,
                          child: CheckboxListTile(
                            value: isSpeaking,
                            onChanged: (value) {
                              isSpeaking = value ?? false;
                              setState(() {});
                            },
                            title: Text(
                              translations.speaking,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
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
                          ).then((value) => timestamp = value?.millisecondsSinceEpoch ?? DateTime(2023, 9, 15).millisecondsSinceEpoch);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showSubjectDialog(BuildContext context, {Subject? subject, CreationType action = CreationType.add}) {
  return showDialog(
    context: context,
    useSafeArea: false,
    builder: (context) {
      return SubjectDialog(subject: subject, action: action);
    },
  );
}

class SubjectDialog extends StatefulWidget {
  const SubjectDialog({
    super.key,
    this.subject,
    this.action = CreationType.add,
  }) : assert(action != CreationType.edit || subject != null);

  final Subject? subject;
  final CreationType action;

  @override
  State<SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends State<SubjectDialog> {
  final nameController = TextEditingController();
  final weightController = TextEditingController();
  final speakingController = TextEditingController();

  final GlobalKey<EasyDialogState> dialogKey = GlobalKey<EasyDialogState>();

  late final Subject subject;
  bool confirmed = false;

  @override
  void initState() {
    super.initState();
    subject = widget.subject ?? Subject("", 0);
    nameController.text = widget.action == CreationType.edit ? subject.name : "";
    weightController.text = widget.action == CreationType.edit ? Calculator.format(subject.weight, leadingZero: false, roundToOverride: 1) : "";
    speakingController.text =
        widget.action == CreationType.edit ? Calculator.format(subject.speakingWeight + 1, leadingZero: false, roundToOverride: 1) : "";
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
      title: widget.action == CreationType.add ? translations.add_subjectOne : translations.edit_subjectOne,
      icon: widget.action == CreationType.add ? Icons.add : Icons.edit,
      onConfirm: () {
        final String name = nameController.text.isEmpty ? getHint(translations.subjectOne, getCurrentYear().subjects) : nameController.text;
        final double weight = Calculator.tryParse(weightController.text) ?? 1;

        double speakingWeight = Calculator.tryParse(speakingController.text) ?? (DefaultValues.speakingWeight) + 1;
        speakingWeight--;
        if (speakingWeight <= 0) speakingWeight = 1;

        if (widget.action == CreationType.add) {
          getCurrentYear().addSubject(Subject(name, weight, speakingWeight: speakingWeight));
        } else {
          getCurrentYear().editSubject(subject, name, weight, speakingWeight);
        }

        Manager.calculate();
        confirmed = true;
        return true;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EasyFormField(
            controller: nameController,
            autofocus: true,
            label: translations.name,
            hint: getHint(translations.subjectOne, getCurrentYear().subjects),
            textInputAction: TextInputAction.next,
            additionalValidator: (newValue) {
              if (confirmed) return null;

              final bool isDuplicate = getCurrentYear().subjects.any((element) {
                final bool isParent = element == subject;
                final bool isChild = element.children.contains(subject);
                final bool sameAsParent = element.name == newValue;
                final bool sameAsChild = element.children.any((child) => child.name == newValue);

                if (isParent && sameAsParent) return false;
                if (isChild && sameAsChild) return false;
                if (sameAsChild || sameAsParent) return true;

                return false;
              });

              return isDuplicate ? translations.enter_unique : null;
            },
          ),
          const Padding(
            padding: EdgeInsets.all(8),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              EasyFormField(
                controller: weightController,
                label: translations.coefficientOne,
                hint: Calculator.format(DefaultValues.weight, leadingZero: false, roundToOverride: 1),
                numeric: true,
                textInputAction: TextInputAction.next,
                additionalValidator: thresholdValidator,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.all(8),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 18),
                child: Row(
                  children: [
                    Text(
                      "1 /",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
              EasyFormField(
                controller: speakingController,
                label: translations.speaking_weight,
                hint: Calculator.format((DefaultValues.speakingWeight) + 1, leadingZero: false, roundToOverride: 1),
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

Future<void> showBonusDialog(BuildContext context, Term term) {
  return showDialog(
    context: context,
    useSafeArea: false,
    builder: (context) {
      return BonusDialog(term: term);
    },
  );
}

class BonusDialog extends StatefulWidget {
  const BonusDialog({
    super.key,
    required this.term,
  });

  final Term term;

  @override
  State<BonusDialog> createState() => _BonusDialogState();
}

class _BonusDialogState extends State<BonusDialog> {
  final bonusController = TextEditingController();

  final GlobalKey<EasyDialogState> dialogKey = GlobalKey<EasyDialogState>();

  @override
  void initState() {
    super.initState();
    bonusController.text = Calculator.format(widget.term.bonus, leadingZero: false);
  }

  @override
  void dispose() {
    super.dispose();
    bonusController.dispose();
  }

  void changeBonus(int multiplier) {
    final double? bonus = Calculator.tryParse(bonusController.text);
    if (bonus == null) {
      heavyHaptics();
      return;
    }
    lightHaptics();

    final newBonus = Decimal.parse(bonus.toString()) + Decimal.fromInt(multiplier) * Decimal.one;

    bonusController.text = Calculator.format(
      newBonus.toDouble(),
      leadingZero: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return EasyDialog(
      key: dialogKey,
      title: translations.bonus,
      icon: Icons.plus_one,
      onConfirm: () {
        final double bonus = Calculator.tryParse(bonusController.text) ?? 0;
        widget.term.bonus = bonus;

        Manager.calculate();
        return true;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              EasyFormField(
                controller: bonusController,
                label: translations.bonus,
                hint: Calculator.format(DefaultValues.bonus, leadingZero: false, roundToOverride: 1),
                numeric: true,
                onSubmitted: () => dialogKey.currentState?.submit(),
                autofocus: true,
              ),
              const Padding(padding: EdgeInsets.only(left: 8)),
              IconButton(
                tooltip: translations.decrease,
                icon: const Icon(Icons.remove, size: 20),
                onPressed: () => changeBonus(-1),
                style: getTonalButtonStyle(context),
              ),
              IconButton(
                tooltip: translations.increase,
                icon: const Icon(Icons.add, size: 20),
                onPressed: () => changeBonus(1),
                style: getTonalButtonStyle(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> showGradeMappingDialog(BuildContext context, {GradeMapping? gradeMapping, CreationType action = CreationType.add}) {
  return showDialog(
    context: context,
    useSafeArea: false,
    builder: (context) {
      return GradeMappingDialog(gradeMapping: gradeMapping, action: action);
    },
  );
}

class GradeMappingDialog extends StatefulWidget {
  const GradeMappingDialog({
    super.key,
    this.gradeMapping,
    this.action = CreationType.add,
  }) : assert(action != CreationType.edit || gradeMapping != null);

  final GradeMapping? gradeMapping;
  final CreationType action;

  @override
  State<GradeMappingDialog> createState() => _GradeMappingDialogState();
}

class _GradeMappingDialogState extends State<GradeMappingDialog> {
  final nameController = TextEditingController();
  final minController = TextEditingController();
  final maxController = TextEditingController();

  final GlobalKey<EasyDialogState> dialogKey = GlobalKey<EasyDialogState>();

  late final GradeMapping gradeMapping;
  bool confirmed = false;

  @override
  void initState() {
    super.initState();
    gradeMapping = widget.gradeMapping ?? GradeMapping(0, 0, "");
    nameController.text = widget.action == CreationType.edit ? gradeMapping.name : "";
    minController.text = widget.action == CreationType.edit ? Calculator.format(gradeMapping.min, leadingZero: false, roundToOverride: 1) : "";
    maxController.text = widget.action == CreationType.edit ? Calculator.format(gradeMapping.max, leadingZero: false, roundToOverride: 1) : "";
  }

  @override
  void dispose() {
    super.dispose();
    minController.dispose();
    maxController.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EasyDialog(
      key: dialogKey,
      title: widget.action == CreationType.add ? translations.add_mapping : translations.edit_mapping,
      icon: widget.action == CreationType.add ? Icons.add : Icons.edit,
      onConfirm: () {
        final String name = nameController.text;
        final double min = Calculator.tryParse(minController.text) ?? 0;
        final double max = Calculator.tryParse(maxController.text) ?? getCurrentYear().maxGrade;

        if (widget.action == CreationType.add) {
          getCurrentYear().gradeMappings.add(GradeMapping(min, max, name));
        } else {
          getCurrentYear().gradeMappings[getCurrentYear().gradeMappings.indexOf(gradeMapping)] = GradeMapping(min, max, name);
        }

        Manager.calculate();
        confirmed = true;
        return true;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EasyFormField(
            controller: nameController,
            autofocus: true,
            label: translations.name,
            textInputAction: TextInputAction.next,
          ),
          const Padding(
            padding: EdgeInsets.all(8),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              EasyFormField(
                controller: minController,
                label: translations.min,
                hint: Calculator.format(0, leadingZero: false, roundToOverride: 1),
                numeric: true,
                textInputAction: TextInputAction.next,
              ),
              const Padding(
                padding: EdgeInsets.all(8),
              ),
              EasyFormField(
                controller: maxController,
                label: translations.max,
                hint: Calculator.format(getCurrentYear().maxGrade, leadingZero: false, roundToOverride: 1),
                numeric: true,
                onSubmitted: () => dialogKey.currentState?.submit(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
