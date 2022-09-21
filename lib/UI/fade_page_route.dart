import 'package:flutter/material.dart';

class FadePageRoute<T> extends MaterialPageRoute<T> {
  FadePageRoute({
    required this.builder,
    RouteSettings? settings,
    this.maintainState = true,
    bool fullscreenDialog = false,
  }) : super(settings: settings, fullscreenDialog: fullscreenDialog, builder: builder);

  /// Builds the primary contents of the route.
  @override
  final WidgetBuilder builder;

  @override
  final bool maintainState;

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
    final Widget result = builder(context);
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
  State<StatefulWidget> createState() => _FadeInPageTransitionState(routeAnimation: routeAnimation, child: child);
}

class _FadeInPageTransitionState extends State<_FadeInPageTransition> with SingleTickerProviderStateMixin {
  _FadeInPageTransitionState({
    required Animation<double> routeAnimation, // The route's linear 0.0 - 1.0 animation.
    required this.child,
  })  : _opacityAnimation = routeAnimation.drive(_easeInTween),
        _bottomUpTween = routeAnimation.drive(_fadeTween);

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

  final Animation<double> _opacityAnimation;
  final Animation<Offset> _bottomUpTween;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _bottomUpTween,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: child,
      ),
    );
  }
}
