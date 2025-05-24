// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:sliver_tools/sliver_tools.dart";

// Project imports:
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/calculations/year.dart";
import "package:graded/l10n/translations.dart";
import "package:graded/misc/enums.dart";
import "package:graded/ui/routes/chart_route.dart";
import "package:graded/ui/routes/home_route.dart";
import "package:graded/ui/routes/subject_route.dart";
import "package:graded/ui/utilities/haptics.dart";
import "package:graded/ui/widgets/better_app_bar.dart";
import "package:graded/ui/widgets/misc_widgets.dart";
import "package:graded/ui/widgets/popup_menus.dart";

enum RouteType {
  home,
  subject,
  chart,
}

class RouteWidget extends StatefulWidget {
  const RouteWidget({
    super.key,
    required this.routeType,
    this.arguments,
  });

  final RouteType routeType;
  final Object? arguments;

  @override
  State<RouteWidget> createState() => RouteWidgetState();
}

class RouteWidgetState extends State<RouteWidget> with TickerProviderStateMixin {
  late TabController tabController;
  List<Widget> children = [];
  GlobalKey tabBarKey = GlobalKey();
  double tabPadding = 0;
  bool canPop = true;

  @override
  void initState() {
    super.initState();
    children = getChildren();
    rebuild();
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  void rebuild() {
    children = getChildren();

    tabController = TabController(
      length: children.length,
      initialIndex: widget.routeType != RouteType.chart ? Manager.currentTerm : 0,
      vsync: this,
    )..addListener(() {
        if (widget.routeType != RouteType.home) return;
        Manager.currentTerm = tabController.index;

        setState(() {
          canPop = !(children.every((e) => e is HomePage) && tabController.length > 1 && tabController.index == tabController.length - 1);
        });
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Manager.deserializationError) {
        heavyHaptics();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translations.storage_error),
          ),
        );

        Manager.deserializationError = false;
      }
    });

    setState(() {});
  }

  void refreshYearOverview() {
    Manager.refreshYearOverview();
    rebuild();
  }

  void rebuildChildren() {
    if (!mounted) return;

    refreshYearOverview();

    for (final child in children) {
      (child.key as GlobalKey?)?.currentState?.setState(() {});
    }
    rebuild();
  }

  void checkTabBarSize() {
    try {
      if (tabBarKey.currentContext?.size == null) return;
    } catch (e) {
      return;
    }

    final double prevPadding = tabPadding;
    tabPadding += (MediaQuery.sizeOf(context).width - tabBarKey.currentContext!.size!.width) / (tabController.length * 2.0);
    if (tabPadding < 0) tabPadding = 0;
    if (prevPadding != tabPadding) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkTabBarSize();
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: PlatformWillPopScope(
        canPop: canPop,
        onPopInvoked: (didPop, _) {
          if (didPop) return;
          if (children.every((e) => e is HomePage) && tabController.length > 1 && tabController.index == tabController.length - 1) {
            int newIndex = tabController.previousIndex;
            if (newIndex == tabController.index) {
              newIndex = 0;
            }
            tabController.animateTo(newIndex);
            setState(() {
              canPop = true;
            });
          }
        },
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            String title = translations.subjectOther;
            if (widget.routeType != RouteType.home) {
              title = (widget.arguments! as List<Subject?>)[1]!.name;
            }

            return <Widget>[
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: MultiSliver(
                  children: [
                    BetterSliverAppBar.large(
                      title: AppBarTitle(
                        title: title,
                      ),
                      actions: [
                        SortAction(
                          onTap: rebuildChildren,
                          sortType: widget.routeType == RouteType.home ? SortType.subject : SortType.test,
                        ),
                        if (widget.routeType == RouteType.home)
                          SettingsAction(
                            onReturn: rebuildChildren,
                          ),
                      ],
                    ),
                    if (children.length > 1)
                      Column(
                        children: [
                          Offstage(
                            child: UnconstrainedBox(
                              child: TabBar(
                                key: tabBarKey,
                                isScrollable: true,
                                controller: tabController,
                                tabs: getTabs(),
                              ),
                            ),
                          ),
                          TabBar(
                            isScrollable: true,
                            controller: tabController,
                            tabs: getTabs(),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: tabController,
            children: children,
          ),
        ),
      ),
    );
  }

  List<Widget> getTabs() {
    final int termCount = getCurrentYear().termCount;
    final List<String> items = List<String>.generate(termCount, (i) {
      return switch (termCount) {
        1 => translations.yearOne,
        2 => translations.semester_num.replaceFirst("%s", "${i + 1}"),
        3 => translations.trimester_num.replaceFirst("%s", "${i + 1}"),
        4 => translations.quartile_num.replaceFirst("%s", "${i + 1}"),
        _ => throw const FormatException("Invalid"),
      };
    });

    if (getCurrentYear().validatedYear == 1) {
      items.add(translations.exams);
    }
    items.add(translations.year_overview);

    final List<Widget> entries = List.generate(
      items.length,
      (index) => Padding(
        padding: EdgeInsets.symmetric(horizontal: tabPadding),
        child: Tab(text: items[index]),
      ),
    );

    return entries;
  }

  List<Widget> getChildren() {
    int tabCount = getCurrentYear().termCount;
    if (getCurrentYear().validatedYear == 1) tabCount++;
    if (tabCount > 1) tabCount++;

    List<Widget> children = [];

    switch (widget.routeType) {
      case RouteType.home:
        children = List.generate(
          tabCount,
          (index) {
            final isYearOverview = index == tabCount - 1 && tabCount > 1;
            return HomePage(
              year: getCurrentYear(),
              termIndex: isYearOverview ? 0 : index,
              isYearOverview: isYearOverview,
            );
          },
        );

      case RouteType.subject:
      case RouteType.chart:
        if (widget.arguments == null) {
          throw ArgumentError("No arguments passed to route");
        }

        final List<Subject?> arguments = widget.arguments! as List<Subject?>;
        Subject? parent = arguments[0];
        Subject subject = arguments[1]!;

        if (widget.routeType == RouteType.chart) {
          tabCount = 1;
        }

        children = List.generate(tabCount, (index) {
          Year year = getCurrentYear();
          final isYearOverview = index == tabCount - 1 && tabCount > 1;

          if (widget.routeType == RouteType.chart || isYearOverview) {
            year = getYearOverview();
          }

          if (widget.routeType == RouteType.subject) {
            if (isYearOverview) {
              if (parent != null) {
                parent = getSubjectInYearOverview(parent!);
              }
              subject = getSubjectInYearOverview(subject);
            }
            return SubjectRoute(year: year, termIndex: isYearOverview ? 0 : index, parent: parent, subject: subject);
          } else {
            subject = getSubjectInYear(subject);
            return ChartRoute(subject: subject);
          }
        });
    }

    return children;
  }
}
