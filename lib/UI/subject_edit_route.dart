import 'package:flutter/material.dart';

import '../Calculations/calculator.dart';
import '../Calculations/manager.dart';
import '../Calculations/subject.dart';
import '../Calculations/term.dart';
import '../Misc/storage.dart';
import '../Translation/translations.dart';
import 'easy_dialog.dart';
import 'popup_sub_menu.dart';

class SubjectEditRoute extends StatefulWidget {
  const SubjectEditRoute({Key? key}) : super(key: key);

  @override
  State<SubjectEditRoute> createState() => _SubjectEditRouteState();
}

class _SubjectEditRouteState extends State<SubjectEditRoute> with WidgetsBindingObserver {
  void rebuild() {
    setState(() {});
  }

  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => {_displayTextInputDialog(context)},
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text(Translations.edit_subjects),
        actions: <Widget>[
          PopupMenuButton<String>(
            color: ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surfaceTint, 2),
            icon: const Icon(Icons.more_vert),
            tooltip: Translations.more_options,
            itemBuilder: (BuildContext context) {
              List<PopupMenuEntry<String>> entries = [];

              entries.add(PopupSubMenuItem<String>(
                title: Translations.sort_by,
                items: [
                  Translations.az,
                  Translations.coefficient,
                ],
                onSelected: (value) {
                  if (value == Translations.az) {
                    Storage.setPreference<int>("sort_mode3", 0);
                  } else if (value == Translations.coefficient) {
                    Storage.setPreference<int>("sort_mode3", 2);
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
        primary: true,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index != Manager.termTemplate.length) {
                  GlobalKey listKey = GlobalKey();

                  return Column(
                    children: [
                      ListTile(
                        key: listKey,
                        onTap: () async {
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
                            Manager.termTemplate.removeAt(index);
                            Manager.sortSubjectsAZ();

                            for (Term p in Manager.getCurrentYear().terms) {
                              p.subjects.removeAt(index);
                            }

                            Manager.calculate();

                            Storage.serialize();
                            rebuild();
                          }
                        },
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
              childCount: Manager.termTemplate.length + 1,
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
          title: Center(
            child: add ? Text(Translations.add_subject) : Text(Translations.edit_subject),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                MaterialLocalizations.of(context).cancelButtonLabel,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                MaterialLocalizations.of(context).okButtonLabel,
              ),
            ),
          ],
          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: inputDecoration(context, hintText: getSubjectHint(), labelText: Translations.name),
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
                      //TODO Text validation
                      controller: _coeffController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (String? input) {
                        if (input == null || input.isEmpty || double.tryParse(input) != null) {
                          return null;
                        }
                        return Translations.enter_valid_number;
                      },
                      decoration: inputDecoration(context, hintText: "1", labelText: Translations.coefficient),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ).then((confirmed) {
      if (confirmed) {
        String name = _nameController.text.isEmpty ? getSubjectHint() : _nameController.text;
        double coefficient = double.tryParse(_coeffController.text) ?? 1.0;

        if (add) {
          Manager.termTemplate.add(Subject(name, coefficient));

          for (Term p in Manager.getCurrentYear().terms) {
            p.subjects.add(Subject(name, coefficient));
          }
        } else {
          Manager.termTemplate[index].name = _nameController.text.isEmpty ? getSubjectHint() : _nameController.text;
          Manager.termTemplate[index].coefficient = double.tryParse(_coeffController.text) ?? 1.0;

          Manager.sortSubjectsAZ();

          for (Term p in Manager.getCurrentYear().terms) {
            for (int i = 0; i < p.subjects.length; i++) {
              p.subjects[i].name = Manager.termTemplate[i].name;
              p.subjects[i].coefficient = Manager.termTemplate[i].coefficient;
            }
          }
        }

        Manager.calculate();
        Storage.serialize();

        rebuild();
      }
    });
  }
}

String getSubjectHint() {
  bool a = false;
  String defaultName = "Subject 1";
  int i = 1;

  do {
    defaultName = "${Translations.subject} ${Manager.termTemplate.length + i}";

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
