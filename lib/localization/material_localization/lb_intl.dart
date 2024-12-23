import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_custom.dart' as date_symbol_data_custom;
import 'package:intl/date_symbols.dart' as intl;
import 'package:intl/intl.dart' as intl;

/// A custom set of date patterns for the `lb` locale.
///
/// These are not accurate and are just a clone of the date patterns for the
/// `no` locale to demonstrate how one would write and use custom date patterns.
const lbLocaleDatePatterns = {
  'd': 'd', // DAY
  'E': 'ccc', // ABBR_WEEKDAY
  'EEEE': 'cccc', // WEEKDAY
  'LLL': 'LLL', // ABBR_STANDALONE_MONTH
  'LLLL': 'LLLL', // STANDALONE_MONTH
  'M': 'L', // NUM_MONTH
  'Md': 'd.M.', // NUM_MONTH_DAY
  'MEd': 'EEE, d.M.', // NUM_MONTH_WEEKDAY_DAY
  'MMM': 'LLL', // ABBR_MONTH
  'MMMd': 'd. MMM', // ABBR_MONTH_DAY
  'MMMEd': 'EEE, d. MMM', // ABBR_MONTH_WEEKDAY_DAY
  'MMMM': 'LLLL', // MONTH
  'MMMMd': 'd. MMMM', // MONTH_DAY
  'MMMMEEEEd': 'EEEE, d. MMMM', // MONTH_WEEKDAY_DAY
  'QQQ': 'QQQ', // ABBR_QUARTER
  'QQQQ': 'QQQQ', // QUARTER
  'y': 'y', // YEAR
  'yM': 'MM/y', // YEAR_NUM_MONTH
  'yMd': 'd.M.y', // YEAR_NUM_MONTH_DAY
  'yMEd': 'EEE, d.M.y', // YEAR_NUM_MONTH_WEEKDAY_DAY
  'yMMM': 'MMM y', // YEAR_ABBR_MONTH
  'yMMMd': 'd. MMM y', // YEAR_ABBR_MONTH_DAY
  'yMMMEd': 'EEE, d. MMM y', // YEAR_ABBR_MONTH_WEEKDAY_DAY
  'yMMMM': 'MMMM y', // YEAR_MONTH
  'yMMMMd': 'd. MMMM y', // YEAR_MONTH_DAY
  'yMMMMEEEEd': 'EEEE, d. MMMM y', // YEAR_MONTH_WEEKDAY_DAY
  'yQQQ': 'QQQ y', // YEAR_ABBR_QUARTER
  'yQQQQ': 'QQQQ y', // YEAR_QUARTER
  'H': 'HH \'Uhr\'', // HOUR24
  'Hm': 'HH:mm', // HOUR24_MINUTE
  'Hms': 'HH:mm:ss', // HOUR24_MINUTE_SECOND
  'j': 'HH \'Uhr\'', // HOUR
  'jm': 'HH:mm', // HOUR_MINUTE
  'jms': 'HH:mm:ss', // HOUR_MINUTE_SECOND
  'jmv': 'HH:mm v', // HOUR_MINUTE_GENERIC_TZ
  'jmz': 'HH:mm z', // HOUR_MINUTETZ
  'jz': 'HH \'Uhr\' z', // HOURGENERIC_TZ
  'm': 'm', // MINUTE
  'ms': 'mm:ss', // MINUTE_SECOND
  's': 's', // SECOND
  'v': 'v', // ABBR_GENERIC_TZ
  'z': 'z', // ABBR_SPECIFIC_TZ
  'zzzz': 'zzzz', // SPECIFIC_TZ
  'ZZZZ': 'ZZZZ' // ABBR_UTC_TZ
};

