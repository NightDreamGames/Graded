// Dart imports:
import "dart:math";

// Flutter imports:
import "package:flutter/material.dart";

// Project imports:
import "package:graded/calculations/calculator.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/l10n/translations.dart";
import "package:graded/ui/utilities/chart_utilities.dart";
import "package:graded/ui/widgets/charts.dart";
import "package:graded/ui/widgets/custom_safe_area.dart";
import "package:graded/ui/widgets/list_widgets.dart";

class ChartRoute extends StatefulWidget {
  const ChartRoute({
    super.key,
    required this.subject,
  });

  final Subject subject;

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
                sliver: SliverToBoxAdapter(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ResultRow(
                        result: widget.subject.getResultString(),
                        preciseResult: widget.subject.getResultString(precise: true),
                        gradeMapping: Calculator.format(widget.subject.result, applyGradeMappings: true),
                        leading: Text(
                          translations.yearly_average,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 8)),
                      StandardLineChart(
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
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(),
                      ),
                      Builder(
                        builder: (context) {
                          final spots = getSubjectTestSpots(
                            subject: widget.subject,
                          );

                          double lowestX = spots.firstOrNull?.x ?? 0;
                          final DateTime lowestDate = DateTime.fromMillisecondsSinceEpoch(lowestX.toInt());
                          if (lowestDate.month >= 9) {
                            lowestX = DateTime(lowestDate.year, 9).millisecondsSinceEpoch.toDouble();
                          } else {
                            lowestX = DateTime(lowestDate.year - 1, 9).millisecondsSinceEpoch.toDouble();
                          }

                          double highestX = spots.firstOrNull?.x ?? 0;
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
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
