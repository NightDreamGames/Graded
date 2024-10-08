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
import "package:graded/main.dart";
import "package:graded/misc/compatibility.dart";
import "package:graded/misc/default_values.dart";
import "package:graded/misc/setup_manager.dart";
import "package:graded/ui/settings/flutter_settings_screens.dart";
import "package:graded/ui/utilities/misc_utilities.dart";

void serialize() {
  setPreference<String?>("data", jsonEncode(Manager.years));
}

void deserialize({List<dynamic>? data}) {
  if (data == null && !hasPreference("data")) return;

  try {
    data ??= jsonDecode(getPreference<String>("data")) as List<dynamic>;
    Manager.years = data.map((yearJson) => Year.fromJson(yearJson as Map<String, dynamic>)..ensureTermCount()).toList();
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

bool hasPreference(String key) {
  return Settings.containsKey(key)!;
}

List<String> keys = [
  "dataVersion",
  "data",
  "currentYear",
  "currentTerm",
  "sortMode1",
  "sortMode2",
  "sortDirection1",
  "sortDirection2",
  "leadingZero",
  "theme",
  "dynamicColor",
  "customColor",
  "amoled",
  "font",
  "hapticFeedback",
  "language",
];

String getExportData() {
  final jsonObject = {};
  for (final String s in keys) {
    jsonObject.putIfAbsent(s, () => getPreference(s));
  }

  final String json = jsonEncode(jsonObject);

  return json;
}

Future<void> exportData() async {
  if (isWeb) throw UnimplementedError("Exporting data is not supported on the web");

  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat("yyyy-MM-dd");
  final String formatted = formatter.format(now);

  String extension = ".json";

  if (Platform.isAndroid) {
    final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;

    if (androidInfo.version.sdkInt >= 29) {
      extension = "";
    }
  }

  final String fileName = "graded-export-$formatted$extension";

  final params = SaveFileDialogParams(
    fileName: fileName,
    data: Uint8List.fromList(utf8.encode(getExportData())),
    mimeTypesFilter: ["application/json"],
  );

  await FlutterFileDialog.saveFile(params: params);
}

Future<bool> importData() async {
  if (isWeb) throw UnimplementedError("Importing data is not supported on the web");

  final String backup = getExportData();
  bool error = false;
  final bool inSetup = SetupManager.inSetup;

  try {
    const params = OpenFileDialogParams(
      allowedUtiTypes: ["public.json"],
      mimeTypesFilter: ["application/json"],
    );
    final filePath = await FlutterFileDialog.pickFile(params: params);

    final File file = File(filePath!);
    String data;
    try {
      data = await utf8.decodeStream(file.openRead());
    } catch (e) {
      data = String.fromCharCodes(file.readAsBytesSync());
    }

    restoreData(data);
    SetupManager.inSetup = false;

    Compatibility.upgradeDataVersion(imported: true);

    Manager.calculate();
    Manager.currentTerm = 0;
  } catch (e) {
    error = true;
    restoreData(backup);

    SetupManager.inSetup = inSetup;
  }

  Compatibility.upgradeDataVersion(imported: true);
  Manager.calculate();

  return !error;
}

void restoreData(String data) {
  final json = jsonDecode(data) as Map<String, dynamic>;

  for (final String key in json.keys) {
    setPreference(key, json[key]);
  }
}
