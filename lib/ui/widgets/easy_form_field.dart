// Flutter imports:
import "package:flutter/material.dart";

// Project imports:
import "package:graded/calculations/calculator.dart";
import "package:graded/localization/translations.dart";
import "package:graded/ui/utilities/misc_utilities.dart";

class EasyFormField extends StatelessWidget {
  const EasyFormField({
    super.key,
    this.controller,
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
    this.flexible = true,
  });

  final TextEditingController? controller;
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
  final bool flexible;

  @override
  Widget build(BuildContext context) {
    final Widget formField = TextFormField(
      controller: controller,
      textInputAction: textInputAction,
      autofocus: autofocus,
      autovalidateMode: numeric || additionalValidator != null ? AutovalidateMode.onUserInteraction : null,
      keyboardType: numeric ? TextInputType.numberWithOptions(decimal: true, signed: !isiOS && signed) : TextInputType.text,
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
      decoration: inputDecoration(labelText: label, hintText: hint),
      onSaved: onSaved,
      onEditingComplete: onSubmitted,
      focusNode: focusNode,
    );

    return flexible ? Flexible(child: formField) : formField;
  }
}

InputDecoration inputDecoration({String? hintText, String? labelText}) {
  return InputDecoration(
    hintText: hintText,
    labelText: labelText,
  );
}
