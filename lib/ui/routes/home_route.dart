// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:showcaseview/showcaseview.dart";

// Project imports:
import "package:graded/calculations/calculator.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/calculations/year.dart";
import "package:graded/l10n/translations.dart";
import "package:graded/misc/storage.dart";
import "package:graded/ui/widgets/custom_safe_area.dart";
import "package:graded/ui/widgets/dialogs.dart";
import "package:graded/ui/widgets/list_widgets.dart";
import "package:graded/ui/widgets/misc_widgets.dart";

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.year,
    required this.termIndex,
    this.isYearOverview = false,
  });

  final Year year;
  final int termIndex;
  final bool isYearOverview;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey showCaseKey = GlobalKey();
  late bool shouldShowcase;
  bool showcasing = false;

  void rebuild() {
    setState(() {});
  }

  void refreshYearOverview() {
    Manager.refreshYearOverview();
    rebuild();
  }

  Future<void> showTutorial(BuildContext context) async {
    if (!shouldShowcase || showcasing) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500), () {
        if (!shouldShowcase || showcasing || !context.mounted || context.findAncestorWidgetOfExactType<ShowCaseWidget>() == null) return;
        ShowCaseWidget.of(context).startShowCase([showCaseKey]);
        showcasing = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = Calculator.getSortedSubjectData(
      widget.isYearOverview ? widget.year.yearOverview.subjects : widget.year.subjects,
      termIndex: widget.isYearOverview ? null : widget.termIndex,
    );
    final List<Subject> subjectData = data.$1;
    final List<List<Subject>> childrenData = data.$2;

    final referenceData = Calculator.getSortedSubjectData(
      widget.year.subjects,
      termIndex: widget.isYearOverview ? null : widget.termIndex,
    );
    final List<Subject> subjectReferenceData = referenceData.$1;
    final List<List<Subject>> childrenReferenceData = referenceData.$2;

    shouldShowcase = subjectData.fold<int>(0, (previousValue, element) => previousValue + (element.result != null ? 1 : 0)) >= 3 &&
        getPreference<bool>("showcasePreciseAverage");

    return ShowCaseWidget(
      blurValue: 1,
      disableBarrierInteraction: true,
      onFinish: () {
        setPreference<bool>("showcasePreciseAverage", false);
        rebuild();
      },
      enableShowcase: shouldShowcase,
      builder: (context) {
        return SafeArea(
          top: false,
          bottom: false,
          child: Builder(
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
                      child: Builder(
                        builder: (context) {
                          showTutorial(context);

                          final Widget child = ResultRow(
                            result: widget.isYearOverview
                                ? widget.year.yearOverview.getResultString()
                                : widget.year.getTermResultString(widget.termIndex),
                            preciseResult: widget.isYearOverview
                                ? widget.year.yearOverview.getResultString(precise: true)
                                : widget.year.getTermResultString(widget.termIndex, precise: true),
                            gradeMapping: Calculator.format(
                                widget.isYearOverview ? widget.year.yearOverview.result : widget.year.getTermResult(widget.termIndex),
                                applyGradeMappings: true),
                            leading: Text(
                              widget.isYearOverview ? translations.yearly_average : translations.average,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          );

                          if (shouldShowcase) {
                            // TODO: Change preciseValue on tap doesn't work
                            return Showcase(
                              key: showCaseKey,
                              description: translations.showcase_precise_average,
                              scaleAnimationCurve: Easing.standardDecelerate,
                              child: child,
                            );
                          } else {
                            return child;
                          }
                        },
                      ),
                    ),
                  ),
                  CustomSliverSafeArea(
                    top: false,
                    maintainBottomViewPadding: true,
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: subjectData.length,
                        (context, index) {
                          if (!subjectData[index].isGroup) {
                            return TextRow(
                              leadingText: subjectData[index].name,
                              trailingText: subjectData[index].getTermResultString(widget.termIndex),
                              gradeMapping: Calculator.format(subjectData[index].getTermResult(widget.termIndex), applyGradeMappings: true),
                              trailing: const Icon(Icons.navigate_next),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  "/subject",
                                  arguments: [null, subjectReferenceData[index]],
                                ).then((_) => refreshYearOverview());
                              },
                              onLongPress: () {
                                if (widget.isYearOverview) return;
                                showTestDialog(context, subjectData[index].terms[widget.termIndex]).then((_) => refreshYearOverview());
                              },
                            );
                          } else {
                            return GroupRow(
                              leadingText: subjectData[index].name,
                              trailingText: subjectData[index].getTermResultString(widget.termIndex),
                              children: [
                                const Divider(),
                                for (int i = 0; i < childrenData[index].length; i++)
                                  Column(
                                    children: [
                                      TextRow(
                                        leadingText: childrenData[index][i].name,
                                        trailingText: childrenData[index][i].getTermResultString(widget.termIndex),
                                        gradeMapping:
                                            Calculator.format(childrenData[index][i].getTermResult(widget.termIndex), applyGradeMappings: true),
                                        trailing: const Icon(Icons.navigate_next),
                                        padding: const EdgeInsets.only(left: 36, right: 24),
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            "/subject",
                                            arguments: [subjectReferenceData[index], childrenReferenceData[index][i]],
                                          ).then((_) => refreshYearOverview());
                                        },
                                        onLongPress: () {
                                          showTestDialog(context, childrenData[index][i].terms[widget.termIndex]).then((_) => refreshYearOverview());
                                        },
                                        isChild: true,
                                      ),
                                      if (i != childrenData[index].length - 1) Divider(indent: Theme.of(context).dividerTheme.indent! + 16),
                                    ],
                                  ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  if (subjectData.isEmpty) SliverEmptyWidget(message: translations.no_subjects),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
