// Project imports:
import "package:graded/misc/enums.dart";

final Map<String, dynamic> defaultValues = {
  //System
  "data": "",
  "default_data": "",
  "current_term": 0,
  "sort_mode1": SortMode.name,
  "sort_mode2": SortMode.name,
  "sort_direction1": SortDirection.ascending,
  "sort_direction2": SortDirection.ascending,
  "data_version": -1,
  //Calculation settings
  "term": 3,
  "total_grades": 60.0,
  "rounding_mode": RoundingMode.up,
  "round_to": 1,
  "speaking_weight": 3.0,
  "exam_coefficient": 2.0,
  //Setup
  "is_first_run": true,
  "school_system": "",
  "lux_system": "",
  "year": -1,
  "section": "",
  "variant": "",
  "validated_school_system": "",
  "validated_lux_system": "",
  "validated_year": -1,
  "validated_section": "",
  "validated_variant": "",
  //App settings
  "theme": "system",
  "brightness": "dark",
  "language": "system",
};
