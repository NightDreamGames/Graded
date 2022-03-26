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
}
