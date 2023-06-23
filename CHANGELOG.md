# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.3.0] - 2023-06-23

### Introducing a new UI for switching terms and several under the hood improvements

- Added TabBar for switching terms
- Refactored routing system
- Optimized the app by reducing the amount of rebuilds
- Fixed several translation errors and inconsistencies
- Switch iOS rendering engine to Impeller
- Fixed blurred monochrome icon on Android
- Code cleanup
- Fixed some additional bugs

## [2.2.2] - 2023-05-14

### Lists can now be sorted in ascending and descending order, and the app now has a monochrome icon

- Added ascending and descending sorting
- Added monochrome icon
- Changed style in the settings screen
- Changed changelog workflow
- Cleaned up the project by changing linter rules
- Upgrade to Dart 3 and Flutter 3.10
- Fixed wrong exam calculation weight
- Fixed UI showcase not starting
- Fixed some additional bugs

## [2.2.1] - 2023-04-30

### This version has several language improvements, adds some new UI features and fixes a lot of bugs

- Added POEditor translation workflow. If you want to contribute, head over to [our POEditor project](https://poeditor.com/join/project/6qnhP0EM5w) and start translating!
- Switched to .arb translations
- Added translations for Dutch and Luxembourgish
- Fixed numerous translation inconsistencies
- Added an illustration for empty lists
- Fixed the white screen when reordering subjects
- Fixed bugs with the showcase in the subject editing screen
- Improve iOS keyboard handling
- Fixed some additional bugs

## [2.2.0] - 2023-03-29

### You can now easily add speaking tests with their own weight! You can edit the speaking weight on the subject editing page

- Added speaking tests
- Added unit tests
- Improved number parsing
- Fixed input validation
- Fixed some layout bugs

## [2.1.8] - 2023-03-15

### Test release

- Test release for CI publishing

## [2.1.7] - 2023-03-14

### This release includes some UI fixes and optimizations

- Fix various issues with displaying decimal numbers
- Code cleanup
- Implemented CI for automated publishing
- Fixed some bugs

## [2.1.5] - 2023-03-07

### You can now take a look at the precise average from a subject or a term by tapping on it

- Added the possibility to tap on a result to show the precise result
- Fixed a few layout bugs
- Fixed some bugs

## [2.1.4] - 2023-02-21

### You can now insert your exam grades in the new "exam" section, allowing them to be correctly calculated

- Added the possibility to insert exams in the luxembourgish system
- Improved iOS behavior and layout
- Fixed typo in "Luxemburgish"
- Fixed some bugs

## [2.1.3] - 2023-02-15

### You can now create and edit your own subject groups and create a custom sorting order for your subjects

- Added creation and editing of subject groups
- Added custom subject sorting order
- Data can now be imported from the setup screen
- Sorting and term popups now indicate the currently selected option
- Fixed many bugs

## [2.1.2] - 2023-01-31

### Your data can now be imported and exported in a simple JSON format

- Added Import/Export
- Improved landscape/tablet mode
- Fixed many bugs

## [2.1.0] - 2023-01-28

### Graded now supports the luxemburgish general system and subject groups

- Integrated the luxemburgish general system. Just select your class in a few quick taps!
- Added subject groups
- Improve setup flow
- Updated icon and splash screen
- Various optimisations, including a revamp of the class dataset
- Fixed many bugs

## [2.0.4] - 2022-12-19

### Bugfixes

- Renamed the app to Graded
- Improved page title animations
- Improved text fields
- Optimized several parts of the app
- Fixed many bugs

## [2.0.3] - 2022-12-13

### Grade.ly is now Graded! Same app, new name

- Renamed the app to Graded
- Improved page title animations
- Improved text fields
- Optimized several parts of the app
- Fixed many bugs

## [2.0.2] - 2022-12-01

### Quality of life update with improved transitions, optimizations and bug fixes

- Improved page transitions
- Added splash screen
- Added language selector
- Added coefficient sorting
- Optimized many parts of the app
- Many bugfixes

## [2.0.1] - 2022-11-15

### Bugfixes and improvements

- Bugfixes

## [2.0.0] - 2022-11-07

### The big rewrite of the app has finally dropped

- Rewrite of the app with the Flutter framework to add multi-platform capabilities
- Moved to Material You design
- Changed setup screen and added possibility to change class after initial setup
- Improved functions related to the year view
- Optimisation
- Bugfixes

## [1.0.4] - 2022-02-23

- Optimisation
- Bugfixes

## [1.0.3] - 2022-02-04

- Bugfixes

## [1.0.2] - 2022-02-03

- Bugfixes

## [1.0.1] - 2022-02-01

- Fixed UI with large subject names or large fonts

## [1.0.0] - 2022-01-31

### Grade.ly is finally out! Take advantage of it to track all your grades before the end of the semester

- Initial release
