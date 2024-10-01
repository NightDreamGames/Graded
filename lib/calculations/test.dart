// Project imports:
import "package:graded/calculations/calculation_object.dart";
import "package:graded/calculations/calculator.dart";
import "package:graded/misc/default_values.dart";

class Test extends CalculationObject {
  @override
  double? numerator;
  @override
  double denominator = 0;
  bool isSpeaking = false;
  int timestamp = 0;
  bool isEmpty = false;

  Test(
    this.numerator,
    this.denominator, {
    String name = "",
    double weight = DefaultValues.weight,
    this.isEmpty = false,
    this.isSpeaking = false,
    int? timestamp,
  }) {
    super.name = name;
    super.weight = weight;
    calculate();
    if (result == null) numerator = null;

    final DateTime now = DateTime.now();
    this.timestamp = timestamp ?? DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
  }

  @override
  void calculate() {
    result = isEmpty ? null : Calculator.calculate([this], clamp: false);
    preciseResult = isEmpty ? null : Calculator.calculate([this], clamp: false, precise: true);
  }

  @override
  String toString() {
    if (result == null) return "-";
    return "${Calculator.format(numerator)}/${Calculator.format(denominator, roundToOverride: 1)}";
  }

  Test.fromTest(Test test) {
    denominator = test.denominator;
    name = test.name;
    weight = test.weight;
    isSpeaking = test.isSpeaking;
    numerator = test.numerator;
    timestamp = test.timestamp;
    calculate();
  }

  Test.fromJson(Map<String, dynamic> json) {
    numerator = json["numerator"] as double?;
    denominator = json["denominator"] as double;
    name = json["name"] as String;
    weight = json["weight"] as double? ?? 1;
    isSpeaking = json["isSpeaking"] as bool? ?? false;
    calculate();
    if (result == null) numerator = null;
    timestamp = json["timestamp"] as int? ?? DateTime(2021, 9, 15).millisecondsSinceEpoch;
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "numerator": numerator,
        "denominator": denominator,
        "weight": weight,
        "isSpeaking": isSpeaking,
        "timestamp": timestamp,
      };
}
