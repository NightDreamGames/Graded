// Dart imports:
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../Calculations/calculator.dart';
import '../../Calculations/manager.dart';
import '../../Calculations/subject.dart';
import '../../Calculations/term.dart';
import '../../Misc/storage.dart';
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
  late int subjectGroupIndex = -1;
  late Term term = Manager.getCurrentTerm();
  late Subject subject = subjectGroupIndex == -1 ? term.subjects[subjectIndex] : term.subjects[subjectIndex].children[subjectGroupIndex];
  late Subject subjectGroup = subjectGroupIndex != -1 ? term.subjects[subjectIndex] : Subject("", 1);

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
    if (getPreference("sort_mode1") != SortMode.result) {
      subject = subjectGroupIndex == -1 ? term.subjects[subjectIndex] : term.subjects[subjectIndex].children[subjectGroupIndex];
    } else {
      subjectIndex = term.subjects.indexOf(subjectGroupIndex == -1 ? subject : subjectGroup);
    }

    setState(() {});
  }

  void switchTerm() {
    Subject tmp = subjectGroupIndex == -1 ? term.subjects[subjectIndex] : term.subjects[subjectIndex].children[subjectGroupIndex];
    term = Manager.getCurrentTerm();
    subjectIndex = term.subjects.indexWhere((element) {
      if (element.name == tmp.name) {
        return true;
      }
      if (element.isGroup) {
        return element.children.indexWhere((element) => element.name == tmp.name) != -1;
      }
      return false;
    });
    subject = subjectGroupIndex == -1 ? term.subjects[subjectIndex] : term.subjects[subjectIndex].children[subjectGroupIndex];

    rebuild();
  }

  @override
  Widget build(BuildContext context) {
    if (subjectIndex == -1) {
      List<int?> arguments = ModalRoute.of(context)?.settings.arguments as List<int?>;
      subjectIndex = arguments[0] ?? 0;
      subjectGroupIndex = arguments[1] ?? -1;
    }

    return Scaffold(
      floatingActionButton: Manager.currentTerm != -1
          ? FloatingActionButton(
              onPressed: () => {showTestDialog(context, subject, nameController, gradeController, maximumController).then((_) => rebuild())},
              child: const Icon(Icons.add),
            )
          : null,
      body: CustomScrollView(
        primary: true,
        slivers: [
          SliverAppBar.large(
            title: AppBarTitle(
              title: subject.name,
              actionAmount: 2,
            ),
            actions: [
              TermSelector(rebuild: switchTerm),
              SortSelector(rebuild: rebuild, type: SortType.test),
            ],
          ),
          SliverSafeArea(
            top: false,
            bottom: false,
            sliver: ResultRow(
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
          ),
          SliverSafeArea(
            top: false,
            bottom: false,
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                addAutomaticKeepAlives: true,
                childCount: subject.tests.length,
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
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 88)),
        ],
      ),
    );
  }
}
