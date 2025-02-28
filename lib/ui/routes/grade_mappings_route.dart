// Flutter imports:
import "package:flutter/material.dart";

// Project imports:
import "package:graded/calculations/calculator.dart";
import "package:graded/ui/utilities/grade_display_value.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/year.dart";
import "package:graded/l10n/translations.dart";
import "package:graded/misc/enums.dart";
import "package:graded/misc/storage.dart";
import "package:graded/ui/utilities/haptics.dart";
import "package:graded/ui/widgets/dialogs.dart";
import "package:graded/ui/widgets/list_widgets.dart";
import "package:graded/ui/widgets/misc_widgets.dart";
import "package:graded/ui/widgets/popup_menus.dart";

class GradeMappingRoute extends StatefulWidget {
  const GradeMappingRoute({super.key});

  @override
  State<GradeMappingRoute> createState() => _GradeMappingRouteState();
}

class _GradeMappingRouteState extends SpinningFabPage<GradeMappingRoute> {
  @override
  void initState() {
    super.initState();
    for (final Year year in Manager.years) {
      year.calculate();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        tooltip: translations.add_year,
        onPressed: () {
          setState(() {
            fabRotation += 0.5;
          });
          showGradeMappingDialog(context).then((value) {
            serialize();
            rebuild();
          });
        },
        child: SpinningIcon(
          icon: Icons.add,
          rotation: fabRotation,
        ),
      ),
      appBar: AppBar(
        title: Text(translations.grade_mappingOther),
        titleSpacing: 0,
        toolbarHeight: 64,
      ),
      body: SafeArea(
        top: false,
        maintainBottomViewPadding: true,
        child: getCurrentYear().gradeMappings.isNotEmpty
            ? ReorderableListView(
                padding: const EdgeInsets.only(bottom: 88),
                primary: true,
                buildDefaultDragHandles: false,
                onReorder: (oldIndex, newIndex) {
                  final GradeMapping gradeMapping = getCurrentYear().gradeMappings.removeAt(oldIndex);
                  getCurrentYear().gradeMappings.insert(newIndex - (newIndex > oldIndex ? 1 : 0), gradeMapping);
                  serialize();
                  rebuild();
                },
                children: [
                  for (int index = 0; index < getCurrentYear().gradeMappings.length; index++)
                    Builder(
                      key: ValueKey(getCurrentYear().gradeMappings[index]),
                      builder: (context) {
                        final GradeMapping gradeMapping = getCurrentYear().gradeMappings[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            children: [
                              Card(
                                child: ListTile(
                                  title: Text(
                                    "${Calculator.format(gradeMapping.min)} - ${Calculator.format(gradeMapping.max)}",
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                  ),
                                  horizontalTitleGap: 8,
                                  contentPadding: const EdgeInsets.only(left: 4, right: 24),
                                  leading: ReorderableDragStartListener(
                                    index: index,
                                    child: const ReorderableHandle(),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        gradeMapping.name,
                                        overflow: TextOverflow.visible,
                                        softWrap: false,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.normal,
                                            ),
                                      ),
                                    ],
                                  ),
                                  onLongPress: () {
                                    showPopupActions(context, index, gradeMapping);
                                  },
                                  onTap: () {
                                    showPopupActions(context, index, gradeMapping);
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              )
            : EmptyWidget(message: translations.no_items),
      ),
    );
  }

  void showPopupActions(BuildContext context, int index, GradeMapping gradeMapping) {
    showMenuActions<MenuAction>(context, MenuAction.values, [translations.edit, translations.delete]).then((result) {
      if (!context.mounted) return;
      switch (result) {
        case MenuAction.edit:
          showGradeMappingDialog(context, gradeMapping: gradeMapping, action: CreationType.edit).then((value) {
            serialize();
            rebuild();
          });
        case MenuAction.delete:
          heavyHaptics();

          getCurrentYear().gradeMappings.removeAt(index);
          serialize();
          rebuild();
        default:
          break;
      }
      rebuild();
    });
  }
}