/// A custom set of date symbols for the `lb` locale.
const lbDateSymbols = {
  "NAME": "lb",
  "ERAS": ['v. Chr.', 'n. Chr.'],
  "ERANAMES": ['v. Chr.', 'n. Chr.'],
  "NARROWMONTHS": ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'],
  "STANDALONENARROWMONTHS": ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'],
  "MONTHS": ['Januar', 'Februar', 'März', 'Abrëll', 'Mee', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'],
  "STANDALONEMONTHS": ['Januar', 'Februar', 'März', 'Abrëll', 'Mee', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'],
  "SHORTMONTHS": ['Jan.', 'Feb.', 'März', 'Apr.', 'Mee', 'Juni', 'Juli', 'Aug.', 'Sept.', 'Okt.', 'Nov.', 'Dez.'],
  "STANDALONESHORTMONTHS": ['Jan', 'Feb', 'Mär', 'Apr', 'Mee', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'],
  "WEEKDAYS": ['Sonndeg', 'Méindeg', 'Dënschdeg', 'Mëttwoch', 'Donneschdeg', 'Freideg', 'Samsdeg'],
  "STANDALONEWEEKDAYS": ['Sonndeg', 'Méindeg', 'Dënschdeg', 'Mëttwoch', 'Donneschdeg', 'Freideg', 'Samsdeg'],
  "SHORTWEEKDAYS": ['So.', 'Mo.', 'Di.', 'Mi.', 'Do.', 'Fr.', 'Sa.'],
  "STANDALONESHORTWEEKDAYS": ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'],
  "NARROWWEEKDAYS": ['S', 'M', 'D', 'M', 'D', 'F', 'S'],
  "STANDALONENARROWWEEKDAYS": ['S', 'M', 'D', 'M', 'D', 'F', 'S'],
  "SHORTQUARTERS": ['Q1', 'Q2', 'Q3', 'Q4'],
  "QUARTERS": ['1. Quartal', '2. Quartal', '3. Quartal', '4. Quartal'],
  "AMPMS": ['AM', 'PM'],
  "DATEFORMATS": ['EEEE, d. MMMM y', 'd. MMMM y', 'dd.MM.y', 'dd.MM.yy'],
  "TIMEFORMATS": ['HH:mm:ss zzzz', 'HH:mm:ss z', 'HH:mm:ss', 'HH:mm'],
  "DATETIMEFORMATS": ['{1}, {0}', '{1}, {0}', '{1}, {0}', '{1}, {0}'],
  "FIRSTDAYOFWEEK": 0,
  "WEEKENDRANGE": [5, 6],
  "FIRSTWEEKCUTOFFDAY": 3,
};

class _LbMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _LbMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'lb';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    final String localeName = intl.Intl.canonicalizedLocale(locale.toString());

    // The locale (in this case `lb`) needs to be initialized into the custom
    // date symbols and patterns setup that Flutter uses.
    date_symbol_data_custom.initializeDateFormattingCustom(
      locale: localeName,
      patterns: lbLocaleDatePatterns,
      symbols: intl.DateSymbols.deserializeFromMap(lbDateSymbols),
    );

    return SynchronousFuture<MaterialLocalizations>(
      LbMaterialLocalizations(
        localeName: localeName,
        // The `intl` library's NumberFormat class is generated from CLDR data
        // (see https://github.com/dart-lang/intl/blob/master/lib/number_symbols_data.dart).
        // Unfortunately, there is no way to use a locale that isn't defined in
        // this map and the only way to work around this is to use a listed
        // locale's NumberFormat symbols. So, here we use the number formats
        // for 'en_US' instead.
        decimalFormat: intl.NumberFormat('#,##0.###', 'de_DE'),
        twoDigitZeroPaddedFormat: intl.NumberFormat('00', 'de_DE'),
        // DateFormat here will use the symbols and patterns provided in the
        // `date_symbol_data_custom.initializeDateFormattingCustom` call above.
        // However, an alternative is to simply use a supported locale's
        // DateFormat symbols, similar to NumberFormat above.
        fullYearFormat: intl.DateFormat('y', localeName),
        compactDateFormat: intl.DateFormat('yMd', localeName),
        shortDateFormat: intl.DateFormat('yMMMd', localeName),
        mediumDateFormat: intl.DateFormat('EEE, MMM d', localeName),
        longDateFormat: intl.DateFormat('EEEE, MMMM d, y', localeName),
        yearMonthFormat: intl.DateFormat('MMMM y', localeName),
        shortMonthDayFormat: intl.DateFormat('MMM d'),
      ),
    );
  }

  @override
  bool shouldReload(_LbMaterialLocalizationsDelegate old) => false;
}

class _LbCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const _LbCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'lb';

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    final String localeName = intl.Intl.canonicalizedLocale(locale.toString());

    // The locale (in this case `lb`) needs to be initialized into the custom
    // date symbols and patterns setup that Flutter uses.
    date_symbol_data_custom.initializeDateFormattingCustom(
      locale: localeName,
      patterns: lbLocaleDatePatterns,
      symbols: intl.DateSymbols.deserializeFromMap(lbDateSymbols),
    );

    return SynchronousFuture<CupertinoLocalizations>(
      LbCupertinoLocalizations(
        localeName: localeName,
        // The `intl` library's NumberFormat class is generated from CLDR data
        // (see https://github.com/dart-lang/intl/blob/master/lib/number_symbols_data.dart).
        // Unfortunately, there is no way to use a locale that isn't defined in
        // this map and the only way to work around this is to use a listed
        // locale's NumberFormat symbols. So, here we use the number formats
        // for 'de_DE' instead.
        decimalFormat: intl.NumberFormat('#,##0.###', 'de_DE'),
        // DateFormat here will use the symbols and patterns provided in the
        // `date_symbol_data_custom.initializeDateFormattingCustom` call above.
        // However, an alternative is to simply use a supported locale's
        // DateFormat symbols, similar to NumberFormat above.
        fullYearFormat: intl.DateFormat('y', localeName),
        mediumDateFormat: intl.DateFormat('EEE, MMM d', localeName),
        dayFormat: intl.DateFormat('d', localeName),
        weekdayFormat: intl.DateFormat('EEE', localeName),
        doubleDigitMinuteFormat: intl.DateFormat('mm', localeName),
        singleDigitHourFormat: intl.DateFormat('hh', localeName),
        singleDigitMinuteFormat: intl.DateFormat('h', localeName),
        singleDigitSecondFormat: intl.DateFormat('s', localeName),
      ),
    );
  }

  @override
  bool shouldReload(_LbCupertinoLocalizationsDelegate old) => false;
}

