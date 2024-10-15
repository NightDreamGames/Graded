// Dart imports:
import "dart:math";

// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:fl_chart/fl_chart.dart";

// Project imports:
import "package:graded/calculations/calculator.dart";
import "package:graded/ui/utilities/chart_utilities.dart";

class StandardLineChart extends StatefulWidget {
  const StandardLineChart({
    super.key,
    this.title = "",
    required this.spots,
    this.minX = 0,
    this.maxX,
    this.minY = 0,
    this.maxY,
    this.xLabelInterval,
    this.xGridInterval = 1,
    this.yGridInterval = 10,
    this.getBottomTitleWidget,
    this.getLeftTitleWidget,
    this.autoMinX = false,
    this.autoMinY = false,
    this.showRollingAverage = false,
  });

  final String title;

  final List<FlSpot> spots;
  final double minX;
  final double? maxX;
  final double minY;
  final double? maxY;
  final int? xLabelInterval;
  final int xGridInterval;
  final int yGridInterval;

  final bool autoMinX;
  final bool autoMinY;
  final bool showRollingAverage;

  final Widget Function(double, TitleMeta)? getBottomTitleWidget;
  final Widget Function(double, TitleMeta)? getLeftTitleWidget;

  @override
  State<StandardLineChart> createState() => _StandardLineChartState();
}

class _StandardLineChartState extends State<StandardLineChart> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.titleLarge,
            softWrap: true,
            overflow: TextOverflow.fade,
          ),
        ),
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 24,
              left: 16,
              top: 16,
              bottom: 8,
            ),
            child: LineChart(
              mainData(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData mainData() {
    final double? minX = widget.autoMinX ? null : widget.minX;
    final double maxX = () {
      final double spotMax = widget.spots.fold(0, (previousValue, element) => max(previousValue, element.x));
      if (widget.maxX == null) return spotMax;
      return max(widget.maxX!, spotMax);
    }();
    final double? minY = widget.autoMinY ? null : 0;
    final double? maxY = widget.maxY;

    return LineChartData(
      gridData: FlGridData(
        horizontalInterval: widget.yGridInterval.toDouble(),
        verticalInterval: widget.xGridInterval.toDouble(),
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(),
        topTitles: const AxisTitles(),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: widget.xLabelInterval?.toDouble(),
            getTitlesWidget: widget.getBottomTitleWidget ?? defaultGetTitle,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxY != null ? maxY / 2 : null,
            getTitlesWidget: widget.getLeftTitleWidget ?? defaultGetTitle,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest),
      ),
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      lineTouchData: LineTouchData(
        touchSpotThreshold: 30,
        touchTooltipData: LineTouchTooltipData(
          fitInsideVertically: true,
          getTooltipColor: (spot) => Theme.of(context).colorScheme.primary,
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              if (touchedSpot.barIndex != 0) return null;
              final TextStyle textStyle = Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  );
              return LineTooltipItem(
                Calculator.format(touchedSpot.y),
                textStyle,
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: widget.spots,
          isCurved: true,
          color: Theme.of(context).colorScheme.primary,
          barWidth: 5,
          isStrokeCapRound: true,
          preventCurveOverShooting: true,
          belowBarData: BarAreaData(
            show: true,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
          ),
        ),
        if (widget.showRollingAverage)
          LineChartBarData(
            spots: calculateRollingAverage(widget.spots, 2, minX: minX, maxX: maxX),
            isCurved: true,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            barWidth: 3,
            isStrokeCapRound: true,
            preventCurveOverShooting: true,
            dashArray: const [5, 8],
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
            ),
          ),
      ],
    );
  }
}
