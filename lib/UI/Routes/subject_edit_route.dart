// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:graded/Calculations/calculator.dart';
import '../../Calculations/manager.dart';
import '../../Calculations/subject.dart';
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
        title: Text(Translations.edit_subjects, style: const TextStyle(fontWeight: FontWeight.bold)),
        titleSpacing: 0,
        toolbarHeight: 64,
        actions: [
          SortSelector(rebuild: rebuild, type: SortType.subject),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ReorderableListView(
          buildDefaultDragHandles: false,
          onReorder: (int oldIndex, int newIndex) {
            //TODO Implement reordering
          },
          children: (buildTiles()),
        ),
      ),
    );
  }

  List<Widget> buildTiles() {
    List<Widget> result = [];
    int reorderIndex = 0;

    for (int i = 0; i < Manager.termTemplate.length; i++) {
      Subject element = Manager.termTemplate[i];
      result.add(SubjectTile(
        key: UniqueKey(),
        s: element,
        listKey: GlobalKey(),
        index: i,
        reorderIndex: reorderIndex,
        rebuild: rebuild,
        nameController: nameController,
        coeffController: coeffController,
      ));
      reorderIndex++;
      for (int j = 0; j < element.children.length; j++) {
        Subject child = element.children[j];
        result.add(SubjectTile(
          key: UniqueKey(),
          s: child,
          listKey: GlobalKey(),
          index: i,
          index2: j,
          reorderIndex: reorderIndex,
          rebuild: rebuild,
          nameController: nameController,
          coeffController: coeffController,
        ));
        reorderIndex++;
      }
    }

    result.add(Padding(
      padding: const EdgeInsets.only(bottom: 88),
      key: UniqueKey(),
    ));
    return result;
  }
}
