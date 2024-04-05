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

  void calculate() {
    result = isEmpty ? null : Calculator.calculate([this], clamp: false);
  }

  @override
  String toString() {
    if (result == null) return "-";
    return "${Calculator.format(numerator)}/${Calculator.format(denominator, roundToOverride: 1)}";
  }

  @override
  String getResult({bool precise = false}) {
    if (result == null) return "-";
    return Calculator.format(result);
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
    numerator = json["grade1"] as double?;
    denominator = json["grade2"] as double;
    name = json["name"] as String;
    weight = json["coefficient"] as double? ?? 1;
    isSpeaking = json["isSpeaking"] as bool? ?? false;
    calculate();
    if (result == null) numerator = null;
    timestamp = json["timestamp"] as int? ?? DateTime(2021, 9, 15).millisecondsSinceEpoch;
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "grade1": numerator,
        "grade2": denominator,
        "coefficient": weight,
        "isSpeaking": isSpeaking,
        "timestamp": timestamp,
      };
}
