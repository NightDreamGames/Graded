// Dart imports:
import "dart:math";

// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:fl_chart/fl_chart.dart";
import "package:intl/intl.dart";

// Project imports:
import "package:graded/calculations/subject.dart";
import "package:graded/calculations/term.dart";
import "package:graded/ui/utilities/hints.dart";

double getHighestAverage({required Subject subject}) {
  double highest = 0;

  for (final t in subject.terms) {
    if (t.result != null && t.result! > highest) {
      highest = t.result!;
    }
  }

  return highest;
}

double getHighestTest({required Subject subject}) {
  double highest = 0;

  for (final t in subject.terms) {
    for (final test in t.tests) {
      if (test.result != null && test.result! > highest) {
        highest = test.result!;
      }
    }
  }

  return highest;
}

List<FlSpot> getSubjectResultSpots({required Subject subject}) {
  final List<FlSpot> spots = <FlSpot>[];

  for (int i = 0; i < subject.terms.length; i++) {
    final Term term = subject.terms[i];
    if (term.result == null) continue;

    spots.add(FlSpot(i.toDouble(), term.result!));
  }
  return spots;
}

List<FlSpot> getSubjectTestSpots({required Subject subject}) {
  final List<FlSpot> spots = <FlSpot>[];

  for (final t in subject.terms) {
    for (final test in t.tests) {
      if (test.result == null) continue;

      double truncatedTimestamp = test.timestamp.toDouble();

      while (spots.any((element) => element.x == truncatedTimestamp)) {
        truncatedTimestamp += 0.1;
      }

      spots.add(FlSpot(truncatedTimestamp, test.result!));
    }
  }

  spots.sort((a, b) => a.x.compareTo(b.x));

  return spots;
}

Widget getBottomWidget(String value, TitleMeta meta) {
  const style = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );
  Widget text;

  text = Text(value, style: style);

  return SideTitleWidget(
    meta: meta,
    child: text,
  );
}

Widget getTermBottomWidgets(double value, TitleMeta meta) {
  return getBottomWidget(getTermNameShort(termIndex: value.toInt()), meta);
}

Widget getDateBottomWidgets(double value, TitleMeta meta) {
  final DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());

  if (date.day != 1 || (date.month % 2) == 0) return const SizedBox();

  return getBottomWidget(DateFormat.MMM().format(date), meta);
}

Widget getLeftTitleWidgets(double value, TitleMeta meta) {
  const style = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  final String text = "${value.toInt()}";
  return Text(text, style: style, textAlign: TextAlign.left);
}

List<FlSpot> calculateRollingAverage(List<FlSpot> data, int windowSize, {double? minX, double? maxX}) {
  final List<FlSpot> rollingAverage = [];
  final List<FlSpot> dataCopy = [];

  dataCopy.addAll(data);

  if (minX != null && dataCopy.isNotEmpty && dataCopy.first.x != minX) {
    rollingAverage.insert(0, FlSpot(minX, dataCopy.first.y));
  }

  if (maxX != null && dataCopy.isNotEmpty && dataCopy.last.x != maxX) {
    dataCopy.add(FlSpot(maxX, dataCopy.last.y));
  }

  for (int i = 0; i < dataCopy.length; i++) {
    double weightedSum = 0;
    double weightSum = 0;
    double lastResult = 0;

    for (int j = i; j >= 0 && j > i - windowSize; j--) {
      final bool isHigher = dataCopy[j].y >= lastResult;

      double weight = 1 + log(windowSize - (i - j));
      weight *= isHigher ? 1.5 : 1;

      weightedSum += dataCopy[j].y * weight;
      weightSum += weight;
      lastResult = dataCopy[j].y;
    }

    rollingAverage.add(FlSpot(dataCopy[i].x, weightedSum / weightSum));
  }

  return rollingAverage;
}
