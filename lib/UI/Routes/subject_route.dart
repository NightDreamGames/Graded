// Dart imports:
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:graded/Misc/storage.dart';

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
  late int subjectIndex = -1;
  late Term term = Manager.getCurrentTerm();
  late Subject subject = term.subjects[subjectIndex];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();
  final TextEditingController maximumController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    gradeController.dispose();
    maximumController.dispose();
    super.dispose();
  }

  void rebuild() {
    if (Storage.getPreference("sort_mode1") != 1) {
      subject = term.subjects[subjectIndex];
    } else {
      subjectIndex = term.subjects.indexOf(subject);
    }

    setState(() {});
  }

  void switchTerm() {
    Subject tmp = term.subjects[subjectIndex];
    term = Manager.getCurrentTerm();
    subjectIndex = term.subjects.indexWhere((element) => element.name == tmp.name);
    subject = term.subjects[subjectIndex];

    rebuild();
  }

  @override
  Widget build(BuildContext context) {
    if (subjectIndex == -1) {
      subjectIndex = ModalRoute.of(context)?.settings.arguments as int? ?? 0;
    }

    return Scaffold(
      floatingActionButton: Manager.currentTerm != -1
          ? FloatingActionButton(
              onPressed: () => {showTestDialog(context, subject, nameController, gradeController, maximumController).then((_) => rebuild())},
              child: const Icon(Icons.add),
            )
          : null,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: AppBarTitle(
              title: subject.name,
              actionAmount: 2,
            ),
            actions: [
              TermSelector(rebuild: switchTerm),
              SortSelector(rebuild: rebuild, type: 1),
            ],
          ),
          ResultRow(
            result: subject.getResult(),
            leading: () {
              if (Manager.currentTerm != -1) {
                return Row(
                  children: [
                    SizedBox(
                      width: (Platform.isAndroid ? 100 : 110) * MediaQuery.textScaleFactorOf(context),
                      child: Text(
                        "${Translations.bonus} ${subject.bonus}${subject.bonus < 0 ? "" : "  "}",
                        overflow: TextOverflow.visible,
                        softWrap: false,
                        style: const TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
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
                  Translations.yearly_average,
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
                GlobalKey listKey = GlobalKey();
                return TextRow(
                  listKey: listKey,
                  leading: subject.tests[index].name,
                  trailing: subject.tests[index].toString(),
                  onTap: () async {
                    if (Manager.currentTerm != -1) {
                      showListMenu(context, listKey).then((result) {
                        if (result == "edit") {
                          showTestDialog(context, subject, nameController, gradeController, maximumController, index: index).then((_) => rebuild());
                        } else if (result == "delete") {
                          subject.removeTest(index);
                          rebuild();
                        }
                      });
                    }
                  },
                );
              },
              addAutomaticKeepAlives: true,
              childCount: subject.tests.length,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 88)),
        ],
      ),
    );
  }
}