class LbMaterialLocalizations extends GlobalMaterialLocalizations {
  const LbMaterialLocalizations({
    super.localeName = 'lb',
    required super.fullYearFormat,
    required super.compactDateFormat,
    required super.shortDateFormat,
    required super.mediumDateFormat,
    required super.longDateFormat,
    required super.yearMonthFormat,
    required super.shortMonthDayFormat,
    required super.decimalFormat,
    required super.twoDigitZeroPaddedFormat,
  });

  static const LocalizationsDelegate<MaterialLocalizations> delegate = _LbMaterialLocalizationsDelegate();

  @override
  String get aboutListTileTitleRaw => r'Iwwer $applicationName';

  @override
  String get alertDialogLabel => 'Notifikatioun';

  @override
  String get anteMeridiemAbbreviation => 'AM';

  @override
  String get backButtonTooltip => 'Zerèck';

  @override
  String get clearButtonTooltip => 'Text läschen';

  @override
  String get bottomSheetLabel => 'Usiicht am ënneren Rand';

  @override
  String get calendarModeButtonLabel => 'Zum Kalenner wiesselen';

  @override
  String get cancelButtonLabel => 'OFBRIECHEN';

  @override
  String get closeButtonLabel => 'SCHLÉISSEN';

  @override
  String get closeButtonTooltip => 'Schléissen';

