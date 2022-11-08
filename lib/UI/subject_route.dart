import 'package:flutter/material.dart';

import '../Calculations/calculator.dart';
import '../Calculations/subject.dart';
import '../Calculations/test.dart';
import '../Misc/storage.dart';
import '../Translation/translations.dart';
import 'package:customizable_space_bar/customizable_space_bar.dart';
import '../Calculations/manager.dart';
import 'popup_sub_menu.dart';
import 'easy_dialog.dart';

class SubjectRoute extends StatefulWidget {
  final Subject subject;

  const SubjectRoute({Key? key, required this.subject}) : super(key: key);

  @override
  State<SubjectRoute> createState() => _SubjectRouteState();
}

class _SubjectRouteState extends State<SubjectRoute> with WidgetsBindingObserver {
  late ScrollController _scrollController;
  bool fabVisible = true;

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
              PopupMenuButton<String>(
                color: ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surfaceTint, 2),
                icon: const Icon(Icons.more_vert),
                tooltip: 'More options',
                onSelected: (value) {},
                itemBuilder: (BuildContext context) {
                  List<PopupMenuEntry<String>> entries = [];

                  entries.add(PopupSubMenuItem<String>(
                    title: Translations.sort_by,
                    items: [
                      Translations.az,
                      Translations.grade,
                    ],
                    onSelected: (value) {
                      if (value == Translations.az) {
                        Storage.setPreference<int>("sort_mode2", 0);
                      } else if (value == Translations.grade) {
                        Storage.setPreference<int>("sort_mode2", 1);
                      }

                      Manager.sortAll();
                      Manager.years[0].terms[0];
                      rebuild();
                    },
                  ));

                  return entries;
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
                onChanged: (value) {},
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: getTestHint(widget.subject),
                  labelText: Translations.name,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Theme.of(context).colorScheme.primary),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
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
                      onChanged: (value) {},
                      autofocus: true,
                      autovalidateMode: AutovalidateMode.always,
                      controller: _gradeController,
                      validator: (String? input) {
                        if (input == null || input.isEmpty || double.tryParse(input) != null) {
                          return null;
                        }
                        return Translations.enter_valid_number;
                      },
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: "01",
                        labelText: Translations.grade,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2, color: Theme.of(context).colorScheme.primary),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.error),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2, color: Theme.of(context).colorScheme.error),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      textAlign: TextAlign.end,
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
                      onChanged: (value) {},
                      controller: _maximumController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (String? input) {
                        if (input != null && double.tryParse(input) != null) {
                          return null;
                        }
                        return Translations.enter_valid_number;
                      },
                      decoration: InputDecoration(
                        hintText: Calculator.format(Manager.totalGrades),
                        labelText: Translations.maximum,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2, color: Theme.of(context).colorScheme.primary),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.error),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2, color: Theme.of(context).colorScheme.error),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
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
