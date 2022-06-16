import 'package:flutter/material.dart';
import 'package:gradely/UI/title.dart';
import '../Calculations/calculator.dart';
import '../Calculations/subject.dart';
import '../Calculations/test.dart';
import '../Misc/storage.dart';
import '../Translation/i18n.dart';
import 'package:customizable_space_bar/customizable_space_bar.dart';
import '../Calculations/manager.dart';
import 'popup_sub_menu.dart';
import 'view_state.dart';

class SubjectRoute extends StatefulWidget {
  final Subject subject;

  const SubjectRoute({Key? key, required this.subject}) : super(key: key);

  @override
  _SubjectRouteState createState() => _SubjectRouteState();
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
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                floating: false,
                pinned: true,
                actions: <Widget>[
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    tooltip: 'More options',
                    onSelected: (value) {},
                    itemBuilder: (BuildContext context) {
                      List<PopupMenuEntry<String>> entries = [];

                      entries.add(PopupSubMenuItem<String>(
                        title: I18n.of(context).sort_by,
                        items: [
                          I18n.of(context).az,
                          I18n.of(context).grade,
                        ],
                        onSelected: (value) {
                          if (value == I18n.of(context).az) {
                            Storage.setPreference<int>("sort_mode2", 0);
                          } else if (value == I18n.of(context).grade) {
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
                expandedHeight: 150,
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
                          widget.subject.name,
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
                /*FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Hero(
                    tag: widget.subject.name,
                    child: Text(
                      widget.subject.name,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),*/
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
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Text(
                                    "${I18n.of(context).bonus} ${widget.subject.bonus}${widget.subject.bonus < 0 ? "" : " "}",
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    style: const TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    widget.subject.changeBonus(-1);
                                    rebuild();
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<CircleBorder>(const CircleBorder()),
                                  ),
                                  child: const Text(
                                    "-",
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    widget.subject.changeBonus(1);
                                    rebuild();
                                  },
                                  style: ButtonStyle(
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
                            AnimatedPadding(
                              padding: EdgeInsets.only(right: fabVisible ? 60 : 0),
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.decelerate,
                              child: /*Hero(
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
                              //),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(height: 0, color: Theme.of(context).dividerColor, thickness: 1),
                    ),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTapDown: (TapDownDetails details) async {
                            if (Manager.currentTerm == -1) return;

                            double left = details.globalPosition.dx;
                            double top = details.globalPosition.dy;
                            var result = await showMenu(
                              context: context,
                              position: RelativeRect.fromLTRB(left, top, 0, 0),
                              items: [
                                PopupMenuItem<String>(value: I18n.of(context).edit, child: Text(I18n.of(context).edit)),
                                PopupMenuItem<String>(value: I18n.of(context).delete, child: Text(I18n.of(context).delete)),
                              ],
                              elevation: 8.0,
                            );
                            if (result == I18n.of(context).edit) {
                              return _displayTextInputDialog(context, index: index);
                            } else if (result == I18n.of(context).delete) {
                              widget.subject.removeTest(index);
                              rebuild();
                            }
                          },
                          child: ListTile(
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
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(height: 1, color: Theme.of(context).dividerColor),
                        ),
                      ],
                    );
                  },
                  addAutomaticKeepAlives: true,
                  childCount: widget.subject.tests.length,
                ),
              ),
            ],
          ),
          _buildFab(),
        ],
      ),
    );
  }

  Widget _buildFab() {
    const double defaultTopMargin = 159;
    const double scaleStart = 125.0;

    double top = defaultTopMargin;
    if (_scrollController.hasClients) {
      double offset = _scrollController.offset;
      top -= offset;

      fabVisible = (offset < defaultTopMargin - scaleStart);
    }

    return Positioned(
      top: top,
      right: 16.0,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: fabVisible ? 1 : 0,
        curve: Curves.ease,
        child: FloatingActionButton(
          onPressed: () => {_displayTextInputDialog(context)},
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _maximumController = TextEditingController();

  Future<void> _displayTextInputDialog(BuildContext context, {int? index}) async {
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
        return AlertDialog(
          title: add ? Text(I18n.of(context).add_test) : Text(I18n.of(context).edit_test),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                MaterialLocalizations.of(context).cancelButtonLabel,
                style: TextStyle(color: Theme.of(context).toggleableActiveColor),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                MaterialLocalizations.of(context).okButtonLabel,
                style: TextStyle(color: Theme.of(context).toggleableActiveColor),
              ),
            ),
          ],
          content: Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {},
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: getTestHint(I18n.of(context).test, widget.subject),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: I18n.of(context).name,
                    labelStyle: TextStyle(color: Colors.grey[500]),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.secondary),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 2, color: Theme.of(context).colorScheme.secondary),
                      borderRadius: BorderRadius.circular(15),
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
                      child: TextField(
                        //TODO Text validation
                        onChanged: (value) {},
                        autofocus: true,
                        controller: _gradeController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: "01",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: I18n.of(context).grade,
                          labelStyle: TextStyle(color: Colors.grey[500]),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.secondary),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2, color: Theme.of(context).colorScheme.secondary),
                            borderRadius: BorderRadius.circular(15),
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
                      child: TextField(
                        onChanged: (value) {},
                        controller: _maximumController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: Calculator.format(Manager.totalGrades),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: I18n.of(context).maximum,
                          labelStyle: TextStyle(color: Colors.grey[500]),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.secondary),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2, color: Theme.of(context).colorScheme.secondary),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((confirmed) {
      if (confirmed) {
        if (add) {
          widget.subject.addTest(Test(double.tryParse(_gradeController.text) ?? 1, double.tryParse(_maximumController.text) ?? Manager.totalGrades,
              _nameController.text.isEmpty ? getTestHint(I18n.of(context).test, widget.subject) : _nameController.text));
        } else {
          widget.subject.editTest(index, double.tryParse(_gradeController.text) ?? 1, double.tryParse(_maximumController.text) ?? Manager.totalGrades,
              _nameController.text.isEmpty ? getTestHint(I18n.of(context).test, widget.subject) : _nameController.text);
        }

        rebuild();
      }
    });
  }
}

String getTestHint(String test, Subject subject) {
  bool a = false;
  String defaultName = "Test 1";
  int i = 1;

  do {
    defaultName = "$test ${subject.tests.length + i}";

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
