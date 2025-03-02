// Flutter imports:
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";

// Package imports:
import "package:fading_edge_scrollview/fading_edge_scrollview.dart";
import "package:flutter_svg/svg.dart";

// Project imports:
import "package:graded/ui/utilities/grade_mapping_value.dart";
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
    disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
    disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
    hoverColor: colorScheme.onSecondaryContainer.withValues(alpha: 0.08),
    focusColor: colorScheme.onSecondaryContainer.withValues(alpha: 0.12),
    highlightColor: colorScheme.onSecondaryContainer.withValues(alpha: 0.12),
  );
}

class PlatformWillPopScope extends StatelessWidget {
  const PlatformWillPopScope({
    super.key,
    this.onPopInvoked,
    this.canPop,
    required this.child,
  });

  final void Function(bool, dynamic)? onPopInvoked;
  final bool? canPop;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return !isiOS
        ? PopScope(
            onPopInvokedWithResult: onPopInvoked,
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

abstract class SpinningFabPage<T extends StatefulWidget> extends State<T> {
  double fabRotation = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500)).then((_) {
      if (!mounted) return;
      setState(() {
        fabRotation += 0.5;
      });
    });
  }
}

typedef OnWidgetSizeChange = void Function(Size size);

class MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  OnWidgetSizeChange onChange;

  MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    final Size newSize = child!.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    super.key,
    required this.onChange,
    required Widget super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange);
  }

  @override
  void updateRenderObject(BuildContext context, covariant MeasureSizeRenderObject renderObject) {
    renderObject.onChange = onChange;
  }
}

class GradeMappingIndicator extends StatelessWidget {
  const GradeMappingIndicator({
    super.key,
    required this.gradeMapping,
    this.textStyle,
  });

  final GradeMapping? gradeMapping;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    if (gradeMapping == null || gradeMapping!.name.isEmpty) return Container();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: gradeMapping?.color ?? Theme.of(context).colorScheme.onSurface.withAlpha(100),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          gradeMapping!.name,
          overflow: TextOverflow.visible,
          softWrap: false,
          style: textStyle ??
              Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.normal,
                  ),
        ),
      ),
    );
  }
}
