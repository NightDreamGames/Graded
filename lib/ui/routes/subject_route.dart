// Dart imports:
import "dart:math";

// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:fading_edge_scrollview/fading_edge_scrollview.dart";

// Project imports:
import "package:graded/calculations/calculator.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/calculations/test.dart";
import "package:graded/calculations/year.dart";
import "package:graded/l10n/translations.dart";
import "package:graded/misc/enums.dart";
import "package:graded/ui/utilities/haptics.dart";
import "package:graded/ui/widgets/custom_safe_area.dart";
import "package:graded/ui/widgets/dialogs.dart";
import "package:graded/ui/widgets/list_widgets.dart";
import "package:graded/ui/widgets/misc_widgets.dart";
import "package:graded/ui/widgets/popup_menus.dart";

class SubjectRoute extends StatefulWidget {
  const SubjectRoute({
    super.key,
    required this.year,
    required this.termIndex,
    required this.subject,
    this.parent,
  });

  final Year year;
  final int termIndex;
  final Subject subject;
  final Subject? parent;

  @override
  State<SubjectRoute> createState() => _SubjectRouteState();
}

class _SubjectRouteState extends SpinningFabPage<SubjectRoute> {
  final ScrollController scrollController = ScrollController();

  void rebuild() {
    setState(() {});
  }

  void refreshYearOverview() {
    Manager.refreshYearOverview();
    rebuild();
  }

  @override
  Widget build(BuildContext context) {
    final List<Test> testData = Calculator.getSortedTestData(widget.subject.terms[widget.termIndex].tests);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: !widget.year.isYearOverview
          ? FloatingActionButton(
              tooltip: translations.add_test,
              heroTag: null,
              onPressed: () {
                setState(() {
                  fabRotation += 0.5;
                });
                showTestDialog(context, widget.subject.terms[widget.termIndex]).then((_) => refreshYearOverview());
              },
              child: SpinningIcon(
                icon: Icons.add,
                rotation: fabRotation,
              ),
            )
          : null,
      body: Builder(
        builder: (context) {
          return CustomScrollView(
            slivers: [
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverSafeArea(
                top: false,
                bottom: false,
                sliver: SliverToBoxAdapter(
                  child: ResultRow(
                    result: widget.subject.getTermResultString(widget.termIndex),
                    preciseResult: widget.subject.getTermResultString(widget.termIndex, precise: true),
                    gradeMapping: Calculator.getGradeMapping(widget.subject.getTermResult(widget.termIndex)),
                    leading: FadingEdgeScrollView.fromSingleChildScrollView(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (!widget.year.isYearOverview)
                              ElevatedButton(
                                onPressed: () {
                                  showBonusDialog(context, widget.subject.terms[widget.termIndex]).then((_) => refreshYearOverview());
                                },
                                style: getTonalButtonStyle(context),
                                child: Text(
                                  "${translations.bonus}: ${Calculator.format(
                                    widget.subject.terms[widget.termIndex].bonus,
                                    leadingZero: false,
                                    showPlusSign: true,
                                  )}",
                                ),
                              )
                            else
                              Text(
                                translations.yearly_average,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            const Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
                            IconButton.filledTonal(
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                  "/chart",
                                  arguments: [
                                    widget.parent,
                                    widget.subject,
                                  ],
                                );
                              },
                              icon: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationY(pi),
                                child: const Icon(
                                  Icons.stacked_bar_chart,
                                ),
                              ),
                              tooltip: translations.chartOther,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              CustomSliverSafeArea(
                top: false,
                maintainBottomViewPadding: true,
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: testData.length,
                    (context, index) {
                      return Builder(
                        builder: (context) {
                          return TextRow(
                            leadingText: testData[index].name,
                            trailingText: testData[index].toString(),
                            enableEqualLongPress: true,
                            onTap: () {
                              if (widget.year.isYearOverview) return;

                              showMenuActions<MenuAction>(context, MenuAction.values, [translations.edit, translations.delete]).then((result) {
                                switch (result) {
                                  case MenuAction.edit:
                                    if (!context.mounted) return;
                                    showTestDialog(context, widget.subject.terms[widget.termIndex], test: testData[index])
                                        .then((_) => refreshYearOverview());
                                  case MenuAction.delete:
                                    heavyHaptics();
                                    widget.subject.terms[widget.termIndex].removeTest(testData[index]);
                                    refreshYearOverview();
                                  default:
                                    break;
                                }
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              if (testData.isEmpty) SliverEmptyWidget(message: translations.no_grades),
              const SliverPadding(padding: EdgeInsets.only(bottom: 88)),
            ],
          );
        },
      ),
    );
  }
}
