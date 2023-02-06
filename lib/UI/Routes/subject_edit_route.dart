// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:graded/Calculations/calculator.dart';
import 'package:graded/Misc/storage.dart';
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
          padding: const EdgeInsets.only(bottom: 88),
          primary: true,
          buildDefaultDragHandles: false,
          onReorder: (int oldIndex, int newIndex) {
            setPreference<int>("sort_mode${SortType.subject}", SortMode.custom);

            var oldIndexes = getSubjectIndexes(oldIndex);
            var newIndexes = getSubjectIndexes(newIndex, addedIndex: 1);
            int oldIndex1 = oldIndexes[0], oldIndex2 = oldIndexes[1];
            int newIndex1 = newIndexes[0], newIndex2 = newIndexes[1];

            if (oldIndex1 == newIndex1 && oldIndex2 < newIndex2) {
              newIndex2--;
            }
            if (oldIndex1 < newIndex1 && oldIndex2 == -1) {
              newIndex1--;
            } else if (newIndex1 == oldIndex1 && oldIndex2 == -1 && newIndex2 != -1) {
              return;
            }

            List<List<Subject>> lists = [Manager.termTemplate];
            lists.addAll(Manager.getCurrentYear().terms.map((term) => term.subjects));

            for (List<Subject> list in lists) {
              Subject item;
              if (oldIndex2 == -1) {
                item = list.removeAt(oldIndex1);
              } else {
                item = list[oldIndex1].children.removeAt(oldIndex2);
                if (list[oldIndex1].children.isEmpty) list[oldIndex1].isGroup = false;
              }
              item.isChild = newIndex2 != -1;
              if (newIndex2 == -1) {
                list.insert(newIndex1, item);
              } else {
                list[newIndex1].children.insert(newIndex2, item);
                list[newIndex1].isGroup = true;
                list[newIndex1].children.addAll(item.children);
                item.isGroup = false;
                item.isChild = true;
              }
            }

            serialize();
            rebuild();
          },
          children: buildTiles(),
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
        key: ValueKey(element),
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
          key: ValueKey(child),
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

    return result;
  }
}

List<int> getSubjectIndexes(int absoluteIndex, {int addedIndex = 0}) {
  int subjectCount = 0, index1 = 0, index2 = -1;

  for (int i = 0; i < Manager.termTemplate.length; i++) {
    int childAmount = Manager.termTemplate[i].children.length;
    if (subjectCount + childAmount + (childAmount > 0 ? addedIndex : 0) >= absoluteIndex) {
      break;
    }
    subjectCount += childAmount;
    index1 = i + 1;
    subjectCount++;
  }
  index2 = absoluteIndex - subjectCount - 1;

  return [index1, index2];
}
