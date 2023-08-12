// Dart imports:
import "dart:convert";
import "dart:io";
import "dart:typed_data";

// Package imports:
import "package:device_info_plus/device_info_plus.dart";
import "package:flutter_file_dialog/flutter_file_dialog.dart";
import "package:intl/intl.dart";

// Project imports:
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/year.dart";
import "package:graded/misc/compatibility.dart";
import "package:graded/misc/default_values.dart";
import "package:graded/ui/settings/flutter_settings_screens.dart";

void serialize() {
  setPreference<String?>("data", jsonEncode(Manager.years));
}

void deserialize() {
  if (!existsPreference("data")) return;

  try {
    final data = jsonDecode(getPreference<String>("data")) as List<dynamic>;
    Manager.years = data.map((yearJson) => Year.fromJson(yearJson as Map<String, dynamic>)).toList();
  } catch (e) {
    Manager.deserializationError = true;
    Manager.clearYears();
  }
}

Future<void> setPreference<T>(String key, T value) async {
  await Settings.setValue<T>(key, value);
}

T getPreference<T>(String key, [T? defaultValue]) {
  return Settings.getValue<T>(key, defaultValue ?? defaultValues[key] as T);
}

bool existsPreference(String key) {
  return Settings.containsKey(key)!;
}

List<String> keys = [
  "data_version",
  "data",
  "current_year",
  "current_term",
  "sort_mode1",
  "sort_mode2",
  "sort_direction1",
  "sort_direction2",
  "term",
  "total_grades",
  "rounding_mode",
  "round_to",
  "validated_school_system",
  "validated_lux_system",
  "validated_year",
  "validated_section",
  "validated_variant",
];

String getExportData() {
  final jsonObject = {};
  for (final String s in keys) {
    jsonObject.putIfAbsent(s, () => getPreference(s));
  }

  String json = jsonEncode(jsonObject);

  return json;
}

Future<void> exportData() async {
  DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat("yyyy-MM-dd");
  final String formatted = formatter.format(now);

  String extension = ".json";

  if (Platform.isAndroid) {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    if (androidInfo.version.sdkInt >= 29) {
      extension = "";
    }
  }

  String fileName = "graded-export-$formatted$extension";

  final params = SaveFileDialogParams(
    fileName: fileName,
    data: Uint8List.fromList(getExportData().codeUnits),
    mimeTypesFilter: ["application/json"],
  );

  await FlutterFileDialog.saveFile(params: params);
}

Future<bool> importData() async {
  String backup = getExportData();
  bool error = false;

  try {
    const params = OpenFileDialogParams(
      allowedUtiTypes: ["public.json"],
      mimeTypesFilter: ["application/json"],
    );
    final filePath = await FlutterFileDialog.pickFile(params: params);

    File file = File(filePath!);
    String data = String.fromCharCodes(file.readAsBytesSync());

    restoreData(data);
  } catch (e) {
    error = true;
    restoreData(backup);
  }
  Compatibility.upgradeDataVersion(imported: true);

  Manager.calculate();
  Manager.currentTerm = 0;

  return !error;
}

void restoreData(String data) {
  final json = jsonDecode(data) as Map<String, dynamic>;

  for (final String key in json.keys) {
    setPreference(key, json[key]);
  }
}
