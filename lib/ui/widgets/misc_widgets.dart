// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:flutter_svg/svg.dart";

// Project imports:
import "package:graded/ui/utilities/misc_utilities.dart";

class AppBarTitle extends StatelessWidget {
  const AppBarTitle({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Text(
        title,
        softWrap: false,
        maxLines: 1,
        overflow: TextOverflow.fade,
      ),
    );
  }
}

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    required this.message,
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                height: 180,
                width: 180,
                child: SvgPicture.asset(
                  "assets/illustrations/empty_list.svg",
                  semanticsLabel: message,
                  colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.outlineVariant, BlendMode.srcIn),
                ),
              ),
            ),
            Text(
              message,
              style: TextStyle(fontSize: 24, color: Theme.of(context).colorScheme.outlineVariant),
            ),
          ],
        ),
      ),
    );
  }
}

ButtonStyle getTonalIconButtonStyle(BuildContext context) {
  final ColorScheme colorScheme = Theme.of(context).colorScheme;

  return IconButton.styleFrom(
    foregroundColor: colorScheme.onSecondaryContainer,
    backgroundColor: colorScheme.secondaryContainer,
    disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
    disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
    hoverColor: colorScheme.onSecondaryContainer.withOpacity(0.08),
    focusColor: colorScheme.onSecondaryContainer.withOpacity(0.12),
    highlightColor: colorScheme.onSecondaryContainer.withOpacity(0.12),
  );
}

class PlatformWillPopScope extends StatelessWidget {
  const PlatformWillPopScope({
    super.key,
    required this.onWillPop,
    required this.child,
  });

  final Future<bool> Function()? onWillPop;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return !isiOS
        ? WillPopScope(
            onWillPop: onWillPop,
            child: child,
          )
        : child;
  }
}
