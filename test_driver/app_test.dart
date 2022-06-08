import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../lib/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('tap on the floating action button, verify counter', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Finds the floating action button to tap on.
      final Finder menu = find.byTooltip("More options");

      // Emulate a tap on the floating action button.
      await tester.tap(menu);
      await tester.pumpAndSettle();

      await tester.tap(find.text("Settings"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Edit subjects"));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text("OK"));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      //await tester.tap(find.text("Edit subjects"));
      await tester.pumpAndSettle();
    });
  });
}
