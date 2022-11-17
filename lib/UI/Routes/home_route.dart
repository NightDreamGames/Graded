// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:customizable_space_bar/customizable_space_bar.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

// Project imports:
import '../../Calculations/manager.dart';
import '../../Misc/storage.dart';
import '../../Translation/translations.dart';
import '../Widgets/popup_sub_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  void rebuild() {
    setState(() {});
  }

  @override
  void initState() {
    setOptimalDisplayMode();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      rebuild();
    }
  }

  Future<void> setOptimalDisplayMode() async {
    final List<DisplayMode> supported = await FlutterDisplayMode.supported;
    final DisplayMode active = await FlutterDisplayMode.active;

    final List<DisplayMode> sameResolution = supported.where((DisplayMode m) => m.width == active.width && m.height == active.height).toList()
      ..sort((DisplayMode a, DisplayMode b) => b.refreshRate.compareTo(a.refreshRate));

    final DisplayMode mostOptimalMode = sameResolution.isNotEmpty ? sameResolution.first : active;

    await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(Theme.of(context).brightness == Brightness.light ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);

    return WillPopScope(
      onWillPop: () {
        if (Manager.currentTerm == -1) {
          Manager.currentTerm = Manager.lastTerm;
          rebuild();
        } else {
          exit(0);
        }

        return Future<bool>.value(false);
      },
      child: CustomScrollView(
        primary: true,
        slivers: <Widget>[
          SliverAppBar.large(
            centerTitle: true,
            automaticallyImplyLeading: false,
            flexibleSpace: CustomizableSpaceBar(
              builder: (context, scrollingRate) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12, left: 24 + 40 * scrollingRate),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: /*Hero(
                            tag: widget.subject.name,
                            flightShuttleBuilder: (
                              BuildContext flightContext,
                              Animation<double> animation,
                              HeroFlightDirection flightDirection,
                              BuildContext fromHeroContext,
                              BuildContext toHeroContext,
                            ) {
                              return DestinationTitle(
                                title: widget.subject.name,
                                isOverflow: false,
                                viewState: flightDirection == HeroFlightDirection.push ? ViewState.enlarge : ViewState.shrink,
                                beginFontStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal),
                                endFontStyle: const TextStyle(fontSize: 42.0, fontWeight: FontWeight.bold),
                              );
                            },
                            child: */
                        Text(
                      getTitle(context),
                      style: TextStyle(
                        fontSize: 42 - 18 * scrollingRate,
                        fontWeight: FontWeight.bold,
                        //),
                      ),
                    ),
                  ),
                );
              },
            ),
            actions: <Widget>[
              Manager.maxTerm != 1
                  ? PopupMenuButton<String>(
                      color: ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surfaceTint, 2),
                      icon: const Icon(Icons.access_time_outlined),
                      tooltip: Translations.select_term,
                      itemBuilder: (BuildContext context) {
                        List<String> a = [];

                        switch (Manager.maxTerm) {
                          case 2:
                            a = [
                              Translations.semester_1,
                              Translations.semester_2,
                              Translations.year,
                            ];
                            break;
                          case 3:
                            a = [
                              Translations.trimester_1,
                              Translations.trimester_2,
                              Translations.trimester_3,
                              Translations.year,
                            ];
                            break;
                        }

                        List<PopupMenuEntry<String>> entries = [];
                        for (int i = 0; i < a.length; i++) {
                          entries.add(PopupMenuItem<String>(
                            value: i.toString(),
                            onTap: () {
                              if (i == Manager.maxTerm) {
                                Manager.lastTerm = Manager.currentTerm;
                                Manager.currentTerm = -1;
                              } else {
                                Manager.currentTerm = i;
                              }

                              rebuild();
                            },
                            child: Text(a[i]),
                          ));
                        }

                        return entries;
                      },
                    )
                  : Container(),
              PopupMenuButton<String>(
                color: ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surfaceTint, 2),
                icon: const Icon(Icons.more_vert),
                tooltip: Translations.more_options,
                onSelected: (value) {
                  if (value == "2") {
                    Navigator.pushNamed(
                      context,
                      "/settings",
                    ).then((value) {
                      rebuild();
                    });
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupSubMenuItem<String>(
                      title: Translations.sort_by,
                      items: [
                        Translations.az,
                        Translations.grade,
                        Translations.coefficient,
                      ],
                      onSelected: (value) {
                        if (value == Translations.az) {
                          Storage.setPreference<int>("sort_mode1", 0);
                        } else if (value == Translations.grade) {
                          Storage.setPreference<int>("sort_mode1", 1);
                        } else if (value == Translations.coefficient) {
                          Storage.setPreference<int>("sort_mode1", 2);
                        }

                        Manager.sortAll();
                        rebuild();
                      },
                    ),
                    PopupMenuItem<String>(
                      value: "2",
                      onTap: () {},
                      child: Text(Translations.settings),
                    )
                  ];
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(
                  height: 54,
                  child: Material(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Text(
                                Translations.average,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: const TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            Manager.getCurrentTerm().getResult(),
                            style: const TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, thickness: 3, color: Theme.of(context).colorScheme.surfaceVariant),
                ),
              ],
            ),
          ),
          ListWidget(rebuild),
        ],
      ),
    );
  }
}

