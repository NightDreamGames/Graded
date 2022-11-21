// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../Calculations/manager.dart';
import '../../Calculations/subject.dart';
import '../../Calculations/term.dart';
import '../../Translations/translations.dart';
import '../Widgets/dialogs.dart';
import '../Widgets/list_widgets.dart';
import '../Widgets/misc_widgets.dart';
import '../Widgets/popup_menus.dart';

class SubjectRoute extends StatefulWidget {
  const SubjectRoute({Key? key}) : super(key: key);

  @override
  State<SubjectRoute> createState() => _SubjectRouteState();
}

class _SubjectRouteState extends State<SubjectRoute> {
  late int subjectIndex;
  late Term term = Manager.getCurrentTerm();
  late Subject subject = term.subjects[subjectIndex];

  void rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    subjectIndex = ModalRoute.of(context)!.settings.arguments as int;

    return Scaffold(
      floatingActionButton: Manager.currentTerm != -1
          ? FloatingActionButton(
              onPressed: () => {showTestDialog(context, subject).then((value) => rebuild())},
              child: const Icon(Icons.add),
            )
          : null,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            //TODO Fix title size
            //title: Text(subject.name, style: TextStyle(fontWeight: FontWeight.bold)),
            flexibleSpace: ScrollingTitle(title: subject.name),
            actions: <Widget>[
              TermSelector(
                  rebuild: rebuild,
                  onTap: () {
                    term = Manager.getCurrentTerm();
                    subject = term.subjects[subjectIndex];
                  }),
              SortSelector(rebuild: rebuild, type: 1, onTap: () => term = Manager.getCurrentTerm()),
            ],
          ),
          ResultRow(
            rebuild,
            result: subject.getResult(),
            leading: () {
              if (Manager.currentTerm != -1) {
                return Row(
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
                    IconButton(
                      icon: const Icon(Icons.remove, size: 20),
                      onPressed: () {
                        subject.changeBonus(-1);
                        rebuild();
                      },
                      style: getIconButtonStyle(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () {
                        subject.changeBonus(1);
                        rebuild();
                      },
                      style: getIconButtonStyle(context),
                    ),
                  ],
                );
              } else {
                return Text(
                  Translations.average,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }
            }(),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index != subject.tests.length) {
                  GlobalKey listKey = GlobalKey();
                  return TextRow(
                    listKey: listKey,
                    leading: subject.tests[index].name,
                    trailing: subject.tests[index].toString(),
                    onTap: () async {
                      if (Manager.currentTerm != -1) {
                        showListMenu(context, listKey).then((result) {
                          if (result == "edit") {
                            showTestDialog(context, subject, index: index).then((value) => rebuild());
                          } else if (result == "delete") {
                            subject.removeTest(index);
                            rebuild();
                          }
                        });
                      }
                    },
                  );
                } else {
                  return const Padding(padding: EdgeInsets.only(bottom: 88));
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
}
