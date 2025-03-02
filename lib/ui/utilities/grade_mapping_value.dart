// Dart imports:
import "dart:ui";

// Package imports:
import "package:flex_color_scheme/flex_color_scheme.dart";

class GradeMapping {
  double min;
  double max;
  String name;
  Color? color;

  GradeMapping(
    this.min,
    this.max,
    this.name, {
    this.color,
  });

  GradeMapping.fromJson(Map<String, dynamic> json)
      : min = json["min"] as double,
        max = json["max"] as double,
        name = (json["value"] as String?) ?? "",
        color = json["color"] != null ? Color(json["color"] as int) : null;

  Map<String, dynamic> toJson() => {
        "min": min,
        "max": max,
        "value": name,
        "color": color?.value32bit,
      };
}