class ListWidget extends StatelessWidget {
  final Function rebuild;

  const ListWidget(this.rebuild, {Key? key})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return ListRow(index, rebuild);
        },
        addAutomaticKeepAlives: true,
        childCount: Manager.getCurrentTerm().subjects.length,
      ),
    );
  }
}

class ListRow extends StatelessWidget {
  final int index;
  final Function rebuild;
  const ListRow(this.index, this.rebuild, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: () {
            Navigator.pushNamed(
              context,
              "/subject",
              arguments: index,
            ).then((_) => rebuild());
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          title: /*Hero(
            tag: Manager.getCurrentTerm(context: context).subjects[index].name,
            flightShuttleBuilder: (
              BuildContext flightContext,
              Animation<double> animation,
              HeroFlightDirection flightDirection,
              BuildContext fromHeroContext,
              BuildContext toHeroContext,
            ) {
              return DestinationTitle(
                title: Manager.getCurrentTerm(context: context).subjects[index].name,
                isOverflow: false,
                viewState: flightDirection == HeroFlightDirection.push ? ViewState.enlarge : ViewState.shrink,
                beginFontStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal),
                endFontStyle: const TextStyle(fontSize: 42.0, fontWeight: FontWeight.bold),
              );
            },
            child:*/

              Text(
            Manager.getCurrentTerm().subjects[index].name,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: const TextStyle(
              fontSize: 18.0,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              /*Hero(
                tag: "${Manager.getCurrentTerm(context: context).subjects[index].name}_result",
                flightShuttleBuilder: (
                  BuildContext flightContext,
                  Animation<double> animation,
                  HeroFlightDirection flightDirection,
                  BuildContext fromHeroContext,
                  BuildContext toHeroContext,
                ) {
                  return DestinationTitle(
                    title: Manager.getCurrentTerm(context: context).subjects[index].getResult(),
                    isOverflow: false,
                    viewState: flightDirection == HeroFlightDirection.push ? ViewState.enlarge : ViewState.shrink,
                    beginFontStyle: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal),
                    endFontStyle: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                  );
                },
                child: */
              Text(
                Manager.getCurrentTerm().subjects[index].getResult(),
                style: const TextStyle(fontSize: 20.0),
                //),
              ),
              const Padding(padding: EdgeInsets.only(right: 24)),
              const Icon(
                Icons.navigate_next,
                size: 24.0,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(height: 1, color: Theme.of(context).colorScheme.surfaceVariant),
        ),
      ],
    );
  }
}

String getTitle(var context) {
  switch (Manager.currentTerm) {
    case 0:
      switch (Manager.maxTerm) {
        case 3:
          return Translations.trimester_1;
        case 2:
          return Translations.semester_1;
        case 1:
          return Translations.year;
      }
      break;
    case 1:
      switch (Manager.maxTerm) {
        case 3:
          return Translations.trimester_2;
        case 2:
          return Translations.semester_2;
      }
      break;
    case 2:
      return Translations.trimester_3;
    case -1:
      return Translations.year;
  }

  return Translations.app_name;
}
