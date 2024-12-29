// Project imports:
import "package:graded/misc/enums.dart";

class DefaultValues {
  // System
  static const String data = "[]";
  static const int currentYear = 0;
  static const int currentTerm = 0;
  static const int sortMode1 = SortMode.name;
  static const int sortMode2 = SortMode.name;
  static const int sortDirection1 = SortDirection.ascending;
  static const int sortDirection2 = SortDirection.ascending;
  static const bool hasBeenSortedCustom = false;
  static const int dataVersion = -1;

  // Calculation settings
  static const int termCount = 3;
  static const double maxGrade = 60;
  static const String roundingMode = RoundingMode.up;
  static const int roundTo = 1;
  static const int preciseRoundToMultiplier = 10;
  static const bool scaleUpTests = false;
  static const double weight = 1.0;
  static const double bonus = 1;
  static const double speakingWeight = 3.0;
  static const double examWeight = 2.0;
  static const bool leadingZero = true;
  static const bool isExam = false;

  // Setup
  static const bool isFirstRun = true;
  static const String schoolSystem = "";
  static const String luxSystem = "";
  static const int year = -1;
  static const String section = "";
  static const String variant = "";

  // App settings
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
  // System
  "data": "[]",
  "currentYear": 0,
  "currentTerm": 0,
  "sortMode1": SortMode.name,
  "sortMode2": SortMode.name,
  "sortDirection1": SortDirection.ascending,
  "sortDirection2": SortDirection.ascending,
  "hasBeenSortedCustom": false,
  "dataVersion": -1,

  // Calculation settings
  "termCount": 3,
  "maxGrade": 60.0,
  "roundingMode": RoundingMode.up,
  "roundTo": 1,
  "preciseRoundToMultiplier": 10,
  "scaleUpTests": false,
  "weight": 1.0,
  "speakingWeight": 3.0,
  "examWeight": 2.0,
  "leadingZero": true,
  "isExam": false,

  // Setup
  "isFirstRun": true,
  "schoolSystem": "",
  "luxSystem": "",
  "year": -1,
  "section": "",
  "variant": "",

  // Showcase
  "showcaseSubjectEdit": true,
  "showcasePreciseAverage": true,

  // App settings
  "theme": "system",
  "brightness": "dark",
  "amoled": false,
  "dynamicColor": true,
  "customColor": 0xFF2196f3,
  "font": "montserrat",
  "language": "system",
  "hapticFeedback": true,
};
