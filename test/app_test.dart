// Flutter imports:
import "package:flutter/material.dart" as legacy;
import "package:flutter/services.dart";

// Package imports:
import "package:cupertino_ui/cupertino_ui.dart";
import "package:flutter_test/flutter_test.dart";
import "package:material_ui/material_ui.dart";
import "package:shared_preferences/shared_preferences.dart";

// Project imports:
import "package:graded/main.dart";
import "package:graded/ui/routes/setup_route.dart";
import "package:graded/ui/settings/flutter_settings_screens.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel("dynamic_color"),
      (_) async => null,
    );
    SharedPreferences.setMockInitialValues({"hapticFeedback": false});
    await Settings.init();
  });

  for (final language in ["en_GB", "lb"]) {
    testWidgets("App starts with $language localizations and a compatible theme", (tester) async {
      await Settings.setValue("language", language);
      await tester.pumpWidget(const AppContainer());
      await tester.pumpAndSettle();

      expect(find.byType(SetupPage), findsOneWidget);
      final context = tester.element(find.byType(SetupPage));
      expect(MaterialLocalizations.of(context).cancelButtonLabel, isNotEmpty);
      expect(CupertinoLocalizations.of(context).expansionTileCollapsedHint, isNotEmpty);
      expect(legacy.Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }, variant: const TargetPlatformVariant({TargetPlatform.windows}));
  }
}
