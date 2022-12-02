// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../Calculations/calculator.dart';
import '../../Translations/translations.dart';

class EasyFormField extends StatelessWidget {
  const EasyFormField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    this.numeric = false,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
    this.textInputAction = TextInputAction.done,
  }) : super(key: key);

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool autofocus;
  final TextAlign textAlign;
  final bool numeric;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: TextFormField(
        controller: controller,
        textInputAction: textInputAction,
        autofocus: autofocus,
        autovalidateMode: numeric ? AutovalidateMode.onUserInteraction : null,
        keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : null,
        textAlign: textAlign,
        textCapitalization: TextCapitalization.sentences,
        validator: numeric
            ? (String? input) {
                if (input == null || input.isEmpty || Calculator.tryParse(input) != null) {
                  return null;
                }
                return Translations.invalid;
              }
            : null,
        decoration: inputDecoration(context, labelText: label, hintText: hint),
      ),
    );
  }
}

InputDecoration inputDecoration(context, {String? hintText, String? labelText}) {
  return InputDecoration(
    hintText: hintText,
    labelText: labelText,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary),
      borderRadius: BorderRadius.circular(16.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 2, color: Theme.of(context).colorScheme.primary),
      borderRadius: BorderRadius.circular(8.0),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.error),
      borderRadius: BorderRadius.circular(16.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 2, color: Theme.of(context).colorScheme.error),
      borderRadius: BorderRadius.circular(8.0),
    ),
  );
}
