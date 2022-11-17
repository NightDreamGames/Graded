// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../Translation/translations.dart';

class EasyFormField extends StatelessWidget {
  const EasyFormField({
    Key? key,
    required TextEditingController controller,
    required String label,
    required String hint,
    bool numeric = false,
    bool autofocus = false,
    TextAlign textAlign = TextAlign.start,
  })  : _controller = controller,
        _label = label,
        _hint = hint,
        _autofocus = autofocus,
        _textAlign = textAlign,
        _numeric = numeric,
        super(key: key);

  final TextEditingController _controller;
  final String _label;
  final String _hint;
  final bool _autofocus;
  final TextAlign _textAlign;
  final bool _numeric;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: TextFormField(
        controller: _controller,
        autofocus: _autofocus,
        autovalidateMode: _numeric ? AutovalidateMode.onUserInteraction : null,
        keyboardType: _numeric ? const TextInputType.numberWithOptions(decimal: true) : null,
        textAlign: _textAlign,
        textCapitalization: TextCapitalization.sentences,
        validator: _numeric
            ? (String? input) {
                if (input == null || input.isEmpty || double.tryParse(input) != null) {
                  return null;
                }
                return Translations.invalid;
              }
            : null,
        decoration: inputDecoration(context, labelText: _label, hintText: _hint),
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
