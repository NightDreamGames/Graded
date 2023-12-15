// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class TranslationsClass {
  TranslationsClass();

  static TranslationsClass? _current;

  static TranslationsClass get current {
    assert(_current != null,
        'No instance of TranslationsClass was loaded. Try to initialize the TranslationsClass delegate before accessing TranslationsClass.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<TranslationsClass> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = TranslationsClass();
      TranslationsClass._current = instance;

      return instance;
    });
  }

  static TranslationsClass of(BuildContext context) {
    final instance = TranslationsClass.maybeOf(context);
    assert(instance != null,
        'No instance of TranslationsClass present in the widget tree. Did you add TranslationsClass.delegate in localizationsDelegates?');
    return instance!;
  }

  static TranslationsClass? maybeOf(BuildContext context) {
    return Localizations.of<TranslationsClass>(context, TranslationsClass);
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `Add group`
  String get add_group {
    return Intl.message(
      'Add group',
      name: 'add_group',
      desc: '',
      args: [],
    );
  }

  /// `Add subject`
  String get add_subjectOne {
    return Intl.message(
      'Add subject',
      name: 'add_subjectOne',
      desc: '',
      args: [],
    );
  }

  /// `Add subjects`
  String get add_subjectOther {
    return Intl.message(
      'Add subjects',
      name: 'add_subjectOther',
      desc: '',
      args: [],
    );
  }

  /// `Add test`
  String get add_test {
    return Intl.message(
      'Add test',
      name: 'add_test',
      desc: '',
      args: [],
    );
  }

  /// `Add year`
  String get add_year {
    return Intl.message(
      'Add year',
      name: 'add_year',
      desc: '',
      args: [],
    );
  }

  /// `Amoled mode`
  String get amoled_mode {
    return Intl.message(
      'Amoled mode',
      name: 'amoled_mode',
      desc: '',
      args: [],
    );
  }

  /// `Graded`
  String get app_name {
    return Intl.message(
      'Graded',
      name: 'app_name',
      desc: 'Do not translate',
      args: [],
    );
  }

  /// `App version`
  String get app_version {
    return Intl.message(
      'App version',
      name: 'app_version',
      desc: '',
      args: [],
    );
  }

  /// `Appearance`
  String get appearance {
    return Intl.message(
      'Appearance',
      name: 'appearance',
      desc: '',
      args: [],
    );
  }

  /// `Average`
  String get average {
    return Intl.message(
      'Average',
      name: 'average',
      desc: '',
      args: [],
    );
  }

  /// `Basic`
  String get basic {
    return Intl.message(
      'Basic',
      name: 'basic',
      desc: '',
      args: [],
    );
  }

  /// `Bonus:`
  String get bonus {
    return Intl.message(
      'Bonus:',
      name: 'bonus',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `中文`
  String get chinese {
    return Intl.message(
      '中文',
      name: 'chinese',
      desc: '',
      args: [],
    );
  }

  /// `Class`
  String get class_ {
    return Intl.message(
      'Class',
      name: 'class_',
      desc: '',
      args: [],
    );
  }

  /// `Weight`
  String get coefficientOne {
    return Intl.message(
      'Weight',
      name: 'coefficientOne',
      desc: '',
      args: [],
    );
  }

  /// `Weights`
  String get coefficientOther {
    return Intl.message(
      'Weights',
      name: 'coefficientOther',
      desc: '',
      args: [],
    );
  }

  /// `Color`
  String get colorOne {
    return Intl.message(
      'Color',
      name: 'colorOne',
      desc: '',
      args: [],
    );
  }

  /// `Colors`
  String get colorOther {
    return Intl.message(
      'Colors',
      name: 'colorOther',
      desc: '',
      args: [],
    );
  }

  /// `Coming soon`
  String get coming_soon {
    return Intl.message(
      'Coming soon',
      name: 'coming_soon',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Contact me`
  String get contact_me {
    return Intl.message(
      'Contact me',
      name: 'contact_me',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get copy {
    return Intl.message(
      'Copy',
      name: 'copy',
      desc: '',
      args: [],
    );
  }

  /// `Copy subjects from current year?`
  String get copy_subjects_prompt {
    return Intl.message(
      'Copy subjects from current year?',
      name: 'copy_subjects_prompt',
      desc: '',
      args: [],
    );
  }

  /// `Credits`
  String get credits {
    return Intl.message(
      'Credits',
      name: 'credits',
      desc: '',
      args: [],
    );
  }

  /// `Developer - Damien Pirotte\nVisual identity - Ellia Walrave\nTesting - Louis Colbus`
  String get credits_description {
    return Intl.message(
      'Developer - Damien Pirotte\nVisual identity - Ellia Walrave\nTesting - Louis Colbus',
      name: 'credits_description',
      desc: 'Do not translate names, keep formatting and line breaks',
      args: [],
    );
  }

  /// `Custom`
  String get custom {
    return Intl.message(
      'Custom',
      name: 'custom',
      desc: '',
      args: [],
    );
  }

  /// `Custom color`
  String get custom_color {
    return Intl.message(
      'Custom color',
      name: 'custom_color',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get date {
    return Intl.message(
      'Date',
      name: 'date',
      desc: '',
      args: [],
    );
  }

  /// `Decrease`
  String get decrease {
    return Intl.message(
      'Decrease',
      name: 'decrease',
      desc: '',
      args: [],
    );
  }

  /// `Default`
  String get default_ {
    return Intl.message(
      'Default',
      name: 'default_',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message(
      'Done',
      name: 'done',
      desc: '',
      args: [],
    );
  }

  /// `Down`
  String get down {
    return Intl.message(
      'Down',
      name: 'down',
      desc: '',
      args: [],
    );
  }

  /// `Nederlands`
  String get dutch {
    return Intl.message(
      'Nederlands',
      name: 'dutch',
      desc: 'Do not translate',
      args: [],
    );
  }

  /// `Dynamic color`
  String get dynamic_color {
    return Intl.message(
      'Dynamic color',
      name: 'dynamic_color',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Edit color scheme`
  String get edit_color_scheme {
    return Intl.message(
      'Edit color scheme',
      name: 'edit_color_scheme',
      desc: '',
      args: [],
    );
  }

  /// `Edit primary color`
  String get edit_primary_color {
    return Intl.message(
      'Edit primary color',
      name: 'edit_primary_color',
      desc: '',
      args: [],
    );
  }

  /// `Edit subject`
  String get edit_subjectOne {
    return Intl.message(
      'Edit subject',
      name: 'edit_subjectOne',
      desc: '',
      args: [],
    );
  }

  /// `Edit subjects`
  String get edit_subjectOther {
    return Intl.message(
      'Edit subjects',
      name: 'edit_subjectOther',
      desc: '',
      args: [],
    );
  }

  /// `Tap here to edit your subjects`
  String get edit_subjects_description {
    return Intl.message(
      'Tap here to edit your subjects',
      name: 'edit_subjects_description',
      desc: '',
      args: [],
    );
  }

  /// `Edit test`
  String get edit_test {
    return Intl.message(
      'Edit test',
      name: 'edit_test',
      desc: '',
      args: [],
    );
  }

  /// `Edit year`
  String get edit_year {
    return Intl.message(
      'Edit year',
      name: 'edit_year',
      desc: '',
      args: [],
    );
  }

  /// `contact@nightdreamgames.com`
  String get email {
    return Intl.message(
      'contact@nightdreamgames.com',
      name: 'email',
      desc: 'Do not translate',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message(
      'English',
      name: 'english',
      desc: 'Do not translate',
      args: [],
    );
  }

  /// `Enter a unique name`
  String get enter_unique {
    return Intl.message(
      'Enter a unique name',
      name: 'enter_unique',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Exam`
  String get exam {
    return Intl.message(
      'Exam',
      name: 'exam',
      desc: '',
      args: [],
    );
  }

  /// `Exams`
  String get exams {
    return Intl.message(
      'Exams',
      name: 'exams',
      desc: '',
      args: [],
    );
  }

  /// `Export`
  String get export_ {
    return Intl.message(
      'Export',
      name: 'export_',
      desc: '',
      args: [],
    );
  }

  /// `Export the current configuration and saved data`
  String get export_description {
    return Intl.message(
      'Export the current configuration and saved data',
      name: 'export_description',
      desc: '',
      args: [],
    );
  }

  /// `Follow NightDream Games`
  String get follow_nightdream_games {
    return Intl.message(
      'Follow NightDream Games',
      name: 'follow_nightdream_games',
      desc: '',
      args: [],
    );
  }

  /// `Font`
  String get font {
    return Intl.message(
      'Font',
      name: 'font',
      desc: '',
      args: [],
    );
  }

  /// `Français`
  String get french {
    return Intl.message(
      'Français',
      name: 'french',
      desc: 'Do not translate',
      args: [],
    );
  }

  /// `General`
  String get general {
    return Intl.message(
      'General',
      name: 'general',
      desc: '',
      args: [],
    );
  }

  /// `Deutsch`
  String get german {
    return Intl.message(
      'Deutsch',
      name: 'german',
      desc: 'Do not translate',
      args: [],
    );
  }

  /// `Grade`
  String get gradeOne {
    return Intl.message(
      'Grade',
      name: 'gradeOne',
      desc: '',
      args: [],
    );
  }

  /// `Grades`
  String get gradeOther {
    return Intl.message(
      'Grades',
      name: 'gradeOther',
      desc: '',
      args: [],
    );
  }

  /// `Group`
  String get group {
    return Intl.message(
      'Group',
      name: 'group',
      desc: '',
      args: [],
    );
  }

  /// `Half down`
  String get half_down {
    return Intl.message(
      'Half down',
      name: 'half_down',
      desc: 'Rounding half down',
      args: [],
    );
  }

  /// `Half up`
  String get half_up {
    return Intl.message(
      'Half up',
      name: 'half_up',
      desc: 'Rounding half up',
      args: [],
    );
  }

  /// `Help translate`
  String get help_translate {
    return Intl.message(
      'Help translate',
      name: 'help_translate',
      desc: '',
      args: [],
    );
  }

  /// `Correct translation mistakes or localise project to your language`
  String get help_translate_description {
    return Intl.message(
      'Correct translation mistakes or localise project to your language',
      name: 'help_translate_description',
      desc: '',
      args: [],
    );
  }

  /// `Import`
  String get import_ {
    return Intl.message(
      'Import',
      name: 'import_',
      desc: '',
      args: [],
    );
  }

  /// `Import a previously exported backup file`
  String get import_description {
    return Intl.message(
      'Import a previously exported backup file',
      name: 'import_description',
      desc: '',
      args: [],
    );
  }

  /// `There was an error importing your backup.`
  String get import_error {
    return Intl.message(
      'There was an error importing your backup.',
      name: 'import_error',
      desc: '',
      args: [],
    );
  }

  /// `Backup imported successfully.`
  String get import_success {
    return Intl.message(
      'Backup imported successfully.',
      name: 'import_success',
      desc: '',
      args: [],
    );
  }

  /// `Increase`
  String get increase {
    return Intl.message(
      'Increase',
      name: 'increase',
      desc: '',
      args: [],
    );
  }

  /// `Invalid`
  String get invalid {
    return Intl.message(
      'Invalid',
      name: 'invalid',
      desc: '',
      args: [],
    );
  }

  /// `Issue tracker`
  String get issue_tracker {
    return Intl.message(
      'Issue tracker',
      name: 'issue_tracker',
      desc: '',
      args: [],
    );
  }

  /// `Send bug reports and feature requests here`
  String get issue_tracker_description {
    return Intl.message(
      'Send bug reports and feature requests here',
      name: 'issue_tracker_description',
      desc: '',
      args: [],
    );
  }

  /// `Italiano`
  String get italian {
    return Intl.message(
      'Italiano',
      name: 'italian',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `en`
  String get language_code {
    return Intl.message(
      'en',
      name: 'language_code',
      desc: 'ISO 639-1 code of the language, 2 letters',
      args: [],
    );
  }

  /// `Licenses`
  String get licenses {
    return Intl.message(
      'Licenses',
      name: 'licenses',
      desc: '',
      args: [],
    );
  }

  /// `Luxembourgish school system`
  String get lux_system {
    return Intl.message(
      'Luxembourgish school system',
      name: 'lux_system',
      desc: '',
      args: [],
    );
  }

  /// `Classic`
  String get lux_system_classic {
    return Intl.message(
      'Classic',
      name: 'lux_system_classic',
      desc: '',
      args: [],
    );
  }

  /// `General`
  String get lux_system_general {
    return Intl.message(
      'General',
      name: 'lux_system_general',
      desc: '',
      args: [],
    );
  }

  /// `Lëtzebuergesch`
  String get luxembourgish {
    return Intl.message(
      'Lëtzebuergesch',
      name: 'luxembourgish',
      desc: 'Do not translate',
      args: [],
    );
  }

  /// `Manage years`
  String get manage_years {
    return Intl.message(
      'Manage years',
      name: 'manage_years',
      desc: '',
      args: [],
    );
  }

  /// `Add, edit and delete your saved years`
  String get manage_years_description {
    return Intl.message(
      'Add, edit and delete your saved years',
      name: 'manage_years_description',
      desc: '',
      args: [],
    );
  }

  /// `Material 3 shades`
  String get material_3_shades {
    return Intl.message(
      'Material 3 shades',
      name: 'material_3_shades',
      desc: '',
      args: [],
    );
  }

  /// `Maximum`
  String get maximum {
    return Intl.message(
      'Maximum',
      name: 'maximum',
      desc: '',
      args: [],
    );
  }

  /// `More options`
  String get more_options {
    return Intl.message(
      'More options',
      name: 'more_options',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  /// `NightDream Games`
  String get nightdream_games {
    return Intl.message(
      'NightDream Games',
      name: 'nightdream_games',
      desc: 'Do not translate',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `No color palette detected`
  String get no_dynamic_color {
    return Intl.message(
      'No color palette detected',
      name: 'no_dynamic_color',
      desc: '',
      args: [],
    );
  }

  /// `No grades`
  String get no_grades {
    return Intl.message(
      'No grades',
      name: 'no_grades',
      desc: '',
      args: [],
    );
  }

  /// `No items`
  String get no_items {
    return Intl.message(
      'No items',
      name: 'no_items',
      desc: '',
      args: [],
    );
  }

  /// `No subjects`
  String get no_subjects {
    return Intl.message(
      'No subjects',
      name: 'no_subjects',
      desc: '',
      args: [],
    );
  }

  /// `Not set`
  String get not_set {
    return Intl.message(
      'Not set',
      name: 'not_set',
      desc: '',
      args: [],
    );
  }

  /// `Note:`
  String get note {
    return Intl.message(
      'Note:',
      name: 'note',
      desc: '',
      args: [],
    );
  }

  /// `You can always edit your subjects and other options in the settings later`
  String get note_description {
    return Intl.message(
      'You can always edit your subjects and other options in the settings later',
      name: 'note_description',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Open`
  String get open {
    return Intl.message(
      'Open',
      name: 'open',
      desc: '',
      args: [],
    );
  }

  /// `Other school system`
  String get other_school_system {
    return Intl.message(
      'Other school system',
      name: 'other_school_system',
      desc: '',
      args: [],
    );
  }

  /// `Preset`
  String get preset {
    return Intl.message(
      'Preset',
      name: 'preset',
      desc: '',
      args: [],
    );
  }

  /// `Previous`
  String get previous {
    return Intl.message(
      'Previous',
      name: 'previous',
      desc: '',
      args: [],
    );
  }

  /// `Quarter`
  String get quarterOne {
    return Intl.message(
      'Quarter',
      name: 'quarterOne',
      desc: '',
      args: [],
    );
  }

  /// `Quarters`
  String get quarterOther {
    return Intl.message(
      'Quarters',
      name: 'quarterOther',
      desc: '',
      args: [],
    );
  }

  /// `Rating system`
  String get rating_system {
    return Intl.message(
      'Rating system',
      name: 'rating_system',
      desc: '',
      args: [],
    );
  }

  /// `Reset this year's grades`
  String get reset {
    return Intl.message(
      'Reset this year\'s grades',
      name: 'reset',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete all the saved grades from this year?`
  String get reset_confirm {
    return Intl.message(
      'Are you sure you want to delete all the saved grades from this year?',
      name: 'reset_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Result`
  String get result {
    return Intl.message(
      'Result',
      name: 'result',
      desc: '',
      args: [],
    );
  }

  /// `Round to`
  String get round_to {
    return Intl.message(
      'Round to',
      name: 'round_to',
      desc: '',
      args: [],
    );
  }

  /// `Rounding mode`
  String get rounding_mode {
    return Intl.message(
      'Rounding mode',
      name: 'rounding_mode',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `School system`
  String get school_system {
    return Intl.message(
      'School system',
      name: 'school_system',
      desc: '',
      args: [],
    );
  }

  /// `School term`
  String get school_termOne {
    return Intl.message(
      'School term',
      name: 'school_termOne',
      desc: '',
      args: [],
    );
  }

  /// `School terms`
  String get school_termOther {
    return Intl.message(
      'School terms',
      name: 'school_termOther',
      desc: '',
      args: [],
    );
  }

  /// `Section`
  String get section {
    return Intl.message(
      'Section',
      name: 'section',
      desc: '',
      args: [],
    );
  }

  /// `A - Languages`
  String get section_classic_a {
    return Intl.message(
      'A - Languages',
      name: 'section_classic_a',
      desc: '',
      args: [],
    );
  }

  /// `B - Mathematics`
  String get section_classic_b {
    return Intl.message(
      'B - Mathematics',
      name: 'section_classic_b',
      desc: '',
      args: [],
    );
  }

  /// `C - Natural sciences`
  String get section_classic_c {
    return Intl.message(
      'C - Natural sciences',
      name: 'section_classic_c',
      desc: '',
      args: [],
    );
  }

  /// `D - Economics`
  String get section_classic_d {
    return Intl.message(
      'D - Economics',
      name: 'section_classic_d',
      desc: '',
      args: [],
    );
  }

  /// `E - Art`
  String get section_classic_e {
    return Intl.message(
      'E - Art',
      name: 'section_classic_e',
      desc: '',
      args: [],
    );
  }

  /// `F - Music`
  String get section_classic_f {
    return Intl.message(
      'F - Music',
      name: 'section_classic_f',
      desc: '',
      args: [],
    );
  }

  /// `G - Human & social sciences`
  String get section_classic_g {
    return Intl.message(
      'G - Human & social sciences',
      name: 'section_classic_g',
      desc: '',
      args: [],
    );
  }

  /// `I - Informatics & Communication`
  String get section_classic_i {
    return Intl.message(
      'I - Informatics & Communication',
      name: 'section_classic_i',
      desc: '',
      args: [],
    );
  }

  /// `A3D - Architecture, design & sustainable development`
  String get section_general_a3d {
    return Intl.message(
      'A3D - Architecture, design & sustainable development',
      name: 'section_general_a3d',
      desc: '',
      args: [],
    );
  }

  /// `ACV - Arts & visual communication`
  String get section_general_acv {
    return Intl.message(
      'ACV - Arts & visual communication',
      name: 'section_general_acv',
      desc: '',
      args: [],
    );
  }

  /// `CC - Communication & organisation`
  String get section_general_cc {
    return Intl.message(
      'CC - Communication & organisation',
      name: 'section_general_cc',
      desc: '',
      args: [],
    );
  }

  /// `CF - Finance`
  String get section_general_cf {
    return Intl.message(
      'CF - Finance',
      name: 'section_general_cf',
      desc: '',
      args: [],
    );
  }

  /// `CG - Management`
  String get section_general_cg {
    return Intl.message(
      'CG - Management',
      name: 'section_general_cg',
      desc: '',
      args: [],
    );
  }

  /// `CM - Administrative & commercial`
  String get section_general_cm {
    return Intl.message(
      'CM - Administrative & commercial',
      name: 'section_general_cm',
      desc: '',
      args: [],
    );
  }

  /// `ED - Educator training`
  String get section_general_ed {
    return Intl.message(
      'ED - Educator training',
      name: 'section_general_ed',
      desc: '',
      args: [],
    );
  }

  /// `GH - Hospitality management`
  String get section_general_gh {
    return Intl.message(
      'GH - Hospitality management',
      name: 'section_general_gh',
      desc: '',
      args: [],
    );
  }

  /// `IG - Engineering`
  String get section_general_ig {
    return Intl.message(
      'IG - Engineering',
      name: 'section_general_ig',
      desc: '',
      args: [],
    );
  }

  /// `IN - Informatics`
  String get section_general_in {
    return Intl.message(
      'IN - Informatics',
      name: 'section_general_in',
      desc: '',
      args: [],
    );
  }

  /// `MM - Marketing, media & communication`
  String get section_general_mm {
    return Intl.message(
      'MM - Marketing, media & communication',
      name: 'section_general_mm',
      desc: '',
      args: [],
    );
  }

  /// `PS - Health & social professions`
  String get section_general_ps {
    return Intl.message(
      'PS - Health & social professions',
      name: 'section_general_ps',
      desc: '',
      args: [],
    );
  }

  /// `SE - Environmental sciences`
  String get section_general_se {
    return Intl.message(
      'SE - Environmental sciences',
      name: 'section_general_se',
      desc: '',
      args: [],
    );
  }

  /// `SH - Health sciences`
  String get section_general_sh {
    return Intl.message(
      'SH - Health sciences',
      name: 'section_general_sh',
      desc: '',
      args: [],
    );
  }

  /// `SI - Nurse training`
  String get section_general_si {
    return Intl.message(
      'SI - Nurse training',
      name: 'section_general_si',
      desc: '',
      args: [],
    );
  }

  /// `SN - Natural sciences`
  String get section_general_sn {
    return Intl.message(
      'SN - Natural sciences',
      name: 'section_general_sn',
      desc: '',
      args: [],
    );
  }

  /// `SO - Social sciences`
  String get section_general_so {
    return Intl.message(
      'SO - Social sciences',
      name: 'section_general_so',
      desc: '',
      args: [],
    );
  }

  /// `Select`
  String get select {
    return Intl.message(
      'Select',
      name: 'select',
      desc: '',
      args: [],
    );
  }

  /// `Select a color`
  String get select_color {
    return Intl.message(
      'Select a color',
      name: 'select_color',
      desc: '',
      args: [],
    );
  }

  /// `Select date`
  String get select_date {
    return Intl.message(
      'Select date',
      name: 'select_date',
      desc: '',
      args: [],
    );
  }

  /// `Select school term`
  String get select_school_term {
    return Intl.message(
      'Select school term',
      name: 'select_school_term',
      desc: '',
      args: [],
    );
  }

  /// `Semester`
  String get semesterOne {
    return Intl.message(
      'Semester',
      name: 'semesterOne',
      desc: '',
      args: [],
    );
  }

  /// `Semesters`
  String get semesterOther {
    return Intl.message(
      'Semesters',
      name: 'semesterOther',
      desc: '',
      args: [],
    );
  }

  /// `Set as sub-subject`
  String get set_sub_subject {
    return Intl.message(
      'Set as sub-subject',
      name: 'set_sub_subject',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Setup`
  String get setup {
    return Intl.message(
      'Setup',
      name: 'setup',
      desc: '',
      args: [],
    );
  }

  /// `Show leading zero`
  String get show_leading_zero {
    return Intl.message(
      'Show leading zero',
      name: 'show_leading_zero',
      desc: '',
      args: [],
    );
  }

  /// `Show a zero in front of single digit numbers`
  String get show_leading_zero_description {
    return Intl.message(
      'Show a zero in front of single digit numbers',
      name: 'show_leading_zero_description',
      desc: '',
      args: [],
    );
  }

  /// `Drag to change subject order`
  String get showcase_drag_subject {
    return Intl.message(
      'Drag to change subject order',
      name: 'showcase_drag_subject',
      desc: '',
      args: [],
    );
  }

  /// `Tap here to show the precise average`
  String get showcase_precise_average {
    return Intl.message(
      'Tap here to show the precise average',
      name: 'showcase_precise_average',
      desc: '',
      args: [],
    );
  }

  /// `Tap here to make this subject a sub-subject and the subject above a subject group`
  String get showcase_tap_subject {
    return Intl.message(
      'Tap here to make this subject a sub-subject and the subject above a subject group',
      name: 'showcase_tap_subject',
      desc: '',
      args: [],
    );
  }

  /// `Sort by`
  String get sort_by {
    return Intl.message(
      'Sort by',
      name: 'sort_by',
      desc: '',
      args: [],
    );
  }

  /// `Source code`
  String get source_code {
    return Intl.message(
      'Source code',
      name: 'source_code',
      desc: '',
      args: [],
    );
  }

  /// `If you've got any change in mind or want to report an issue, head over to the Graded GitHub repo.`
  String get source_code_description {
    return Intl.message(
      'If you\'ve got any change in mind or want to report an issue, head over to the Graded GitHub repo.',
      name: 'source_code_description',
      desc: '',
      args: [],
    );
  }

  /// `Español`
  String get spanish {
    return Intl.message(
      'Español',
      name: 'spanish',
      desc: 'Do not translate',
      args: [],
    );
  }

  /// `Speaking`
  String get speaking {
    return Intl.message(
      'Speaking',
      name: 'speaking',
      desc:
          'Attention: "Speaking" as in "oral exam", not the verb "to speak". Make sure to use the appropriate translation.',
      args: [],
    );
  }

  /// `Speaking weight`
  String get speaking_weight {
    return Intl.message(
      'Speaking weight',
      name: 'speaking_weight',
      desc:
          'Attention: "Speaking" as in "oral exam", not the verb "to speak". Make sure to use the appropriate translation.',
      args: [],
    );
  }

  /// `There was an error loading your saved data, so it has been deleted.`
  String get storage_error {
    return Intl.message(
      'There was an error loading your saved data, so it has been deleted.',
      name: 'storage_error',
      desc: '',
      args: [],
    );
  }

  /// `Subject`
  String get subjectOne {
    return Intl.message(
      'Subject',
      name: 'subjectOne',
      desc: '',
      args: [],
    );
  }

  /// `Subjects`
  String get subjectOther {
    return Intl.message(
      'Subjects',
      name: 'subjectOther',
      desc: '',
      args: [],
    );
  }

  /// `System`
  String get system {
    return Intl.message(
      'System',
      name: 'system',
      desc: '',
      args: [],
    );
  }

  /// `Test`
  String get testOne {
    return Intl.message(
      'Test',
      name: 'testOne',
      desc: '',
      args: [],
    );
  }

  /// `Tests`
  String get testOther {
    return Intl.message(
      'Tests',
      name: 'testOther',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message(
      'Theme',
      name: 'theme',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get theme_dark {
    return Intl.message(
      'Dark',
      name: 'theme_dark',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get theme_light {
    return Intl.message(
      'Light',
      name: 'theme_light',
      desc: '',
      args: [],
    );
  }

  /// `To 100-th`
  String get to_100th {
    return Intl.message(
      'To 100-th',
      name: 'to_100th',
      desc: '',
      args: [],
    );
  }

  /// `To 10-th`
  String get to_10th {
    return Intl.message(
      'To 10-th',
      name: 'to_10th',
      desc: '',
      args: [],
    );
  }

  /// `To integer`
  String get to_integer {
    return Intl.message(
      'To integer',
      name: 'to_integer',
      desc: '',
      args: [],
    );
  }

  /// `Trimester`
  String get trimesterOne {
    return Intl.message(
      'Trimester',
      name: 'trimesterOne',
      desc: '',
      args: [],
    );
  }

  /// `Trimesters`
  String get trimesterOther {
    return Intl.message(
      'Trimesters',
      name: 'trimesterOther',
      desc: '',
      args: [],
    );
  }

  /// `Up`
  String get up {
    return Intl.message(
      'Up',
      name: 'up',
      desc: '',
      args: [],
    );
  }

  /// `Variant`
  String get variant {
    return Intl.message(
      'Variant',
      name: 'variant',
      desc: '',
      args: [],
    );
  }

  /// `L - Latin`
  String get variant_classic_l {
    return Intl.message(
      'L - Latin',
      name: 'variant_classic_l',
      desc: '',
      args: [],
    );
  }

  /// `ZH - Chinese`
  String get variant_classic_zh {
    return Intl.message(
      'ZH - Chinese',
      name: 'variant_classic_zh',
      desc: '',
      args: [],
    );
  }

  /// `A - Continuation of german`
  String get variant_general_a {
    return Intl.message(
      'A - Continuation of german',
      name: 'variant_general_a',
      desc: '',
      args: [],
    );
  }

  /// `AD - Adaptation class`
  String get variant_general_ad {
    return Intl.message(
      'AD - Adaptation class',
      name: 'variant_general_ad',
      desc: '',
      args: [],
    );
  }

  /// `ADF - French adaptation class`
  String get variant_general_adf {
    return Intl.message(
      'ADF - French adaptation class',
      name: 'variant_general_adf',
      desc: '',
      args: [],
    );
  }

  /// `F - Beginning of german`
  String get variant_general_f {
    return Intl.message(
      'F - Beginning of german',
      name: 'variant_general_f',
      desc: '',
      args: [],
    );
  }

  /// `FR - Francophone regime`
  String get variant_general_fr {
    return Intl.message(
      'FR - Francophone regime',
      name: 'variant_general_fr',
      desc: '',
      args: [],
    );
  }

  /// `IA - Learning german`
  String get variant_general_ia {
    return Intl.message(
      'IA - Learning german',
      name: 'variant_general_ia',
      desc: '',
      args: [],
    );
  }

  /// `IF - Learning french`
  String get variant_general_if {
    return Intl.message(
      'IF - Learning french',
      name: 'variant_general_if',
      desc: '',
      args: [],
    );
  }

  /// `P - Preparation route`
  String get variant_general_p {
    return Intl.message(
      'P - Preparation route',
      name: 'variant_general_p',
      desc: '',
      args: [],
    );
  }

  /// `PF - French preparation way`
  String get variant_general_pf {
    return Intl.message(
      'PF - French preparation way',
      name: 'variant_general_pf',
      desc: '',
      args: [],
    );
  }

  /// `Year`
  String get yearOne {
    return Intl.message(
      'Year',
      name: 'yearOne',
      desc: '',
      args: [],
    );
  }

  /// `Years`
  String get yearOther {
    return Intl.message(
      'Years',
      name: 'yearOther',
      desc: '',
      args: [],
    );
  }

  /// `Year overview`
  String get year_overview {
    return Intl.message(
      'Year overview',
      name: 'year_overview',
      desc: '',
      args: [],
    );
  }

  /// `Yearly average`
  String get yearly_average {
    return Intl.message(
      'Yearly average',
      name: 'yearly_average',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<TranslationsClass> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'lb'),
      Locale.fromSubtags(languageCode: 'nl'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<TranslationsClass> load(Locale locale) =>
      TranslationsClass.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
