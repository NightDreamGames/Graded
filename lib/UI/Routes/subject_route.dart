// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:customizable_space_bar/customizable_space_bar.dart';

// Project imports:
import '../../Calculations/calculator.dart';
import '../../Calculations/manager.dart';
import '../../Calculations/subject.dart';
import '../../Calculations/test.dart';
import '../../Misc/storage.dart';
import '../../Translation/translations.dart';
import '../Widgets/easy_dialog.dart';
import '../Widgets/easy_form_field.dart';
import '../Widgets/popup_sub_menu.dart';

class SubjectRoute extends StatefulWidget {
  final int subjectIndex;

  const SubjectRoute({Key? key, required this.subjectIndex}) : super(key: key);

  @override
  State<SubjectRoute> createState() => _SubjectRouteState();
}

class _SubjectRouteState extends State<SubjectRoute> with WidgetsBindingObserver {
  late ScrollController _scrollController;
  late Subject subject = Manager.getCurrentTerm().subjects[widget.subjectIndex];

  void rebuild() {
    setState(() {});
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      rebuild();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Manager.currentTerm != -1
          ? FloatingActionButton(
              onPressed: () => {_displayTextInputDialog(context)},
              child: const Icon(Icons.add),
            )
          : null,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar.large(
            //TODO Fix title size
            //title: Text(subject.name, style: TextStyle(fontWeight: FontWeight.bold)),
            flexibleSpace: CustomizableSpaceBar(
              builder: (context, scrollingRate) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12, left: 24 + 40 * scrollingRate),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      subject.name,
                      style: TextStyle(
                        fontSize: 42 - 18 * scrollingRate,
                        fontWeight: FontWeight.bold,
                        //),
                      ),
                    ),
                    /*Hero(
                      tag: subject.name,
                      flightShuttleBuilder: (
                        BuildContext flightContext,
                        Animation<double> animation,
                        HeroFlightDirection flightDirection,
                        BuildContext fromHeroContext,
                        BuildContext toHeroContext,
                      ) {
                        return DestinationTitle(
                          title: subject.name,
                          isOverflow: false,
                          viewState: flightDirection == HeroFlightDirection.push ? ViewState.enlarge : ViewState.shrink,
                          beginFontStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal),
                          endFontStyle: const TextStyle(fontSize: 42.0, fontWeight: FontWeight.bold),
                        );
                      },
                      child: */
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
                        List<String> termEntries = [];

                        switch (Manager.maxTerm) {
                          case 2:
                            subject = Manager.getCurrentTerm().subjects[widget.subjectIndex];

                            termEntries = [
                              Translations.semester_1,
                              Translations.semester_2,
                              Translations.year,
                            ];
                            break;
                          case 3:
                            termEntries = [
                              Translations.trimester_1,
                              Translations.trimester_2,
                              Translations.trimester_3,
                              Translations.year,
                            ];
                            break;
                        }

                        List<PopupMenuEntry<String>> entries = [];
                        for (int i = 0; i < termEntries.length; i++) {
                          entries.add(PopupMenuItem<String>(
                            value: i.toString(),
                            onTap: () {
                              if (i == Manager.maxTerm) {
                                Manager.lastTerm = Manager.currentTerm;
                                Manager.currentTerm = -1;
                              } else {
                                Manager.currentTerm = i;
                              }

                              subject = Manager.getCurrentTerm().subjects[widget.subjectIndex];
                              rebuild();
                            },
                            child: Text(termEntries[i]),
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
                          Storage.setPreference<int>("sort_mode2", 0);
                        } else if (value == Translations.grade) {
                          Storage.setPreference<int>("sort_mode2", 1);
                        } else if (value == Translations.coefficient) {
                          Storage.setPreference<int>("sort_mode1", 2);
                        }

                        Manager.sortAll();
                        Manager.years[0].terms[0];
                        rebuild();
                      },
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Manager.currentTerm != -1
                            ? Row(
                                children: [
                                  Text(
                                    "${Translations.bonus} ${subject.bonus}${subject.bonus < 0 ? "" : "  "}",
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    style: const TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Padding(padding: EdgeInsets.only(left: 8)),
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          subject.changeBonus(-1);
                                          rebuild();
                                        },
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.all(16)),
                                          minimumSize: MaterialStateProperty.all<Size>(Size.zero),
                                          shape: MaterialStateProperty.all<CircleBorder>(const CircleBorder()),
                                        ),
                                        child: const Text(
                                          "-",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          subject.changeBonus(1);
                                          rebuild();
                                        },
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.all(16)),
                                          minimumSize: MaterialStateProperty.all<Size>(Size.zero),
                                          shape: MaterialStateProperty.all<CircleBorder>(const CircleBorder()),
                                        ),
                                        child: const Text(
                                          "+",
                                          style: TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Text(
                                Translations.average,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: const TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        /*Hero(
                            tag: "${subject.name}_result",
                            flightShuttleBuilder: (
                              BuildContext flightContext,
                              Animation<double> animation,
                              HeroFlightDirection flightDirection,
                              BuildContext fromHeroContext,
                              BuildContext toHeroContext,
                            ) {
                              return DestinationTitle(
                                title: subject.getResult(),
                                isOverflow: false,
                                viewState: flightDirection == HeroFlightDirection.push ? ViewState.enlarge : ViewState.shrink,
                                beginFontStyle: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal),
                                endFontStyle: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                              );
                            },
                            child:*/
                        Text(
                          subject.getResult(),
                          style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                        ),
                      ],
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
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index != subject.tests.length) {
                  GlobalKey listKey = GlobalKey();

                  return Column(
                    children: [
                      ListTile(
                        key: listKey,
                        onTap: () async {
                          if (Manager.currentTerm != -1) {
                            RenderBox box = listKey.currentContext?.findRenderObject() as RenderBox;
                            Offset position = box.localToGlobal(Offset(box.size.width, box.size.height / 2));

                            var result = await showMenu(
                              context: context,
                              color: ElevationOverlay.applySurfaceTint(
                                  Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surfaceTint, 2),
                              position: RelativeRect.fromLTRB(position.dx, position.dy, 0, 0),
                              items: [
                                PopupMenuItem<String>(value: "edit", child: Text(Translations.edit)),
                                PopupMenuItem<String>(value: "delete", child: Text(Translations.delete)),
                              ],
                            );
                            if (result == "edit") {
                              if (!context.mounted) return;
                              _displayTextInputDialog(context, index: index);
                            } else if (result == "delete") {
                              subject.removeTest(index);
                              rebuild();
                            }
                          }
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                        title: Text(
                          subject.tests[index].name,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: const TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              subject.tests[index].toString(),
                              style: const TextStyle(
                                fontSize: 20.0,
                              ),
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
                } else {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 88),
                  );
                }
              },
              addAutomaticKeepAlives: true,
              childCount: subject.tests.length + 1,
            ),
          ),
        ],
      ),
    );
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _maximumController = TextEditingController();

  void _displayTextInputDialog(BuildContext context, {int? index}) async {
    _gradeController.clear();
    _maximumController.clear();
    _nameController.clear();

    bool add = index == null;
    _gradeController.text = add ? "" : Calculator.format(subject.tests[index].grade1, ignoreZero: true);
    _maximumController.text = add ? "" : Calculator.format(subject.tests[index].grade2, ignoreZero: true);
    _nameController.text = add ? "" : subject.tests[index].name;

    return showDialog(
      context: context,
      builder: (context) {
        return EasyDialog(
          title: add ? Translations.add_test : Translations.edit_test,
          leading: add
              ? Icon(Icons.add, color: Theme.of(context).colorScheme.secondary)
              : Icon(Icons.edit, color: Theme.of(context).colorScheme.secondary),
          onConfirm: () {
            if (add) {
              subject.addTest(Test(double.tryParse(_gradeController.text) ?? 1, double.tryParse(_maximumController.text) ?? Manager.totalGrades,
                  _nameController.text.isEmpty ? getTestHint(subject) : _nameController.text));
            } else {
              subject.editTest(index, double.tryParse(_gradeController.text) ?? 1, double.tryParse(_maximumController.text) ?? Manager.totalGrades,
                  _nameController.text.isEmpty ? getTestHint(subject) : _nameController.text);
            }

            rebuild();

            return true;
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              EasyFormField(
                controller: _nameController,
                autofocus: true,
                label: Translations.name,
                hint: getTestHint(subject),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  EasyFormField(
                    controller: _gradeController,
                    label: Translations.grade,
                    hint: "01",
                    textAlign: TextAlign.end,
                    autofocus: true,
                    numeric: true,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 18),
                    child: Text("/", style: TextStyle(fontSize: 20)),
                  ),
                  EasyFormField(
                    controller: _maximumController,
                    label: Translations.maximum,
                    hint: Calculator.format(Manager.totalGrades),
                    numeric: true,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

String getTestHint(Subject subject) {
  bool a = false;
  String defaultName = "";
  int i = 1;

  do {
    defaultName = "${Translations.test} ${subject.tests.length + i}";

    for (Test t in subject.tests) {
      if (t.name == defaultName) {
        a = true;
        i++;
        break;
      } else {
        a = false;
      }
    }
  } while (a);

  return defaultName;
}
