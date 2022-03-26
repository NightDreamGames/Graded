import 'package:gradely/Misc/preferences.dart';
import 'package:gradely/UI/settings_route.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:gradely/Calculations/manager.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Calculations/subject.dart';
import '../Translation/i18n.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

import '../Misc/serialization.dart';
import '../Calculations/manager.dart';
import 'default_theme.dart';
import 'popup_sub_menu.dart';
import 'subject_route.dart';

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
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
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
                            Preferences.setPreference("sort_mode2", 0);
                          } else if (value == I18n.of(context).grade) {
                            Preferences.setPreference("sort_mode2", 1);
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
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Text(
                    widget.subject.name,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
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
                                    I18n.of(context).bonus + " " + widget.subject.bonus.toString() + (widget.subject.bonus < 0 ? "" : " "),
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
                              ],
                            ),
                            AnimatedPadding(
                              padding: EdgeInsets.only(right: fabVisible ? 60 : 0),
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.decelerate,
                              child: Text(
                                widget.subject.getResult(),
                                style: const TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                        ListTile(
                          onTap: () {
                            //TODO add options
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
                          child: Divider(height: 1, color: Theme.of(context).dividerColor),
                        ),
                      ],
                    );
                  },
                  addAutomaticKeepAlives: true,
                  childCount: widget.subject.tests.length,
                ),
              ),
              const SliverFillRemaining(),
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

  final TextEditingController _skillOneController = TextEditingController();

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(I18n.of(context).add_test),
          actions: [
            TextButton(
              onPressed: () {},
              child: Text(
                MaterialLocalizations.of(context).cancelButtonLabel,
                style: TextStyle(color: Theme.of(context).toggleableActiveColor),
              ),
            ),
            TextButton(
              onPressed: () {},
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
                  controller: _skillOneController,
                  //TODO Change hint
                  decoration: const InputDecoration(hintText: "Test 1"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: TextField(
                        onChanged: (value) {},
                        autofocus: true,
                        controller: _skillOneController,
                        decoration: const InputDecoration(hintText: "01"),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "/",
                      ),
                    ),
                    Flexible(
                      child: TextField(
                        onChanged: (value) {},
                        controller: _skillOneController,
                        decoration: InputDecoration(
                            hintText: Manager.totalGrades.toString(),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(width: 3, color: Colors.blue),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(width: 3, color: Colors.blue),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(width: 3, color: Colors.red),
                              borderRadius: BorderRadius.circular(15),
                            )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