  @override
  String get collapsedIconTapHint => 'Maximéieren';

  @override
  String get expansionTileExpandedHint => 'duebel tippen fir ze miniméieren';

  @override
  String get expansionTileCollapsedHint => 'duebel tippen fir ze erweideren';

  @override
  String get expansionTileExpandedTapHint => 'Miniméieren';

  @override
  String get expansionTileCollapsedTapHint => 'Erweideren fir méi Detailer';

  @override
  String get expandedHint => 'Miniméiert';

  @override
  String get collapsedHint => 'Erweidert';

  @override
  String get continueButtonLabel => 'WEIDER';

  @override
  String get copyButtonLabel => 'Kopéieren';

  @override
  String get currentDateLabel => 'Haut';

  @override
  String get cutButtonLabel => 'Ausschneiden';

  @override
  String get scanTextButtonLabel => 'Text scannen';

  @override
  String get dateHelpText => 'tt.mm.jjjj';

  @override
  String get dateInputLabel => 'Datum aginn';

  @override
  String get dateOutOfRangeLabel => 'Ausserhalb vum Zäitraum.';

  @override
  String get datePickerHelpText => 'DATUM AUSWIELEN';

  @override
  String get dateRangeEndDateSemanticLabelRaw => r'Enddatum $fullDate';

  @override
  String get dateRangeEndLabel => 'Enddatum';

  @override
  String get dateRangePickerHelpText => 'ZÄITRAUM AUSWIELEN';

  @override
  String get dateRangeStartDateSemanticLabelRaw => r'Startdatum $fullDate';

  @override
  String get dateRangeStartLabel => 'Startdatum';

  @override
  String get dateSeparator => '.';

  @override
  String get deleteButtonTooltip => 'Läschen';

  @override
  String get dialModeButtonLabel => 'Zur Auerzäitauswiel wiesselen';

  @override
  String get dialogLabel => 'Dialogfeld';

  @override
  String get drawerLabel => 'Navigatiounsmenü';

  @override
  String get expandedIconTapHint => 'Miniméieren';

  @override
  String get firstPageTooltip => 'Éischt Säit';

  @override
  String get hideAccountsLabel => 'Konten ausblenden';

  @override
  String get inputDateModeButtonLabel => 'Zur Textangab wiesselen';

  @override
  String get inputTimeModeButtonLabel => 'Zum Textangabemodus wiesselen';

  @override
  String get invalidDateFormatLabel => 'Ongëltegen Format.';

  @override
  String get invalidDateRangeLabel => 'Ongëltegen Zäitraum.';

  @override
  String get invalidTimeLabel => 'Gitt eng gülteg Auerzäit un';

  @override
  String get keyboardKeyAlt => 'Alt';

  @override
  String get keyboardKeyAltGraph => 'AltGr';

  @override
  String get keyboardKeyBackspace => 'Rècktast';

  @override
  String get keyboardKeyCapsLock => 'Caps Lock Tast';

  @override
  String get keyboardKeyChannelDown => 'Viregte Kanal';

  @override
  String get keyboardKeyChannelUp => 'Nächste Kanal';

  @override
  String get keyboardKeyControl => 'Strg';

  @override
  String get keyboardKeyDelete => 'Entf';

  @override
  String get keyboardKeyEject => 'Auswerfen';

  @override
  String get keyboardKeyEnd => 'Enn';

  @override
  String get keyboardKeyEscape => 'Esc';

  @override
  String get keyboardKeyFn => 'Fn';

  @override
  String get keyboardKeyHome => 'Pos1';

  @override
  String get keyboardKeyInsert => 'Einfg';

  @override
  String get keyboardKeyMeta => 'Meta';

  @override
  String get keyboardKeyMetaMacOs => 'Befehl';

  @override
  String get keyboardKeyMetaWindows => 'Win';

  @override
  String get keyboardKeyNumLock => 'Num';

