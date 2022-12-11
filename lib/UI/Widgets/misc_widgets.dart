// Flutter imports:
import 'package:flutter/material.dart';

class AppBarTitle extends StatelessWidget {
  const AppBarTitle({
    Key? key,
    required this.title,
    this.actionAmount = 1,
  }) : super(key: key);

  final String title;
  final int actionAmount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool collapsed = constraints.biggest.height == 64;

        return Padding(
          padding: EdgeInsets.only(left: collapsed ? 48 : 8, right: collapsed ? 48 * actionAmount.toDouble() : 8),
          child: Text(
            title,
            softWrap: false,
            maxLines: 1,
            overflow: TextOverflow.fade,
            style: collapsed ? const TextStyle(fontWeight: FontWeight.bold) : const TextStyle(fontWeight: FontWeight.bold, fontSize: 42),
          ),
        );
      },
    );
  }
}

ButtonStyle getIconButtonStyle(BuildContext context) {
  return IconButton.styleFrom(
    foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
    disabledBackgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
    hoverColor: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.08),
    focusColor: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.12),
    highlightColor: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.12),
  );
}
