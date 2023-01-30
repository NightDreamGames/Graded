// Dart imports:
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../Calculations/manager.dart';
import '../Calculations/subject.dart';
import '../Calculations/year.dart';
import '../Translations/translations.dart';
import '/UI/Settings/flutter_settings_screens.dart';

final Map<String, dynamic> defaultValues = {
  //System
  "data": "",
  "default_data": "",
  "current_term": 0,
  "sort_mode1": 0,
  "sort_mode2": 0,
  "sort_mode3": 0,
  "data_version": -1,
  //Calculation settings
  "term": 3,
  "total_grades": 60.0,
  "rounding_mode": "rounding_up",
  "round_to": 1,
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

void serialize() {
  setPreference<String?>("data", jsonEncode(Manager.years));
  setPreference<String?>("default_data", jsonEncode(Manager.termTemplate));
}

void deserialize() {
  if (existsPreference("data")) {
    try {
      var termTemplateList = jsonDecode(getPreference<String>("default_data")) as List;
      Manager.termTemplate = termTemplateList.map((templateJson) => Subject.fromJson(templateJson)).toList();

      var data = jsonDecode(getPreference<String>("data")) as List;
      Manager.years = data.map((yearJson) => Year.fromJson(yearJson)).toList();
    } catch (e) {
      Manager.deserializationError = true;
      Manager.clear();
    }
  }
}

Future<void> setPreference<T>(String key, T value) async {
  await Settings.setValue<T>(key, value);
}

T getPreference<T>(String key, {T? defaultValue}) {
  return Settings.getValue<T>(key, defaultValue ?? defaultValues[key]);
}

bool existsPreference(String key) {
  return Settings.containsKey(key)!;
}

List<String> keys = [
  "data",
  "default_data",
  "current_term",
  "sort_mode1",
  "sort_mode2",
  "sort_mode3",
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
  var jsonObject = {};
  for (String s in keys) {
    jsonObject.putIfAbsent(s, () => getPreference(s));
  }

  String json = jsonEncode(jsonObject);

  return json;
}

void exportData() async {
  DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final String formatted = formatter.format(now);

  String fileName = "graded-export-$formatted${Platform.isIOS ? '.json' : ''}";

  final params = SaveFileDialogParams(
    fileName: fileName,
    data: Uint8List.fromList(getExportData().codeUnits),
    mimeTypesFilter: ["application/json"],
  );

  await FlutterFileDialog.saveFile(params: params);
}

void importData(BuildContext context) async {
  String backup = getExportData();
  bool error = false;

  try {
    const params = OpenFileDialogParams(
      allowedUtiTypes: ["public.json"],
      mimeTypesFilter: ["application/json"],
      dialogType: OpenFileDialogType.document,
      sourceType: SourceType.photoLibrary,
    );
    final filePath = await FlutterFileDialog.pickFile(params: params);

    File file = File(filePath!);
    String data = String.fromCharCodes(file.readAsBytesSync());

    restoreData(data);

    deserialize();
  } catch (e) {
    error = true;
    restoreData(backup);
    deserialize();
  }

  Manager.currentTerm = 0;
  Manager.lastTerm = 0;

  // ignore: use_build_context_synchronously
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(error ? Translations.import_error : Translations.import_success),
    ),
  );

  if (!error) {
    Navigator.pop(context);
  }
}

void restoreData(String data) {
  var json = jsonDecode(data);

  for (String s in keys) {
    setPreference(s, json[s]);
  }
}