  @override
  String get keyboardKeyNumpad0 => 'Num 0';

  @override
  String get keyboardKeyNumpad1 => 'Num 1';

  @override
  String get keyboardKeyNumpad2 => 'Num 2';

  @override
  String get keyboardKeyNumpad3 => 'Num 3';

  @override
  String get keyboardKeyNumpad4 => 'Num 4';

  @override
  String get keyboardKeyNumpad5 => 'Num 5';

  @override
  String get keyboardKeyNumpad6 => 'Num 6';

  @override
  String get keyboardKeyNumpad7 => 'Num 7';

  @override
  String get keyboardKeyNumpad8 => 'Num 8';

  @override
  String get keyboardKeyNumpad9 => 'Num 9';

  @override
  String get keyboardKeyNumpadAdd => 'Num +';

  @override
  String get keyboardKeyNumpadComma => 'Num ,';

  @override
  String get keyboardKeyNumpadDecimal => 'Num .';

  @override
  String get keyboardKeyNumpadDivide => 'Num /';

  @override
  String get keyboardKeyNumpadEnter => 'Num Agabstast';

  @override
  String get keyboardKeyNumpadEqual => 'Num =';

  @override
  String get keyboardKeyNumpadMultiply => 'Num *';

  @override
  String get keyboardKeyNumpadParenLeft => 'Num (';

  @override
  String get keyboardKeyNumpadParenRight => 'Num )';

  @override
  String get keyboardKeyNumpadSubtract => 'Num -';

  @override
  String get keyboardKeyPageDown => 'Bild rof';

  @override
  String get keyboardKeyPageUp => 'Bild rop';

  @override
  String get keyboardKeyPower => 'Un/Aus';

  @override
  String get keyboardKeyPowerOff => 'Aus';

  @override
  String get keyboardKeyPrintScreen => 'Drock';

  @override
  String get keyboardKeyScrollLock => 'Rollen';

  @override
  String get keyboardKeySelect => 'Auswielen';

  @override
  String get keyboardKeyShift => 'Ëmschalttast';

  @override
  String get keyboardKeySpace => 'Leertast';

  @override
  String get lastPageTooltip => 'Lescht Säit';

  @override
  String? get licensesPackageDetailTextFew => null;

  @override
  String? get licensesPackageDetailTextMany => null;

  @override
  String? get licensesPackageDetailTextOne => '1 Lizenz';

  @override
  String get licensesPackageDetailTextOther => r'$licenseCount Lizenzen';

  @override
  String? get licensesPackageDetailTextTwo => null;

  @override
  String? get licensesPackageDetailTextZero => 'Keng Lizenzen';

  @override
  String get licensesPageTitle => 'Lizenzen';

  @override
  String get menuBarMenuLabel => 'Menü an der Menüleiste';

  @override
  String get modalBarrierDismissLabel => 'Schléissen';

  @override
  String get menuDismissLabel => 'Menu schléissen';

  @override
  String get noSpellCheckReplacementsLabel => 'Keen Ersatz fonnt';

  @override
  String get moreButtonTooltip => 'Méi';

  @override
  String get nextMonthTooltip => 'Nächste Mount';

  @override
  String get nextPageTooltip => 'Nächst Säit';

  @override
  String get okButtonLabel => 'OK';

  @override
  String get openAppDrawerTooltip => 'Navigatiounsmenü opmaachen';

  @override
  String get pageRowsInfoTitleRaw => r'$firstRow–$lastRow vun $rowCount';

  @override
  String get pageRowsInfoTitleApproximateRaw => r'$firstRow–$lastRow vun zirka $rowCount';

  @override
  String get pasteButtonLabel => 'Asetzen';

  @override
  String get popupMenuLabel => 'Pop-up-Menü';

  @override
  String get postMeridiemAbbreviation => 'PM';

  @override
  String get previousMonthTooltip => 'Viregte Mount';

  @override
  String get previousPageTooltip => 'Viregt Säit';

