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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController coeffController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    coeffController.dispose();
    super.dispose();
  }

  void rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showSubjectDialog(context, nameController, coeffController).then((_) => rebuild()),
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
                GlobalKey listKey = GlobalKey();
                return TextRow(
                  listKey: listKey,
                  leading: Manager.termTemplate[index].name,
                  trailing: Calculator.format(Manager.termTemplate[index].coefficient, ignoreZero: true),
                  onTap: () async {
                    showListMenu(context, listKey).then((result) {
                      if (result == "edit") {
                        showSubjectDialog(context, nameController, coeffController, index: index).then((_) => rebuild());
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
              },
              addAutomaticKeepAlives: true,
              childCount: Manager.termTemplate.length,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 88)),
        ],
      ),
    );
  }
}
