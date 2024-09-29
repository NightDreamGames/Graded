abstract class SortMode {
  static const int name = 0;
  static const int result = 1;
  static const int coefficient = 2;
  static const int custom = 3;
  static const int timestamp = 4;
}

abstract class SortDirection {
  static const int ascending = 1;
  static const int descending = -1;
}

abstract class SortType {
  static const int subject = 1;
  static const int test = 2;
}

abstract class RoundingMode {
  static const String up = "rounding_up";
  static const String down = "rounding_down";
  static const String halfUp = "rounding_half_up";
  static const String halfDown = "rounding_half_down";
}

enum MenuAction { edit, delete }

enum YearAction { select, edit, delete }

enum CreationType { add, edit }
