import 'package:flutter/material.dart';
import 'package:gradely/Translation/i18n.dart';

import '../Calculations/calculator.dart';
import '../Calculations/manager.dart';
import '../Calculations/subject.dart';
import '../Calculations/term.dart';
import '../Calculations/test.dart';
import '../Misc/storage.dart';
import 'popup_sub_menu.dart';

class SubjectEditRoute extends StatefulWidget {
  const SubjectEditRoute({Key? key}) : super(key: key);

  @override
  _SubjectEditRouteState createState() => _SubjectEditRouteState();
}

class _SubjectEditRouteState extends State<SubjectEditRoute> with WidgetsBindingObserver {
  void rebuild() {
    setState(() {});
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
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
      appBar: AppBar(
        title: Text(I18n.of(context).edit_subjects),
        actions: <Widget>[
          IconButton(onPressed: () => _displayTextInputDialog(context), icon: Icon(Icons.add)),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More options',
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
                    Storage.setPreference<int>("sort_mode3", 0);
                  } else if (value == I18n.of(context).grade) {
                    Storage.setPreference<int>("sort_mode3", 1);
                  }

                  Manager.sortAll();
                  rebuild();
                },
              ));
              return entries;
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Column(
                  children: [
                    GestureDetector(
                      onTapDown: (TapDownDetails details) async {
                        double left = details.globalPosition.dx;
                        double top = details.globalPosition.dy;
                        var result = await showMenu(
                          context: context,
                          position: RelativeRect.fromLTRB(left, top, 0, 0),
                          items: [
                            PopupMenuItem<String>(child: Text(I18n.of(context).edit), value: I18n.of(context).edit),
                            PopupMenuItem<String>(child: Text(I18n.of(context).delete), value: I18n.of(context).delete),
                          ],
                          elevation: 8.0,
                        );
                        if (result == I18n.of(context).edit) {
                          return _displayTextInputDialog(context, index: index);
                        } else if (result == I18n.of(context).delete) {
                          Manager.termTemplate.removeAt(index);
                          Storage.serialize();
                          rebuild();
                        }
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                        title: Text(
                          Manager.termTemplate[index].name,
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
                              Calculator.format(Manager.termTemplate[index].coefficient, ignoreZero: true),
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
              childCount: Manager.termTemplate.length,
            ),
          ),
        ],
      ),
    );
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _coeffController = TextEditingController();

  Future<void> _displayTextInputDialog(BuildContext context, {int? index}) async {
    _coeffController.clear();
    _nameController.clear();

    bool add = index == null;
    _coeffController.text = add ? "" : Calculator.format(Manager.termTemplate[index].coefficient, ignoreZero: true);
    _nameController.text = add ? "" : Manager.termTemplate[index].name;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: add ? Text(I18n.of(context).add_subject) : Text(I18n.of(context).edit_subject),
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
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: getSubjectHint(I18n.of(context).subject),
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
                        controller: _coeffController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: "01",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: I18n.of(context).coefficient,
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
        String name = _nameController.text.isEmpty ? getSubjectHint(I18n.of(context).subject) : _nameController.text;
        double coefficient = double.tryParse(_coeffController.text) ?? 1.0;

        if (add) {
          Manager.termTemplate.add(Subject(name, coefficient));

          for (Term p in Manager.getCurrentYear().terms) {
            p.subjects.add(Subject(name, coefficient));
          }
        } else {
          Manager.termTemplate[index].name = _nameController.text.isEmpty ? getSubjectHint(I18n.of(context).subject) : _nameController.text;
          Manager.termTemplate[index].coefficient = double.tryParse(_coeffController.text) ?? 1.0;

          for (Term p in Manager.getCurrentYear().terms) {
            for (int i = 0; i < p.subjects.length; i++) {
              p.subjects[i].name = Manager.termTemplate[i].name;
              p.subjects[i].coefficient = Manager.termTemplate[i].coefficient;
            }
          }
        }

        Manager.calculate();

        rebuild();
      }
    });
  }
}

String getSubjectHint(String subject) {
  bool a = false;
  String defaultName = "Subject 1";
  int i = 1;

  do {
    defaultName = subject + " " + (Manager.termTemplate.length + i).toString();

    for (Subject t in Manager.termTemplate) {
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