  @override
  String get refreshIndicatorSemanticLabel => 'Aktualiséieren';

  @override
  String? get remainingTextFieldCharacterCountFew => null;

  @override
  String? get remainingTextFieldCharacterCountMany => null;

  @override
  String? get remainingTextFieldCharacterCountOne => 'Nach 1 Zeechen';

  @override
  String get remainingTextFieldCharacterCountOther => r'Nach $remainingCount Zeechen';

  @override
  String? get remainingTextFieldCharacterCountTwo => null;

  @override
  String? get remainingTextFieldCharacterCountZero => 'TBD';

  @override
  String get reorderItemDown => 'No ënnen verschiben';

  @override
  String get reorderItemLeft => 'No lénks verschiben';

  @override
  String get reorderItemRight => 'No riets verschiben';

  @override
  String get reorderItemToEnd => 'Um Enn verschiben';

  @override
  String get reorderItemToStart => 'Um Ufank verschiben';

  @override
  String get reorderItemUp => 'No uewen verschiben';

  @override
  String get rowsPerPageTitle => 'Zeilen pro Säit:';

  @override
  String get saveButtonLabel => 'Späicheren';

  @override
  String get scrimLabel => 'Gitter';

  @override
  String get scrimOnTapHintRaw => r'$modalRouteContentName schléissen';

  @override
  ScriptCategory get scriptCategory => ScriptCategory.englishLike;

  @override
  String get searchFieldLabel => 'Sichen';

  @override
  String get selectAllButtonLabel => 'All auswielen';

  @override
  String get lookUpButtonLabel => 'Nosichen';

  @override
  String get searchWebButtonLabel => 'Web sichen';

  @override
  String get shareButtonLabel => 'Deelen...';

  @override
  String get selectYearSemanticsLabel => 'Joer auswielen';

  @override
  String get selectedDateLabel => 'Gewielt';

  @override
  String? get selectedRowCountTitleFew => null;

  @override
  String? get selectedRowCountTitleMany => null;

  @override
  String? get selectedRowCountTitleOne => '1 Element ausgewielt';

  @override
  String get selectedRowCountTitleOther => r'$selectedRowCount Elementer ausgewielt';

  @override
  String? get selectedRowCountTitleTwo => null;

  @override
  String? get selectedRowCountTitleZero => 'Keng Objekter ausgewielt';

  @override
  String get showAccountsLabel => 'Konten uweisen';

  @override
  String get showMenuTooltip => 'Menü uweisen';

  @override
  String get signedInLabel => 'Ugemellt';

  @override
  String get tabLabelRaw => r'Tab $tabIndex vun $tabCount';

  @override
  TimeOfDayFormat get timeOfDayFormatRaw => TimeOfDayFormat.HH_colon_mm;

  @override
  String get timePickerDialHelpText => 'AUERZÄIT AUSWIELEN';

  @override
  String get timePickerHourLabel => 'Stonn';

  @override
  String get timePickerHourModeAnnouncement => 'Stonnen auswielen';

  @override
  String get timePickerInputHelpText => 'ZÄIT AGINN';

  @override
  String get timePickerMinuteLabel => 'Minutt';

  @override
  String get timePickerMinuteModeAnnouncement => 'Minutten auswielen';

  @override
  String get unspecifiedDate => 'Datum';

  @override
  String get unspecifiedDateRange => 'Zäitraum';

  @override
  String get viewLicensesButtonLabel => 'LIZENZEN UWEISEN';
}

/// The translations for Luxembourgish (`lb`).
class LbCupertinoLocalizations extends GlobalCupertinoLocalizations {
  /// Create an instance of the translation bundle for Luxembourgish.
  ///
  /// For details on the meaning of the arguments, see [GlobalCupertinoLocalizations].
  const LbCupertinoLocalizations({
    super.localeName = 'lb',
    required super.fullYearFormat,
    required super.dayFormat,
    required super.mediumDateFormat,
    required super.weekdayFormat,
    required super.singleDigitHourFormat,
    required super.singleDigitMinuteFormat,
    required super.doubleDigitMinuteFormat,
    required super.singleDigitSecondFormat,
    required super.decimalFormat,
  });

