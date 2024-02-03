// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:fading_edge_scrollview/fading_edge_scrollview.dart";
import "package:flutter_svg/svg.dart";

// Project imports:
import "package:graded/ui/utilities/misc_utilities.dart";

class AppBarTitle extends StatefulWidget {
  const AppBarTitle({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<AppBarTitle> createState() => _AppBarTitleState();
}

class _AppBarTitleState extends State<AppBarTitle> {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        scrollController.animateTo(
          scrollController.offset > 0 ? 0 : scrollController.position.maxScrollExtent,
          duration: Durations.medium2,
          curve: Easing.standard,
        );
      },
      child: FadingEdgeScrollView.fromSingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: scrollController,
          child: Text(
            widget.title,
            softWrap: false,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}

class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget({
    required this.message,
    this.topPadding = 100,
  });

  final String message;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              SizedBox(
                height: 180,
                width: 180,
                child: SvgPicture.asset(
                  "assets/illustrations/empty_list.svg",
                  semanticsLabel: message,
                  colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.outlineVariant, BlendMode.srcIn),
                ),
              ),
              Text(
                message,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SliverEmptyWidget extends StatelessWidget {
  const SliverEmptyWidget({
    required this.message,
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        return SliverToBoxAdapter(
          child: _EmptyWidget(
            message: message,
            topPadding: constraints.viewportMainAxisExtent / 5,
          ),
        );
      },
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return _EmptyWidget(
          message: message,
          topPadding: constraints.maxHeight / 3,
        );
      },
    );
  }
}

ButtonStyle getTonalButtonStyle(BuildContext context) {
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
    this.onPopInvoked,
    this.canPop,
    required this.child,
  });

  final void Function(bool)? onPopInvoked;
  final bool? canPop;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return !isiOS
        ? PopScope(
            onPopInvoked: onPopInvoked,
            canPop: canPop ?? true,
            child: child,
          )
        : child;
  }
}

class SpinningIcon extends StatelessWidget {
  const SpinningIcon({
    required this.rotation,
    required this.icon,
    super.key,
  });

  final double rotation;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      duration: Durations.long2,
      curve: Easing.standard,
      turns: rotation,
      child: Icon(icon),
    );
  }
}
