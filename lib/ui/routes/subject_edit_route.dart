// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:showcaseview/showcaseview.dart";

// Project imports:
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/localization/translations.dart";
import "package:graded/misc/enums.dart";
import "package:graded/misc/storage.dart";
import "package:graded/ui/widgets/dialogs.dart";
import "package:graded/ui/widgets/list_widgets.dart";
import "package:graded/ui/widgets/misc_widgets.dart";
import "package:graded/ui/widgets/popup_menus.dart";

final GlobalKey showCaseKey1 = GlobalKey();
final GlobalKey showCaseKey2 = GlobalKey();

class SubjectEditRoute extends StatefulWidget {
  const SubjectEditRoute({
    super.key,
    this.creationType = CreationType.edit,
  });

  final CreationType creationType;

  @override
  State<SubjectEditRoute> createState() => _SubjectEditRouteState();
}

class _SubjectEditRouteState extends State<SubjectEditRoute> {
  double fabRotation = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500)).then((_) {
      setState(() {
        fabRotation += 0.5;
      });
    });
  }

  void rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.creationType == CreationType.edit ? translations.edit_subjectOther : translations.add_subjectOther;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: translations.add_subjectOne,
        onPressed: () {
          setState(() {
            fabRotation += 0.5;
          });
          showSubjectDialog(context).then((_) => rebuild());
        },
        child: SpinningIcon(
          icon: Icons.add,
          rotation: fabRotation,
        ),
      ),
      appBar: AppBar(
        title: Text(title),
        titleSpacing: 0,
        toolbarHeight: 64,
        actions: [
          SortAction(
            onTap: rebuild,
            sortType: SortType.subject,
          ),
        ],
      ),
      body: ShowCaseWidget(
        blurValue: 1,
        onFinish: () {
          setPreference<bool>("showcase_subject_edit", false);
          rebuild();
        },
        builder: Builder(
          builder: (context) {
            return SafeArea(
              top: false,
              bottom: false,
              child: getCurrentYear().termTemplate.isNotEmpty
                  ? ReorderableListView(
                      padding: EdgeInsets.only(bottom: 88 + MediaQuery.paddingOf(context).bottom),
                      primary: true,
                      buildDefaultDragHandles: false,
                      onReorder: (int oldIndex, int newIndex) {
                        getCurrentYear().reorderSubjects(oldIndex, newIndex);
                        rebuild();
                      },
                      children: buildTiles(),
                    )
                  : EmptyWidget(message: translations.no_subjects),
            );
          },
        ),
      ),
    );
  }

  List<Widget> buildTiles() {
    final List<Widget> result = [];
    int reorderIndex = 0;

    for (int i = 0; i < getCurrentYear().termTemplate.length; i++) {
      final Subject element = getCurrentYear().termTemplate[i];
      result.add(
        SubjectTile(
          key: ValueKey(element),
          subject: element,
          listKey: GlobalKey(),
          index1: i,
          reorderIndex: reorderIndex,
          onActionCompleted: rebuild,
        ),
      );
      reorderIndex++;
      for (int j = 0; j < element.children.length; j++) {
        final Subject child = element.children[j];
        result.add(
          SubjectTile(
            key: ValueKey(child),
            subject: child,
            listKey: GlobalKey(),
            index1: i,
            index2: j,
            reorderIndex: reorderIndex,
            onActionCompleted: rebuild,
          ),
        );
        reorderIndex++;
      }
    }

    return result;
  }
}
