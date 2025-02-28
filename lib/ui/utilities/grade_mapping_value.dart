class GradeMapping {
  double min;
  double max;
  String name;

  GradeMapping(this.min, this.max, this.name);

  GradeMapping.fromJson(Map<String, dynamic> json)
      : min = json["min"] as double,
        max = json["max"] as double,
        name = (json["value"] as String?) ?? "";

  Map<String, dynamic> toJson() => {
        "min": min,
        "max": max,
        "value": name,
      };
}
