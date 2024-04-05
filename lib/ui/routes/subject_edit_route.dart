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
import "package:graded/ui/utilities/hints.dart";
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

class _SubjectEditRouteState extends SpinningFabPage<SubjectEditRoute> {
  @override
  void initState() {
    super.initState();

    if (widget.creationType == CreationType.add && Manager.years.isNotEmpty && getCurrentYear(allowSetup: false).termTemplate.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translations.copy_subjects_prompt),
            action: SnackBarAction(
              label: translations.copy,
              onPressed: () {
                getCurrentYear(allowSetup: false).termTemplate.forEach((element) {
                  if (!isDuplicateName(element.name, getCurrentYear().termTemplate)) {
                    getCurrentYear().addSubject(Subject.fromSubject(element));
                  }
                });
                rebuild();
              },
            ),
          ),
        );
      });
    }
  }

  void rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.creationType == CreationType.edit ? translations.edit_subjectOther : translations.add_subjectOther;

    return PopScope(
      onPopInvoked: (didPop) {
        if (!didPop) return;
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
          enableShowcase: getPreference<bool>("showcase_subject_edit", true),
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
