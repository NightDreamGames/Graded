// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:customizable_space_bar/customizable_space_bar.dart';

class ScrollingTitle extends StatelessWidget {
  const ScrollingTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return CustomizableSpaceBar(
      builder: (context, scrollingRate) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12, left: 24 + 40 * scrollingRate),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 42 - 18 * scrollingRate,
                fontWeight: FontWeight.bold,
              ),
            ),
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
