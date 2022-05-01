import 'package:gradely/Calculations/calculator.dart';

class Test {
  double grade1 = 0;
  double grade2 = 0;
  String name = "";
  String nameResource = "";

  Test(this.grade1, this.grade2, this.name, {this.nameResource = ""});

  @override
  String toString() {
    return Calculator.format(grade1) + "/" + Calculator.format(grade2);
  }

  Test.fromJson(Map<String, dynamic> json)
      : grade1 = json['grade1'],
        grade2 = json['grade2'],
        name = json['name'],
        nameResource = json['name_resource'] ?? "";

  Map<String, dynamic> toJson() => {
        "grade1": grade1,
        "grade2": grade2,
        "name": name,
        "name_resource": nameResource,
      };
}
