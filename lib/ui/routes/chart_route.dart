// Dart imports:
import "dart:math";

// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:sliver_tools/sliver_tools.dart";

// Project imports:
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/calculations/term.dart";
import "package:graded/localization/translations.dart";
import "package:graded/ui/utilities/chart_utilities.dart";
import "package:graded/ui/widgets/charts.dart";
import "package:graded/ui/widgets/custom_safe_area.dart";
import "package:graded/ui/widgets/list_widgets.dart";

class ChartRoute extends StatefulWidget {
  const ChartRoute({
    super.key,
    required this.term,
    required this.subject,
    this.parent,
  });

  final Term term;
  final Subject subject;
  final Subject? parent;

  @override
  State<ChartRoute> createState() => _ChartRouteState();
}

class _ChartRouteState extends State<ChartRoute> {
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Builder(
        builder: (context) {
          return CustomScrollView(
            slivers: [
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              CustomSliverSafeArea(
                top: false,
                maintainBottomViewPadding: true,
                sliver: MultiSliver(
                  children: [
                    SliverToBoxAdapter(
                      child: ResultRow(
                        result: widget.subject.getResult(),
                        preciseResult: widget.subject.getResult(precise: true),
                        leading: Text(
                          translations.yearly_average,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    const SliverPadding(padding: EdgeInsets.only(top: 8)),
                    SliverToBoxAdapter(
                      child: StandardLineChart(
                        title: translations.average_over_time,
                        spots: getSubjectResultSpots(
                          subject: widget.subject,
                        ),
                        maxY: max(getHighestAverage(subject: widget.subject), getCurrentYear().maxGrade),
                        maxX: getCurrentYear().termCount - 1,
                        xLabelInterval: 1,
                        getBottomTitleWidget: getTermBottomWidgets,
                        getLeftTitleWidget: getLeftTitleWidgets,
                        showRollingAverage: true,
                      ),
                    ),
                    const SliverPadding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      sliver: SliverToBoxAdapter(
                        child: Divider(),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Builder(
                        builder: (context) {
                          final spots = getSubjectTestSpots(
                            subject: widget.subject,
                          );

                          double lowestX = spots[0].x;
                          final DateTime lowestDate = DateTime.fromMillisecondsSinceEpoch(lowestX.toInt());
                          if (lowestDate.month >= 9) {
                            lowestX = DateTime(lowestDate.year, 9).millisecondsSinceEpoch.toDouble();
                          } else {
                            lowestX = DateTime(lowestDate.year - 1, 9).millisecondsSinceEpoch.toDouble();
                          }

                          double highestX = spots[0].x;
                          final DateTime highestDate = DateTime.fromMillisecondsSinceEpoch(highestX.toInt());
                          if (highestDate.month >= 9) {
                            highestX = DateTime(highestDate.year + 1, 9).millisecondsSinceEpoch.toDouble();
                          } else {
                            highestX = DateTime(highestDate.year, 9).millisecondsSinceEpoch.toDouble();
                          }

                          return StandardLineChart(
                            title: translations.testOther,
                            spots: spots,
                            minX: lowestX,
                            maxX: highestX,
                            maxY: max(getHighestTest(subject: widget.subject), getCurrentYear().maxGrade),
                            xGridInterval: 2629746000, // 1 month
                            xLabelInterval: Duration.millisecondsPerDay,
                            getBottomTitleWidget: getDateBottomWidgets,
                            getLeftTitleWidget: getLeftTitleWidgets,
                            showRollingAverage: true,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
