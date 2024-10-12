# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.7.1] - 2024-10-12

### Quick hotfix

- Fix UI issue when in Year mode

## [2.7.0] - 2024-10-05

### Added charts to visualise your progress and improved handling of saves

- Add charts and graphs
- Add iOS tinted and dark icons
- Add reverse custom sorting
- Optimize and unify the way data is saved
- Improve robustness of data upgrade from old versions
- Fix export missing keys
- Streamline codebase
- Various optimisations

## [2.6.5] - 2024-02-28

### Bugfixing and minor improvements

- Move bonus to its own dialog, allowing for more precise input
- Make app bar title scrollable when it overflows
- Add limit at maximum grade
- Fix BottomSheet maximum height
- Fix UI on Test dialog
- Add rounded edges to inksplashes
- Round negative numbers correctly
- Add missing tooltips
- Optimisations and minification

## [2.6.4] - 2024-01-28

### Added haptics and fixed long due minor UI bugs

- Add haptics on navigation and significant actions
- Add device info to email contact template
- Fix UI animations when the keyboard opens
- Fix TextFields becoming invalid on confirmation
- Fix Test dialog expanding spam

## [2.6.3] - 2023-12-31

### Bug fixing

- Precise average showcase
- Clear subjects when switching school systems in setup
- Fix year editing dialog
- Fix subject editing crashes
- Only show subject copying popup when there is actual data to copy
- Other minor optimisations and bugfixes

## [2.6.2] - 2023-12-22

### Minor changes and CI fixes

- Add icon to switches
- Add support for per-app language
- Specify language region for english
- UI fixes for longer strings
- Fix crash on old iOS versions
- Fix CI changelog upload
- Other minor optimisations and bugfixes

## [2.6.1] - 2023-12-19

### Added a few settings and improve font support

- Add prompt when creating new year to copy old subjects
- Add setting to show or hide leading zeros
- Add font preview in settings
- Add Roboto and SFPro fonts
- Fixed duplicate subject names being allowed
- Fixed some translations
- Code cleanup

## [2.6.0] - 2023-12-10

### Settings rework, new color and font options, and more consistent theming

- Update theming engine
- Add color options (dynamic color, custom color, amoled mode)
- Add font options
- Rework about and credits sections in settings
- Code cleanup
- Fixed multiple other UI bugs

## [2.5.1] - 2023-11-21

### Mostly bug fixes

- Enable predictive back gesture
- Rework some animations
- Fix iOS dialog flicker
- Fix errors on TextFields
- Fix rating system dialog
- Fix subjects being linked between terms
- Fix multiple bugs when popping routes
- Fix duplicated subject names
- Fix back gestures on iOS
- Code cleanup
- Upgrade to Flutter 3.16
- Add more test cases
- Fix changelogs in CI
- Fixed multiple other bugs

## [2.5.0] - 2023-11-10

### This version adds weights to tests, and reworks many parts of the user interface

- Redesign lists with Material 3 cards
- Add test weights
- Make test creation dialog expandable
- Add animations to various screens
- Add edge-to-edge rendering
- Fix blurry splash screen images
- Fix TabBar padding
- Vast code cleanup and optimisations
- Fixed multiple other bugs

## [2.4.2] - 2023-10-14

### Logo change and bug fixes

- Update icons and splash screen
- Update monochrome icon
- Fix round adaptive icon
- Fix AppBar title padding
- Fix AppBar landscape layout
- Fixed other bugs

## [2.4.1] - 2023-09-24

### Mostly bug fixes related to UI and theming

- Upgrade to Flutter 3.13
- Multiple theme fixes and optimisations
- Calculate all years before showing average
- Fix TabBar scrolling and updating
- Fix empty list widget
- CI changelog improvements
- Update store descriptions
- Fixed other bugs

## [2.4.0] - 2023-09-11

### This feature update includes support for multiple years as well as many other improvements

- Add support for saving and managing multiple years
- Add long press on subject to quick-create a test
- Add dates to tests and date sorting
- TabBar UI improvements
- Improve tooltips and accessibility
- Change behavior of precise average
- Add natural sorting to alphabetical sort
- Target Android 14
- Removed support for legacy 1.X.X versions
- Fixed many bugs

## [2.3.1] - 2023-07-05

- Add quarters
- Clean up translations
- Edit descriptions in settings
- Add more term options in during luxembourgish setup
- Start implementing multiple years support
- Fix subject group sorting
- Code cleanup
- Fixed some additional bugs

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
