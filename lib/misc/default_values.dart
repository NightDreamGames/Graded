// Project imports:
import "package:graded/misc/enums.dart";

class DefaultValues {
  //System
  static const String data = "[]";
  static const int currentYear = 0;
  static const int currentTerm = 0;
  static const int sortMode1 = SortMode.name;
  static const int sortMode2 = SortMode.name;
  static const int sortDirection1 = SortDirection.ascending;
  static const int sortDirection2 = SortDirection.ascending;
  static const int dataVersion = -1;

  //Calculation settings
  static const int termCount = 3;
  static const double maxGrade = 60.0;
  static const String roundingMode = RoundingMode.up;
  static const int roundTo = 1;
  static const int preciseRoundToMultiplier = 10;
  static const double weight = 1.0;
  static const double bonus = 1;
  static const double speakingWeight = 3.0;
  static const double examWeight = 2.0;
  static const bool leadingZero = true;

  //Setup
  static const bool isFirstRun = true;
  static const String schoolSystem = "";
  static const String luxSystem = "";
  static const int year = -1;
  static const String section = "";
  static const String variant = "";

  //App settings
  static const String theme = "system";
  static const String brightness = "dark";
  static const bool amoled = false;
  static const bool dynamicColor = true;
  static const int customColor = 0xFF2196f3;
  static const String font = "montserrat";
  static const String language = "system";
  static const bool hapticFeedback = true;
}

const Map<String, dynamic> defaultValues = {
  //System
  "data": "[]",
  "current_year": 0,
  "current_term": 0,
  "sort_mode1": SortMode.name,
  "sort_mode2": SortMode.name,
  "sort_direction1": SortDirection.ascending,
  "sort_direction2": SortDirection.ascending,
  "data_version": -1,

  //Calculation settings
  "term_count": 3,
  "max_grade": 60.0,
  "rounding_mode": RoundingMode.up,
  "round_to": 1,
  "precise_round_to_multiplier": 10,
  "weight": 1.0,
  "speaking_weight": 3.0,
  "exam_weight": 2.0,
  "leading_zero": true,

  //Setup
  "is_first_run": true,
  "school_system": "",
  "lux_system": "",
  "year": -1,
  "section": "",
  "variant": "",

  //App settings
  "theme": "system",
  "brightness": "dark",
  "amoled": false,
  "dynamic_color": true,
  "custom_color": 0xFF2196f3,
  "font": "montserrat",
  "language": "system",
  "haptic_feedback": true,
};
