// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:showcaseview/showcaseview.dart";

// Project imports:
import "package:graded/calculations/calculator.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/calculations/term.dart";
import "package:graded/localization/translations.dart";
import "package:graded/misc/storage.dart";
import "package:graded/ui/widgets/custom_safe_area.dart";
import "package:graded/ui/widgets/dialogs.dart";
import "package:graded/ui/widgets/list_widgets.dart";
import "package:graded/ui/widgets/misc_widgets.dart";

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.term,
  });

  final Term term;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey showCaseKey = GlobalKey();
  late bool shouldShowcase;

  void rebuild() {
    setState(() {});
  }

  void refreshYearOverview() {
    Manager.refreshYearOverview();
    rebuild();
  }

  Future<void> showTutorial(BuildContext context) async {
    if (!shouldShowcase) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500), () {
        if (!shouldShowcase || !mounted || context.findAncestorWidgetOfExactType<ShowCaseWidget>() == null) return;
        ShowCaseWidget.of(context).startShowCase([showCaseKey]);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = Calculator.getSortedSubjectData(widget.term.subjects);
    final List<Subject> subjectData = data.$1;
    final List<List<Subject>> childrenData = data.$2;

    shouldShowcase = subjectData.fold<int>(0, (previousValue, element) => previousValue + (element.result != null ? 1 : 0)) >= 3 &&
        getPreference<bool>("showcase_precise_average", true);

    return ShowCaseWidget(
      blurValue: 1,
      disableBarrierInteraction: true,
      onFinish: () {
        setPreference<bool>("showcase_precise_average", false);
        rebuild();
      },
      enableShowcase: shouldShowcase,
      builder: Builder(
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
                              result: widget.term.getResult(),
                              preciseResult: widget.term.getResult(precise: true),
                              leading: Text(
                                widget.term.isYearOverview ? translations.yearly_average : translations.average,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            );

                            if (shouldShowcase) {
                              // TODO: Change preciseValue on tap
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
                                trailingText: subjectData[index].getResult(),
                                trailing: const Icon(Icons.navigate_next),
                                onTap: () {
                                  Navigator.pushNamed(context, "/subject", arguments: [null, subjectData[index]]).then((_) => refreshYearOverview());
                                },
                                onLongPress: () {
                                  showTestDialog(context, subjectData[index]).then((_) => refreshYearOverview());
                                },
                              );
                            } else {
                              return GroupRow(
                                leadingText: subjectData[index].name,
                                trailingText: subjectData[index].getResult(),
                                children: [
                                  const Divider(),
                                  for (int i = 0; i < childrenData[index].length; i++)
                                    Column(
                                      children: [
                                        TextRow(
                                          leadingText: childrenData[index][i].name,
                                          trailingText: childrenData[index][i].getResult(),
                                          trailing: const Icon(Icons.navigate_next),
                                          padding: const EdgeInsets.only(left: 36, right: 24),
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              "/subject",
                                              arguments: [subjectData[index], childrenData[index][i]],
                                            ).then((_) => refreshYearOverview());
                                          },
                                          onLongPress: () {
                                            showTestDialog(context, childrenData[index][i]).then((_) => refreshYearOverview());
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
      ),
    );
  }
}
