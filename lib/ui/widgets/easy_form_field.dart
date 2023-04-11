// Dart imports:
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../calculations/calculator.dart';
import '../../localization/translations.dart';

class EasyFormField extends StatelessWidget {
  const EasyFormField({
    Key? key,
    required this.controller,
    this.label,
    this.hint,
    this.numeric = false,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
    this.textInputAction = TextInputAction.done,
    this.onSaved,
    this.onSubmitted,
    this.additionalValidator,
    this.signed = true,
    this.focusNode,
  }) : super(key: key);

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final bool autofocus;
  final TextAlign textAlign;
  final bool numeric;
  final TextInputAction textInputAction;
  final void Function(String?)? onSaved;
  final void Function()? onSubmitted;
  final String? Function(String)? additionalValidator;
  final bool signed;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: textInputAction,
      autofocus: autofocus,
      autovalidateMode: numeric || additionalValidator != null ? AutovalidateMode.onUserInteraction : null,
      keyboardType: numeric ? TextInputType.numberWithOptions(decimal: true, signed: Platform.isIOS ? false : signed) : TextInputType.text,
      textAlign: textAlign,
      textCapitalization: TextCapitalization.sentences,
      validator: (String? input) {
        if (input != null && input.isNotEmpty) {
          if (numeric && Calculator.tryParse(input) == null) {
            return translations.invalid;
          }
        }
        return additionalValidator?.call(input!);
      },
      decoration: inputDecoration(context, labelText: label, hintText: hint),
      onSaved: onSaved,
      onEditingComplete: onSubmitted,
      focusNode: focusNode,
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
