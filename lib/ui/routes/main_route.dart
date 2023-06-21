// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:sliver_tools/sliver_tools.dart";

// Project imports:
import "package:graded/calculations/manager.dart";
import "package:graded/localization/translations.dart";
import "package:graded/misc/enums.dart";
import "package:graded/misc/storage.dart";
import "package:graded/ui/routes/home_route.dart";
import "package:graded/ui/widgets/misc_widgets.dart";
import "package:graded/ui/widgets/popup_menus.dart";

enum RouteType {
  home,
  subject,
}

class RouteWidget extends StatefulWidget {
  const RouteWidget({
    super.key,
    required this.title,
    required this.children,
    required this.routeType,
  });

  final String title;
  final List<Widget> children;
  final RouteType routeType;

  @override
  State<RouteWidget> createState() => RouteWidgetState();
}

class RouteWidgetState extends State<RouteWidget> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: widget.children.length,
      initialIndex: Manager.currentTerm,
      vsync: this,
    )..addListener(() {
        if (widget.routeType != RouteType.home) return;
        Manager.currentTerm = tabController.index;
      });
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  void rebuild() {
    setState(() {});
  }

  void refreshYearOverview() {
    Manager.refreshYearOverview(yearOverview: Manager.getYearOverview(), year: Manager.getCurrentYear());
    rebuild();
  }

  void rebuildChildren() {
    if (!mounted) return;

    refreshYearOverview();

    for (final child in widget.children) {
      (child.key as GlobalKey?)?.currentState?.setState(() {});
    }
    rebuild();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Manager.deserializationError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translations.storage_error),
          ),
        );

        Manager.deserializationError = false;
      }
    });

    return Scaffold(
      body: PlatformWillPopScope(
        onWillPop: () {
          if (widget.children.last is HomePage && tabController.length > 1 && tabController.index == tabController.length - 1) {
            int newIndex = tabController.previousIndex;
            if (newIndex == tabController.index) {
              newIndex = 0;
            }
            tabController.animateTo(newIndex);
            return Future<bool>.value(false);
          }
          return Future<bool>.value(true);
        },
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: MultiSliver(
                  children: [
                    SliverAppBar.large(
                      title: AppBarTitle(
                        title: widget.title,
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
                      forceElevated: innerBoxIsScrolled,
                    ),
                    if (widget.children.length > 1)
                      TabBar(
                        //TODO Scrollable only when needed
                        isScrollable: true,
                        controller: tabController,
                        tabs: getTabs(),
                      ),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: tabController,
            children: widget.children,
          ),
        ),
      ),
    );
  }

  List<Widget> getTabs() {
    List<String> items = [];

    switch (getPreference<int>("term")) {
      case 1:
        items = [
          translations.year,
        ];
      case 2:
        items = [
          "${translations.semester} 1",
          "${translations.semester} 2",
        ];
      case 3:
        items = [
          "${translations.trimester} 1",
          "${translations.trimester} 2",
          "${translations.trimester} 3",
        ];
    }

    if (getPreference<int>("validated_year") == 1) {
      items.add(translations.exams);
    }
    items.add(translations.year_overview);

    List<Tab> entries = List.generate(items.length, (index) => Tab(text: items[index]));

    return entries;
  }
}
