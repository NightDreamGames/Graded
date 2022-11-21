// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../Calculations/calculator.dart';
import '../../Calculations/manager.dart';
import '../../Calculations/term.dart';
import '../../Translations/translations.dart';
import '../Widgets/dialogs.dart';
import '../Widgets/list_widgets.dart';
import '../Widgets/popup_menus.dart';

class SubjectEditRoute extends StatefulWidget {
  const SubjectEditRoute({Key? key}) : super(key: key);

  @override
  State<SubjectEditRoute> createState() => _SubjectEditRouteState();
}

class _SubjectEditRouteState extends State<SubjectEditRoute> {
  void rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => {showSubjectDialog(context).then((value) => rebuild())},
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text(Translations.edit_subjects),
        actions: <Widget>[
          SortSelector(rebuild: rebuild, type: 2),
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
                  return TextRow(
                    listKey: listKey,
                    leading: Manager.termTemplate[index].name,
                    trailing: Calculator.format(Manager.termTemplate[index].coefficient, ignoreZero: true),
                    onTap: () async {
                      showListMenu(context, listKey).then((result) {
                        if (result == "edit") {
                          showSubjectDialog(context, index: index).then((value) => rebuild());
                        } else if (result == "delete") {
                          Manager.termTemplate.removeAt(index);
                          Manager.sortSubjectsAZ();

                          for (Term p in Manager.getCurrentYear().terms) {
                            p.subjects.removeAt(index);
                          }

                          Manager.calculate();
                          rebuild();
                        }
                      });
                    },
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
}
