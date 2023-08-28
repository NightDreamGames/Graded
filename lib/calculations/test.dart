// Project imports:
import "package:graded/calculations/calculation_object.dart";
import "package:graded/calculations/calculator.dart";

class Test extends CalculationObject {
  @override
  double? numerator;
  @override
  double denominator = 0;
  bool isSpeaking = false;
  int timestamp = 0;

  Test(this.numerator, this.denominator, {String name = "", double coefficient = 1, bool isEmpty = false, this.isSpeaking = false, int? timestamp}) {
    super.name = name;
    super.coefficient = coefficient;
    result = isEmpty ? null : Calculator.calculate([this]);
    if (result == null) numerator = null;

    final DateTime now = DateTime.now();
    this.timestamp = timestamp ?? DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
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

  Test.fromJson(Map<String, dynamic> json) {
    numerator = json["grade1"] as double?;
    denominator = json["grade2"] as double;
    name = json["name"] as String;
    coefficient = json["coefficient"] as double? ?? 1;
    isSpeaking = json["isSpeaking"] as bool? ?? false;
    result = Calculator.calculate([this]);
    if (result == null) numerator = null;
    timestamp = json["timestamp"] as int? ?? DateTime(2021, 9, 15).millisecondsSinceEpoch;
  }

  Map<String, dynamic> toJson() => {
        "grade1": numerator,
        "grade2": denominator,
        "name": name,
        "coefficient": coefficient,
        "isSpeaking": isSpeaking,
        "timestamp": timestamp,
      };
}
