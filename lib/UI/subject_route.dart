// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:customizable_space_bar/customizable_space_bar.dart';

// Project imports:
import '../Calculations/calculator.dart';
import '../Calculations/manager.dart';
import '../Calculations/subject.dart';
import '../Calculations/test.dart';
import '../Misc/storage.dart';
import '../Translation/translations.dart';
import 'easy_dialog.dart';
import 'popup_sub_menu.dart';

class SubjectRoute extends StatefulWidget {
  Subject subject;
  final int subjectIndex;

  SubjectRoute({Key? key, required this.subjectIndex})
      : subject = Manager.getCurrentTerm().subjects[subjectIndex],
        super(key: key);

  @override
  State<SubjectRoute> createState() => _SubjectRouteState();
}

class _SubjectRouteState extends State<SubjectRoute> with WidgetsBindingObserver {
  late ScrollController _scrollController;

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
            //title: Text(widget.subject.name, style: TextStyle(fontWeight: FontWeight.bold)),
            flexibleSpace: CustomizableSpaceBar(
              builder: (context, scrollingRate) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12, left: 24 + 40 * scrollingRate),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      widget.subject.name,
                      style: TextStyle(
                        fontSize: 42 - 18 * scrollingRate,
                        fontWeight: FontWeight.bold,
                        //),
                      ),
                    ),
                    /*Hero(
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
                            widget.subject = Manager.getCurrentTerm().subjects[widget.subjectIndex];

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

                              widget.subject = Manager.getCurrentTerm().subjects[widget.subjectIndex];
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
                                    "${Translations.bonus} ${widget.subject.bonus}${widget.subject.bonus < 0 ? "" : "  "}",
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
                                          widget.subject.changeBonus(-1);
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
                                          widget.subject.changeBonus(1);
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
                            tag: "${widget.subject.name}_result",
                            flightShuttleBuilder: (
                              BuildContext flightContext,
                              Animation<double> animation,
                              HeroFlightDirection flightDirection,
                              BuildContext fromHeroContext,
                              BuildContext toHeroContext,
                            ) {
                              return DestinationTitle(
                                title: widget.subject.getResult(),
                                isOverflow: false,
                                viewState: flightDirection == HeroFlightDirection.push ? ViewState.enlarge : ViewState.shrink,
                                beginFontStyle: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal),
                                endFontStyle: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                              );
                            },
                            child:*/
                        Text(
                          widget.subject.getResult(),
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
                if (index != widget.subject.tests.length) {
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
                              widget.subject.removeTest(index);
                              rebuild();
                            }
                          }
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                        title: Text(
                          widget.subject.tests[index].name,
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
                              widget.subject.tests[index].toString(),
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
              childCount: widget.subject.tests.length + 1,
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
    _gradeController.text = add ? "" : Calculator.format(widget.subject.tests[index].grade1, ignoreZero: true);
    _maximumController.text = add ? "" : Calculator.format(widget.subject.tests[index].grade2, ignoreZero: true);
    _nameController.text = add ? "" : widget.subject.tests[index].name;

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
              widget.subject.addTest(Test(
                  double.tryParse(_gradeController.text) ?? 1,
                  double.tryParse(_maximumController.text) ?? Manager.totalGrades,
                  _nameController.text.isEmpty ? getTestHint(widget.subject) : _nameController.text));
            } else {
              widget.subject.editTest(
                  index,
                  double.tryParse(_gradeController.text) ?? 1,
                  double.tryParse(_maximumController.text) ?? Manager.totalGrades,
                  _nameController.text.isEmpty ? getTestHint(widget.subject) : _nameController.text);
            }

            rebuild();

            return true;
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: inputDecoration(context, hintText: getTestHint(widget.subject), labelText: Translations.name),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: TextFormField(
                      controller: _gradeController,
                      autofocus: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (String? input) {
                        if (input == null || input.isEmpty || double.tryParse(input) != null) {
                          return null;
                        }
                        return Translations.enter_valid_number;
                      },
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.end,
                      decoration: inputDecoration(context, hintText: "01", labelText: Translations.grade),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(4),
                    child: Text(
                      "/",
                    ),
                  ),
                  Flexible(
                    child: TextFormField(
                      controller: _maximumController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (String? input) {
                        if (input != null && double.tryParse(input) != null) {
                          return null;
                        }
                        return Translations.enter_valid_number;
                      },
                      decoration: inputDecoration(context, hintText: Calculator.format(Manager.totalGrades), labelText: Translations.maximum),
                    ),
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