  static const LocalizationsDelegate<CupertinoLocalizations> delegate = _LbCupertinoLocalizationsDelegate();

  @override
  String get alertDialogLabel => 'Notifikatiounen';

  @override
  String get anteMeridiemAbbreviation => 'AM';

  @override
  String get clearButtonLabel => 'Clear';

  @override
  String get copyButtonLabel => 'Kopéieren';

  @override
  String get cutButtonLabel => 'Ausschneiden';

  @override
  String get datePickerDateOrderString => 'dmy';

  @override
  String get datePickerDateTimeOrderString => 'date_time_dayPeriod';

  @override
  String? get datePickerHourSemanticsLabelFew => null;

  @override
  String? get datePickerHourSemanticsLabelMany => null;

  @override
  String? get datePickerHourSemanticsLabelOne => r'$hour Auer';

  @override
  String get datePickerHourSemanticsLabelOther => r'$hour Auer';

  @override
  String? get datePickerHourSemanticsLabelTwo => null;

  @override
  String? get datePickerHourSemanticsLabelZero => null;

  @override
  String? get datePickerMinuteSemanticsLabelFew => null;

  @override
  String? get datePickerMinuteSemanticsLabelMany => null;

  @override
  String? get datePickerMinuteSemanticsLabelOne => '1 Minutt';

  @override
  String get datePickerMinuteSemanticsLabelOther => r'$minute Minutten';

  @override
  String? get datePickerMinuteSemanticsLabelTwo => null;

  @override
  String? get datePickerMinuteSemanticsLabelZero => null;

  @override
  String get modalBarrierDismissLabel => 'Schléissen';

  @override
  String get noSpellCheckReplacementsLabel => 'Keen Ersatz fonnt';

  @override
  String get pasteButtonLabel => 'Asetzen';

  @override
  String get postMeridiemAbbreviation => 'PM';

  @override
  String get searchTextFieldPlaceholderLabel => 'Sich';

  @override
  String get selectAllButtonLabel => 'Alles auswielen';

  @override
  String get tabSemanticsLabelRaw => r'Tab $tabIndex vun $tabCount';

  @override
  String? get timerPickerHourLabelFew => null;

  @override
  String? get timerPickerHourLabelMany => null;

  @override
  String? get timerPickerHourLabelOne => 'Stonn';

  @override
  String get timerPickerHourLabelOther => 'Stonnen';

  @override
  String? get timerPickerHourLabelTwo => null;

  @override
  String? get timerPickerHourLabelZero => null;

  @override
  String? get timerPickerMinuteLabelFew => null;

  @override
  String? get timerPickerMinuteLabelMany => null;

  @override
  String? get timerPickerMinuteLabelOne => 'Min.';

  @override
  String get timerPickerMinuteLabelOther => 'Min.';

  @override
  String? get timerPickerMinuteLabelTwo => null;

  @override
  String? get timerPickerMinuteLabelZero => null;

  @override
  String? get timerPickerSecondLabelFew => null;

  @override
  String? get timerPickerSecondLabelMany => null;

  @override
  String? get timerPickerSecondLabelOne => 's';

  @override
  String get timerPickerSecondLabelOther => 's';

  @override
  String? get timerPickerSecondLabelTwo => null;

  @override
  String? get timerPickerSecondLabelZero => null;

  @override
  String get todayLabel => 'Haut';

  @override
  String get lookUpButtonLabel => 'Nosichen';

  @override
  String get searchWebButtonLabel => 'Web sichen';

  @override
  String get shareButtonLabel => 'Deelen...';

  @override
  String get menuDismissLabel => 'Menu schléissen';
}
