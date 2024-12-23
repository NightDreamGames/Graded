// Flutter imports:
import "package:flutter/material.dart";

/// A method that will add default leading padding to all children in the list
List<Widget> getPaddedParentChildrenList(List<Widget> childrenIfEnabled) {
  return childrenIfEnabled.map<Widget>((childWidget) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: childWidget,
    );
  }).toList();
}

TextStyle? headerTextStyle(BuildContext context) => Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16);

TextStyle? subtitleTextStyle(BuildContext context) =>
    Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8));

TextStyle? radioTextStyle(BuildContext context) => Theme.of(context).textTheme.titleMedium;
