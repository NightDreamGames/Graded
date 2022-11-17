// Flutter imports:
import 'package:flutter/material.dart';

class FadePageRoute<T> extends MaterialPageRoute<T> {
  FadePageRoute({
    required this.widgetBuilder,
    RouteSettings? settings,
    this.doMaintainState = true,
    bool fullscreenDialog = false,
  }) : super(settings: settings, fullscreenDialog: fullscreenDialog, builder: widgetBuilder);

  /// Builds the primary contents of the route.
  final WidgetBuilder widgetBuilder;

  final bool doMaintainState;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) {
    return previousRoute is FadePageRoute;
  }

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    // Don't perform outgoing animation if the next route is a fullscreen dialog.
    return (nextRoute is FadePageRoute && !nextRoute.fullscreenDialog);
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget result = widgetBuilder(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
//    final PageTransitionsTheme theme = Theme.of(context).pageTransitionsTheme;
    return _FadeInPageTransition(routeAnimation: animation, child: child);
  }

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';
}

class _FadeInPageTransition extends StatefulWidget {
  const _FadeInPageTransition({
    required this.routeAnimation,
    required this.child,
  });

  final Widget child;
  final Animation<double> routeAnimation;
  @override
  State<StatefulWidget> createState() => _FadeInPageTransitionState();
}

class _FadeInPageTransitionState extends State<_FadeInPageTransition> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _opacityAnimation = widget.routeAnimation.drive(_easeInTween);
    _bottomUpTween = widget.routeAnimation.drive(_fadeTween);
  }

  // Fractional offset from 1/4 screen below the top to fully on screen.
  /*static final Animation<Offset> _bottomUpTween = Tween<Offset>(
    begin: const Offset(0.0, 0.25),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: AnimationController(duration: const Duration(milliseconds: 300), vsync: this)..forward(),
    curve: Curves.easeInCubic,
  ));*/
  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeInOut);
  static final Animatable<Offset> _fadeTween = Tween<Offset>(
    begin: const Offset(0.0, 0.1),
    end: Offset.zero,
  );

  late Animation<double> _opacityAnimation;
  late Animation<Offset> _bottomUpTween;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _bottomUpTween,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: widget.child,
      ),
    );
  }
}
